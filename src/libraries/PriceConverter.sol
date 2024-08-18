// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from
    "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {OracleLib} from "src/libraries/OracleLib.sol";

library PriceConverter {
    using OracleLib for AggregatorV3Interface;

    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;

    function _getPrice(AggregatorV3Interface _priceFeed) internal view returns (uint256) {
        (, int256 answer,,,) = _priceFeed.staleCheckLastestRoundData();
        // $2000e8 * 1e10
        return uint256(answer) * ADDITIONAL_FEED_PRECISION;
    }

    function _getConversionRate(uint256 _amount, AggregatorV3Interface _priceFeed) internal view returns (uint256) {
        uint256 tokenPrice = _getPrice(_priceFeed);
        uint256 tokenAmountInUsd = (tokenPrice * _amount) / PRECISION;

        return tokenAmountInUsd;
    }

    function _convertToPrecisionValue(uint256 _value) internal pure returns (uint256) {
        // $value * 1e18
        return _value * PRECISION;
    }

    function _convertUsdToEth(uint256 _usdAmount, AggregatorV3Interface _priceFeed) internal view returns (uint256) {
        _usdAmount = _convertToPrecisionValue(_usdAmount);
        uint256 price = _getPrice(_priceFeed);
        uint256 rate = _usdAmount / price;
        return rate;
    }
}
