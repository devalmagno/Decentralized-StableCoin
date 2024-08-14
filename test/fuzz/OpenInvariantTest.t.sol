// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.18;

// // 1. The total supply of DSC should be less than the total value of collateral
// // 2. Getter view functions should never revert <- evergreen invariant

// import {Test} from "forge-std/Test.sol";
// import {StdInvariant} from "forge-std/StdInvariant.sol";
// import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

// import {DeployDSC} from "script/DeployDSC.s.sol";
// import {HelperConfig} from "script/HelperConfig.s.sol";
// import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
// import {DSCEngine} from "src/DSCEngine.sol";

// contract OpenInvariantTest is StdInvariant, Test {
//     DeployDSC deployer;
//     DecentralizedStableCoin dsc;
//     DSCEngine engine;
//     HelperConfig config;
//     address weth;
//     address wbtc;

//     function setUp() external {
//         deployer = new DeployDSC();
//         (dsc, engine, config) = deployer.run();
//         (weth, wbtc,,) = config.activeNetworkConfig();
//         targetContract(address(engine));
//     }

//     function invariant__protocolMustHaveMoreValueThanTotalSupply() public view {
//         // get the value of all the collateral in the protocol
//         // compare it to all the debt (dsc);
//         uint256 totalSupply = dsc.totalSupply();
//         uint256 totalWethDeposited = IERC20(weth).balanceOf(address(engine));
//         uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(engine));

//         uint256 wethValue = engine.getUsdValue(weth, totalWethDeposited);
//         uint256 wbtcValue = engine.getUsdValue(wbtc, totalWbtcDeposited);
//         uint256 totalValue = wethValue + wbtcValue;
//         assert(totalValue >= totalSupply);
//     }
// }
