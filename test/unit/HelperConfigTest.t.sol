// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {ERC20Mock} from "test/mocks/ERC20Mock.sol";
import {MockV3Aggregator} from "test/mocks/MockV3Aggregator.sol";

contract HelperConfigTest is Test {
    HelperConfig config;

    uint8 constant DECIMALS = 8;
    int256 constant ETH_USD_PRICE = 2000e8;
    int256 constant BTC_USD_PRICE = 1000e8;

    NetworkConfig public sepoliaNetworkConfig;
    NetworkConfig public anvilNetworkConfig;

    struct NetworkConfig {
        address weth;
        address wbtc;
        address ethPriceFeed;
        address btcPriceFeed;
    }

    function setUp() external {
        config = new HelperConfig();

        sepoliaNetworkConfig = NetworkConfig({
            weth: 0xdd13E55209Fd76AfE204dBda4007C227904f0a81,
            wbtc: 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063,
            ethPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            btcPriceFeed: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
        });

        (address weth, address wbtc, address ethPriceFeed, address btcPriceFeed) = config.getAnvilEthConfigAttributes();
        anvilNetworkConfig =
            NetworkConfig({weth: weth, wbtc: wbtc, ethPriceFeed: ethPriceFeed, btcPriceFeed: btcPriceFeed});
    }

    function testGetSepoliaEthConfig() public view {
        if (block.chainid != 11155111) return;
        assertEq(keccak256(abi.encode(config.getSepoliaEthConfig())), keccak256(abi.encode(sepoliaNetworkConfig)));
    }

    function testGetOrCreateAnvilConfig() public {
        if (block.chainid != 31337) return;
        assertEq(keccak256(abi.encode(config.getAnvilEthConfig())), keccak256(abi.encode(anvilNetworkConfig)));
    }
}
