// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "test/mocks/MockV3Aggregator.sol";
import {MockERC20} from "test/mocks/MockERC20.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 constant DECIMALS = 8;
    int256 constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address wethTokenAddress;
        address wbtcTokenAddress;
        address wethPriceFeed;
        address wbtcPriceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory config = NetworkConfig({
            wethTokenAddress: 0xdd13E55209Fd76AfE204dBda4007C227904f0a81,
            wbtcTokenAddress: 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063,
            wethPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            wbtcPriceFeed: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
        });

        return config;
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        vm.startBroadcast();
        MockERC20 weth = new MockERC20("Wrapped Ethereum", "WETH");
        MockERC20 wbtc = new MockERC20("Wrapped Bitcoin", "WBTC");
        MockV3Aggregator wethPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        MockV3Aggregator wbtcPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory config = NetworkConfig({
            wethTokenAddress: address(weth),
            wbtcTokenAddress: address(wbtc),
            wethPriceFeed: address(wethPriceFeed),
            wbtcPriceFeed: address(wbtcPriceFeed)
        });

        return config;
    }
}
