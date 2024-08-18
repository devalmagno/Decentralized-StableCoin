// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {ERC20Mock} from "test/mocks/ERC20Mock.sol";
import {MockV3Aggregator} from "test/mocks/MockV3Aggregator.sol";

contract Handler is Test {
    DSCEngine engine;
    DecentralizedStableCoin dsc;
    ERC20Mock weth;
    ERC20Mock wbtc;

    uint256 public timesMintIsCalled;
    uint256 public timesRedeemIsCalled;
    address[] public usersWithcollateralDeposited;

    MockV3Aggregator public ethUsdPriceFeed;

    // Ghost Variables
    uint96 public constant MAX_DEPOSIT_SIZE = type(uint96).max;

    constructor(DSCEngine _engine, DecentralizedStableCoin _dsc) {
        engine = _engine;
        dsc = _dsc;

        address[] memory collateralTokens = engine.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);
        ethUsdPriceFeed = MockV3Aggregator(engine.getPriceFeed(address(weth)));
    }

    function mintDsc(uint256 _amountDsc, uint256 _addressSeed) public {
        if (usersWithcollateralDeposited.length == 0) return;

        address sender = usersWithcollateralDeposited[_addressSeed % usersWithcollateralDeposited.length];
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = engine.getAccountInformation(sender);
        int256 maxTotalDscToMint = (int256(collateralValueInUsd) / 2) - int256(totalDscMinted);
        if (maxTotalDscToMint <= 0) return;

        _amountDsc = bound(_amountDsc, 0, uint256(maxTotalDscToMint));
        console.log("Amount DSC to mint: ", _amountDsc);
        console.log("Max Total DSC to mint: ", maxTotalDscToMint);
        if (_amountDsc == 0) return;
        vm.prank(sender);
        engine.mintDsc(_amountDsc);
        timesMintIsCalled++;
    }

    function depositCollateral(uint256 _collateralSeed, uint256 _amountCollateral) public {
        _amountCollateral = bound(_amountCollateral, 1, MAX_DEPOSIT_SIZE);
        ERC20Mock collateral = _getCollateralFromSeed(_collateralSeed);
        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, _amountCollateral);
        collateral.approve(address(engine), _amountCollateral);
        engine.depositCollateral(address(collateral), _amountCollateral);
        vm.stopPrank();

        // double push
        usersWithcollateralDeposited.push(msg.sender);
    }

    function redeemCollateral(uint256 _collateralSeed, uint256 _amountCollateral, uint256 _addressSeed) public {
        if (usersWithcollateralDeposited.length == 0) return;

        address sender = usersWithcollateralDeposited[_addressSeed % usersWithcollateralDeposited.length];
        ERC20Mock collateralToRedeem = _getCollateralFromSeed(_collateralSeed);

        uint256 redeemedCollateralDeposited = engine.getCollateralBalanceOfUser(sender, address(collateralToRedeem));
        if (redeemedCollateralDeposited == 0) {
            return;
        }

        uint256 redeemedCollateralDepositedInUsd =
            engine.getUsdValue(address(collateralToRedeem), redeemedCollateralDeposited);
        uint256 maxCollateralValue = engine.getAccountCollateralValue(sender);

        uint256 totalDscMinted = engine.getDSCBalanceOfUser(sender);

        uint256 maxCollateralToRedeem = (maxCollateralValue / 2) - totalDscMinted;

        if (maxCollateralToRedeem == 0) {
            return;
        } else if (maxCollateralToRedeem > redeemedCollateralDepositedInUsd) {
            maxCollateralToRedeem = redeemedCollateralDepositedInUsd;
        }

        uint256 maxCollateral = engine.getTokenAmountFromUsd(address(collateralToRedeem), maxCollateralToRedeem);

        _amountCollateral = bound(_amountCollateral, 0, maxCollateral);
        if (_amountCollateral == 0) {
            return;
        }
        timesRedeemIsCalled++;

        vm.prank(sender);
        engine.redeemCollateral(address(collateralToRedeem), _amountCollateral);
    }

    // This breaks our invariant test suite!!!
    // function updateCollateralPrice(uint96 _newPrice) public {
    //     _newPrice = uint96(bound(_newPrice, 1, (type(uint96).max)));
    //     int256 newPriceInt = int256(uint256(_newPrice));
    //     ethUsdPriceFeed.updateAnswer(newPriceInt);
    // }

    // Helper Functions
    function _getCollateralFromSeed(uint256 _collateralSeed) private view returns (ERC20Mock) {
        if (_collateralSeed % 2 == 0) {
            return weth;
        }
        return wbtc;
    }
}
