// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {DeployDSC} from "script/DeployDSC.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract DSCEngineTest is Test {
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__NotAllowedToken();
    error DSCEngine__TransferFailed();

    DeployDSC public deployer;
    DecentralizedStableCoin public dsc;
    DSCEngine public engine;
    HelperConfig public config;

    address private constant USER = address(1);
    uint256 private constant SEND_VALUE = 10 ether;

    address private s_ethUsdPriceFeed;
    address private s_weth;

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, engine, config) = deployer.run();
        (s_weth,, s_ethUsdPriceFeed,) = config.activeNetworkConfig();
    }

    //////////////////////////////////////
    // Price Tests                      //
    //////////////////////////////////////
    function testGetUsdValueCanConvertCorrectly() public view {
        uint256 expectedPriceInUsd = 20000e18; // $20000 in USD
        uint256 priceInUsd = engine.getUsdValue(s_weth, SEND_VALUE);

        assertEq(expectedPriceInUsd, priceInUsd);
    }

    //////////////////////////////////////
    // depositCollateral Tests                    //
    //////////////////////////////////////
    function testDepositCollateralRevertWhenAmountIsZero() public {
        vm.expectRevert(DSCEngine__NeedsMoreThanZero.selector);
        vm.prank(USER);
        engine.depositCollateral(s_weth, 0);
    }

    function testDepositCollateralRevertWhenCollateralTokenIsNotAllowed() public {
        address notAllowedToken = address(new ERC20Mock("Not Allowed", "NOT"));

        vm.expectRevert(DSCEngine__NotAllowedToken.selector);
        vm.prank(USER);
        engine.depositCollateral(notAllowedToken, SEND_VALUE);
    }
}
