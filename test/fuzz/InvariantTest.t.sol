// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// 1. The total supply of DSC should be less than the total value of collateral
// 2. Getter view functions should never revert <- evergreen invariant

import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {DeployDSC} from "script/DeployDSC.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {Handler} from "test/fuzz/Handler.t.sol";

contract InvariantTest is StdInvariant, Test {
    DeployDSC deployer;
    DecentralizedStableCoin dsc;
    DSCEngine engine;
    HelperConfig config;
    Handler handler;

    address weth;
    address wbtc;

    function setUp() external {
        deployer = new DeployDSC();
        (dsc, engine, config) = deployer.run();
        (weth, wbtc,,) = config.activeNetworkConfig();
        handler = new Handler(engine, dsc);
        targetContract(address(handler));
    }

    function invariant__protocolMustHaveMoreValueThanTotalSupply() public view {
        // get the value of all the collateral in the protocol
        // compare it to all the debt (dsc);
        uint256 totalSupply = dsc.totalSupply();
        uint256 timesMintIsCalled = handler.timesMintIsCalled();
        uint256 timesRedeemIsCalled = handler.timesRedeemIsCalled();
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(engine));
        uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(engine));

        uint256 wethValue = engine.getUsdValue(weth, totalWethDeposited);
        uint256 wbtcValue = engine.getUsdValue(wbtc, totalWbtcDeposited);
        uint256 totalValue = wethValue + wbtcValue;
        console.log("weth value: ", wethValue);
        console.log("wbtc value: ", wbtcValue);
        console.log("total supply: ", totalSupply);
        console.log("times minted is called: ", timesMintIsCalled);
        console.log("times redeemed is called: ", timesRedeemIsCalled);
        assert(totalValue >= totalSupply);
    }

    function invariant__gettersShouldNotRevert() public view {
        engine.getAccountCollateralValue(msg.sender);
        engine.getAccountInformation(msg.sender);
        engine.getCollateralBalanceOfUser(msg.sender, weth);
        engine.getCollateralBalanceOfUser(msg.sender, wbtc);
        engine.getCollateralTokens();
        engine.getDSCBalanceOfUser(msg.sender);
        engine.getTokenAmountFromUsd(weth, 1);
        engine.getUsdValue(weth, 1);
        engine.getPriceFeed(address(weth));
        engine.getPriceFeed(address(wbtc));
        engine.getUserHealthFactor(msg.sender);
    }
}
