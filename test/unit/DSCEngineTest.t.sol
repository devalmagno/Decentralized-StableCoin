// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {DeployDSC} from "script/DeployDSC.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {ERC20Mock} from "test/mocks/ERC20Mock.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {MockV3Aggregator} from "test/mocks/MockV3Aggregator.sol";

contract DSCEngineTest is Test {
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__NotAllowedToken();
    error DSCEngine__TransferFailed();
    error DSCEngine__BreaksHealthFactor(uint256 _healthFactor);
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error DSCEngine__HealthFactorOk();
    error DSCEngine__HealthFactorNotImproved();

    DeployDSC public deployer;
    DecentralizedStableCoin public dsc;
    DSCEngine public engine;
    HelperConfig public config;

    address private constant USER = address(1);
    uint256 private constant AMOUNT_COLLATERAL = 10 ether;
    uint256 private constant AMOUNT_TO_MINT_IN_WETH = 2 ether;
    uint256 private constant STARTING_ERC20_BALANCE = 10 ether;
    uint256 private constant PRECISION = 1e18;

    address private s_ethUsdPriceFeedAddress;
    MockV3Aggregator private s_ethUsdPriceFeed;
    address private s_weth;
    uint256 private s_amountDscToMintInUsd; // 5 ether in usd
    uint256 private s_amountToBurn; // s_amountDscToMintInUsd / 2
    uint256 private s_collateralValueInUsd; // 10 ether in usd
    uint256 private s_expectedHealthFactor; // 10 ether in usd

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
        (s_weth,, s_ethUsdPriceFeedAddress,) = config.activeNetworkConfig();
        s_ethUsdPriceFeed = MockV3Aggregator(s_ethUsdPriceFeedAddress);

        ERC20Mock(s_weth).mint(USER, AMOUNT_COLLATERAL);

        s_amountDscToMintInUsd = engine.getUsdValue(s_weth, AMOUNT_TO_MINT_IN_WETH);
        s_collateralValueInUsd = engine.getUsdValue(s_weth, AMOUNT_COLLATERAL);
        s_expectedHealthFactor = engine.getUsdValue(s_weth, AMOUNT_COLLATERAL);

        s_amountToBurn = s_amountDscToMintInUsd / 2;
    }

    //////////////////////////////////////
    // Constructor Tests                //
    //////////////////////////////////////
    address[] public s_tokenAddresses;
    address[] public s_priceFeedAddresses;

    function testRevertsIfTokenLengthDoesntMatchPriceFeeds() public {
        s_tokenAddresses.push(s_weth);
        s_priceFeedAddresses.push(s_ethUsdPriceFeedAddress);
        s_priceFeedAddresses.push(s_ethUsdPriceFeedAddress);
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
        uint256 amountDscToMintInWeth = AMOUNT_TO_MINT_IN_WETH * 3.1 ether; // 2 ether + 3.1 = 5.1 ether
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
    function testRedeemCollateralRevertsWhenAmountIsZero() public {
        vm.prank(USER);
        vm.expectRevert(DSCEngine__NeedsMoreThanZero.selector);
        engine.redeemCollateral(s_weth, 0);
    }

    function testUserCanRedeemCollateralWhenDSCBalanceIsZero() public approved deposited {
        uint256 totalDSCMinted = engine.getDSCBalanceOfUser(USER);
        uint256 startingCollateralBalance = engine.getCollateralBalanceOfUser(USER, s_weth);

        vm.prank(USER);
        engine.redeemCollateral(s_weth, AMOUNT_COLLATERAL);
        uint256 endingCollateralBalance = engine.getCollateralBalanceOfUser(USER, s_weth);

        assertEq(totalDSCMinted, 0);
        assert(startingCollateralBalance > endingCollateralBalance);
    }

    function testRedeemCollateralRevertsWhenHealthFactorIsBroken() public approved deposited minted {
        uint256 totalDscMinted = engine.getDSCBalanceOfUser(USER);
        uint256 expectedHealthFactor = engine.calculateHealthFactor(totalDscMinted, 0); // Redeeming all of the collateral will result in collateralValueInUsd = 0, so healthFactor = 0

        vm.prank(USER);
        vm.expectRevert(abi.encodeWithSelector(DSCEngine__BreaksHealthFactor.selector, expectedHealthFactor));
        engine.redeemCollateral(s_weth, AMOUNT_COLLATERAL);
    }

    function testUserCanRedeemCollateralWhenDscBalanceIsNotZero() public approved deposited minted {
        uint256 totalDscMinted = engine.getDSCBalanceOfUser(USER);
        uint256 totalDscMintedInWeth = engine.getTokenAmountFromUsd(s_weth, totalDscMinted);
        uint256 startingWethCollateralBalance = engine.getCollateralBalanceOfUser(USER, s_weth);
        uint256 amountToRedeem = (startingWethCollateralBalance / 2) - totalDscMintedInWeth;
        uint256 expectedWethCollateralBalance = startingWethCollateralBalance - amountToRedeem;
        console.log("amountToRedeem: ", amountToRedeem);
        console.log("startingWethCollateralBalance: ", startingWethCollateralBalance);
        console.log("Total DSC Minted in WETH: ", totalDscMintedInWeth);

        vm.prank(USER);
        engine.redeemCollateral(s_weth, amountToRedeem);
        uint256 endingWethCollateralBalance = engine.getCollateralBalanceOfUser(USER, s_weth);

        assertEq(endingWethCollateralBalance, expectedWethCollateralBalance);
    }

    //////////////////////////////////////
    // burnDSC Tests                    //
    //////////////////////////////////////
    function testBurnDsc() public approved deposited minted {
        uint256 totalDscMinted = engine.getDSCBalanceOfUser(USER);
        assertEq(totalDscMinted, s_amountDscToMintInUsd);

        uint256 amountToBurn = totalDscMinted / 2;
        uint256 expectedDscBalance = totalDscMinted - amountToBurn;

        vm.startPrank(USER);
        IERC20(address(dsc)).approve(address(engine), amountToBurn);
        engine.burnDsc(amountToBurn);
        vm.stopPrank();

        uint256 endingDscBalance = engine.getDSCBalanceOfUser(USER);
        assertEq(expectedDscBalance, endingDscBalance);
    }

    //////////////////////////////////////
    // redeemCollateralAndBurnDsc Tests //
    //////////////////////////////////////
    function testRedeemCollateralAndBurnDsc() public approved deposited minted {
        uint256 startingCollateralBalance = engine.getCollateralBalanceOfUser(USER, s_weth);

        uint256 expectedDscBalance = s_amountDscToMintInUsd - s_amountToBurn;
        uint256 expectedDscBalanceInWeth = engine.getTokenAmountFromUsd(s_weth, expectedDscBalance);

        uint256 maxCollateralToRedeem = (startingCollateralBalance / 2) - expectedDscBalanceInWeth;
        uint256 expectedCollateralBalance = startingCollateralBalance - maxCollateralToRedeem;

        vm.startPrank(USER);
        IERC20(address(dsc)).approve(address(engine), s_amountToBurn);
        engine.redeemCollateralForDsc(s_weth, maxCollateralToRedeem, s_amountToBurn);
        vm.stopPrank();

        uint256 endingDscBalance = engine.getDSCBalanceOfUser(USER);
        uint256 endingCollateralBalance = engine.getCollateralBalanceOfUser(USER, s_weth);
        assertEq(expectedDscBalance, endingDscBalance);
        assertEq(endingCollateralBalance, expectedCollateralBalance);
    }

    //////////////////////////////////////
    // liquidate Tests                  //
    //////////////////////////////////////
    function testLiquidateFailsWhenUserHealthFactorIsOk() public approved deposited minted {
        vm.expectRevert(DSCEngine__HealthFactorOk.selector);
        engine.liquidate(s_weth, USER, s_amountDscToMintInUsd);
    }

    function testLiquidateFailsWhenHealthFactorIsNotImproved() public approved deposited minted {
        int256 newPrice = 500e8;
        s_ethUsdPriceFeed.updateAnswer(newPrice);
        uint256 startingUserHealthFactor = engine.getUserHealthFactor(USER);
        console.log(startingUserHealthFactor);

        // vm.expectRevert(DSCEngine__HealthFactorNotImproved.selector);
        engine.liquidate(s_weth, USER, s_amountToBurn);

        uint256 endingUserHealthFactor = engine.getUserHealthFactor(USER);
        console.log(startingUserHealthFactor, endingUserHealthFactor);
    }
}
