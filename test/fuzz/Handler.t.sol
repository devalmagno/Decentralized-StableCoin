// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {ERC20Mock} from "openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract Handler is Test {
    DSCEngine engine;
    DecentralizedStableCoin dsc;
    ERC20Mock weth;
    ERC20Mock wbtc;

    // Ghost Variables
    uint96 public constant MAX_DEPOSIT_SIZE = type(uint96).max;

    constructor(DSCEngine _engine, DecentralizedStableCoin _dsc) {
        engine = _engine;
        dsc = _dsc;

        address[] memory collateralTokens = engine.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);
    }

    function mintDsc(uint256 _amountDsc) public {
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = engine.getAccountInformation(msg.sender);
        uint256 maxTotalDscToMint = (collateralValueInUsd / 2) - totalDscMinted;
        if (maxTotalDscToMint <= 0) return;

        _amountDsc = bound(_amountDsc, 1, maxTotalDscToMint);
        vm.prank(msg.sender);
        engine.mintDsc(_amountDsc);
    }

    function depositCollateral(uint256 _collateralSeed, uint256 _amountCollateral) public {
        _amountCollateral = bound(_amountCollateral, 1, MAX_DEPOSIT_SIZE);
        ERC20Mock collateral = _getCollateralFromSeed(_collateralSeed);

        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, _amountCollateral);
        collateral.approve(address(engine), _amountCollateral);
        engine.depositCollateral(address(collateral), _amountCollateral);
        vm.stopPrank();
    }

    function redeemCollateral(uint256 _collateralSeed, uint256 _amountCollateral) public {
        ERC20Mock collateral = _getCollateralFromSeed(_collateralSeed);
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = engine.getAccountInformation(msg.sender);
        uint256 maxCollateralToRedeemInUsd = (collateralValueInUsd / 2) - totalDscMinted;
        uint256 maxCollateralToRedeemInWeth =
            engine.getTokenAmountFromUsd(address(collateral), maxCollateralToRedeemInUsd);

        _amountCollateral = bound(_amountCollateral, 0, maxCollateralToRedeemInWeth);
        if (_amountCollateral == 0) {
            return;
        }
        console.log("amount to redeem: ", _amountCollateral);
        console.log("max amount to redeem: ", maxCollateralToRedeemInWeth);
        vm.prank(msg.sender);
        engine.redeemCollateral(address(collateral), _amountCollateral);
    }

    // Helper Functions
    function _getCollateralFromSeed(uint256 _collateralSeed) private view returns (ERC20Mock) {
        if (_collateralSeed % 2 == 0) {
            return weth;
        }
        return wbtc;
    }
}
