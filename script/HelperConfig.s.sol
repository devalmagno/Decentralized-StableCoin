// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "test/mocks/MockV3Aggregator.sol";
import {ERC20Mock} from "test/mocks/ERC20Mock.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 constant DECIMALS = 8;
    int256 constant ETH_USD_PRICE = 2000e8;
    int256 constant BTC_USD_PRICE = 1000e8;

    struct NetworkConfig {
        address weth;
        address wbtc;
        address ethPriceFeed;
        address btcPriceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory config = NetworkConfig({
            weth: 0xdd13E55209Fd76AfE204dBda4007C227904f0a81,
            wbtc: 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063,
            ethPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            btcPriceFeed: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
        });

        return config;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.ethPriceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        ERC20Mock weth = new ERC20Mock("Wrapped Ethereum", "WETH");
        ERC20Mock wbtc = new ERC20Mock("Wrapped Bitcoin", "WBTC");
        MockV3Aggregator wethPriceFeed = new MockV3Aggregator(DECIMALS, ETH_USD_PRICE);
        MockV3Aggregator wbtcPriceFeed = new MockV3Aggregator(DECIMALS, BTC_USD_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory config = NetworkConfig({
            weth: address(weth),
            wbtc: address(wbtc),
            ethPriceFeed: address(wethPriceFeed),
            btcPriceFeed: address(wbtcPriceFeed)
        });

        return config;
    }
}
