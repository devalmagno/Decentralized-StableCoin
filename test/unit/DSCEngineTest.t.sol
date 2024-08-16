// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {DeployDSC} from "script/DeployDSC.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract DSCEngineTest is Test {
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__NotAllowedToken();
    error DSCEngine__TransferFailed();
    error DSCEngine__BreaksHealthFactor(uint256 _healthFactor);
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();

    DeployDSC public deployer;
    DecentralizedStableCoin public dsc;
    DSCEngine public engine;
    HelperConfig public config;

    address private constant USER = address(1);
    uint256 private constant AMOUNT_COLLATERAL = 10 ether;
    uint256 private constant AMOUNT_TO_MINT_IN_WETH = 5 ether;
    uint256 private constant STARTING_ERC20_BALANCE = 10 ether;
    uint256 private constant PRECISION = 1e18;

    address private s_ethUsdPriceFeed;
    address private s_weth;
    uint256 private s_amountDscToMintInUsd; // 5 ether in usd
    uint256 private s_collateralValueInUsd; // 10 ether in usd

    modifier approved() {
        vm.prank(USER);
        IERC20(s_weth).approve(address(engine), AMOUNT_COLLATERAL);
        _;
    }

    modifier deposited() {
        vm.prank(USER);
        engine.depositCollateral(s_weth, AMOUNT_COLLATERAL);
        _;
    }

    modifier minted() {
        vm.prank(USER);
        engine.mintDsc(s_amountDscToMintInUsd);
        _;
    }

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, engine, config) = deployer.run();
        (s_weth,, s_ethUsdPriceFeed,) = config.activeNetworkConfig();
        ERC20Mock(s_weth).mint(USER, AMOUNT_COLLATERAL);
        s_amountDscToMintInUsd = engine.getUsdValue(s_weth, AMOUNT_TO_MINT_IN_WETH);
        s_collateralValueInUsd = engine.getUsdValue(s_weth, AMOUNT_COLLATERAL);
    }

    //////////////////////////////////////
    // Constructor Tests                //
    //////////////////////////////////////
    address[] public s_tokenAddresses;
    address[] public s_priceFeedAddresses;

    function testRevertsIfTokenLengthDoesntMatchPriceFeeds() public {
        s_tokenAddresses.push(s_weth);
        s_priceFeedAddresses.push(s_ethUsdPriceFeed);
        s_priceFeedAddresses.push(s_ethUsdPriceFeed);
        vm.expectRevert(DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength.selector);
        new DSCEngine(s_tokenAddresses, s_priceFeedAddresses, address(dsc));
    }

    //////////////////////////////////////
    // Price Tests                      //
    //////////////////////////////////////
    function testGetUsdValue() public view {
        uint256 ethPriceInUsd = engine.getUsdValue(s_weth, 1 ether);
        uint256 expectedPriceInUsd = (AMOUNT_COLLATERAL * ethPriceInUsd) / 1e18; // $20000 in USD
        uint256 priceInUsd = engine.getUsdValue(s_weth, AMOUNT_COLLATERAL);

        assertEq(expectedPriceInUsd, priceInUsd);
    }

    function testGetTokenAmountFromUsd() public view {
        uint256 usdAmount = 100e18; // $100 in USD * PRECISION
        uint256 ethPriceInUsd = engine.getUsdValue(s_weth, 1 ether);
        uint256 expectedWeth = (usdAmount * PRECISION) / ethPriceInUsd;
        uint256 actualWeth = engine.getTokenAmountFromUsd(s_weth, usdAmount);
        assertEq(expectedWeth, actualWeth);
    }

    //////////////////////////////////////
    // depositCollateral Tests          //
    //////////////////////////////////////
    function testDepositCollateralRevertsIfAmountIsZero() public approved {
        vm.expectRevert(DSCEngine__NeedsMoreThanZero.selector);
        vm.prank(USER);
        engine.depositCollateral(s_weth, 0);
    }

    function testDepositCollateralRevertWhenCollateralTokenIsNotAllowed() public approved {
        address notAllowedToken = address(new ERC20Mock("Not Allowed", "NOT"));

        vm.prank(USER);
        vm.expectRevert(DSCEngine__NotAllowedToken.selector);
        engine.depositCollateral(notAllowedToken, AMOUNT_COLLATERAL);
    }

    function testUserCanDepositCollateral() public approved {
        uint256 sendValueInUsd = engine.getUsdValue(s_weth, AMOUNT_COLLATERAL);

        vm.prank(USER);
        engine.depositCollateral(s_weth, AMOUNT_COLLATERAL);

        uint256 accountCollateralValue = engine.getAccountCollateralValue(USER);

        assertEq(sendValueInUsd, accountCollateralValue);
    }

    function testCanDepositCollateralAndGetAccountInfo() public approved deposited {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = engine.getAccountInformation(USER);
        uint256 expectedCollateralInUsd = engine.getUsdValue(s_weth, AMOUNT_COLLATERAL);
        uint256 expectedTotalDscMinted = 0;

        assertEq(totalDscMinted, expectedTotalDscMinted);
        assertEq(collateralValueInUsd, expectedCollateralInUsd);
    }

    //////////////////////////////////////
    // mintDsc Tests                    //
    //////////////////////////////////////
    function testMintDscRevertsIfAmountIsZero() public {
        vm.expectRevert(DSCEngine__NeedsMoreThanZero.selector);
        vm.prank(USER);
        engine.mintDsc(0);
    }

    function testMintDscRevertsIfHealthFactorIsBroken() public approved deposited {
        uint256 amountDscToMintInWeth = AMOUNT_TO_MINT_IN_WETH * 0.1 ether; // 5 ether + 0.1 = 5.1 ether
        uint256 amountDscToMintInUsd = engine.getUsdValue(s_weth, amountDscToMintInWeth);
        uint256 amountCollateralInUsd = engine.getUsdValue(s_weth, AMOUNT_COLLATERAL);
        uint256 expectedHealthFactor = engine.calculateHealthFactor(amountDscToMintInUsd, amountCollateralInUsd);

        vm.prank(USER);
        vm.expectRevert(abi.encodeWithSelector(DSCEngine__BreaksHealthFactor.selector, expectedHealthFactor));
        engine.mintDsc(amountDscToMintInUsd); // It will fail because amount to mint needs to be 50% lower than the amount of collateral deposited by the user in USD
    }

    function testUserCanMintDsc() public approved deposited minted {
        (uint256 totalDscMinted,) = engine.getAccountInformation(USER);
        assertEq(totalDscMinted, s_amountDscToMintInUsd);
    }

    //////////////////////////////////////
    // depositCollateralAndMintDsc Tests//
    //////////////////////////////////////
    function testDepositCollateralAndMintDsc() public approved deposited minted {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = engine.getAccountInformation(USER);
        assertEq(totalDscMinted, s_amountDscToMintInUsd);
        assertEq(collateralValueInUsd, s_collateralValueInUsd);
    }

    //////////////////////////////////////
    // redeemCollateral Tests           //
    //////////////////////////////////////
    function testRedeemCollateralRevertsIfAmountIsZero() public {
        vm.prank(USER);
        vm.expectRevert(DSCEngine__NeedsMoreThanZero.selector);
        engine.redeemCollateral(s_weth, 0);
    }
}
