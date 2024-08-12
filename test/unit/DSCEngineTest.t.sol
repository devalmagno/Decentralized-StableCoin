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
    uint256 private constant STARTING_ERC20_BALANCE = 10 ether;

    address private s_ethUsdPriceFeed;
    address private s_weth;

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

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, engine, config) = deployer.run();
        (s_weth,, s_ethUsdPriceFeed,) = config.activeNetworkConfig();
        ERC20Mock(s_weth).mint(USER, AMOUNT_COLLATERAL);
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
        uint256 usdAmount = 100 ether;
        uint256 ethPriceInUsd = engine.getUsdValue(s_weth, 1 ether);
        uint256 expectedWeth = (usdAmount * 1e18) / ethPriceInUsd;
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

    // function testMintDscRevertsIfHealthFactorIsBroken() public approved deposited {
    //     uint256 amountDscToMint = engine.getUsdValue(s_weth, AMOUNT_COLLATERAL * 10); // 10 ether * 10 = 100 ether
    //     vm.prank(USER);
    //     vm.expectRevert(
    //         abi.encodeWithSelector(DSCEngine__BreaksHealthFactor.selector, )
    //     );
    //     engine.mintDsc(amountDscToMint); // It will fail because amount to mint needs to be 25% less than the amount of collateral deposited by the user in USD
    // }
}
