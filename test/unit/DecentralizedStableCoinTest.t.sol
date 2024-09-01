// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";

contract DecentralizedStableCoinTest is Test {
    error DecentralizedStableCoin__MustBeMoreThanZero();
    error DecentralizedStableCoin__BurnAmountExceedsBalance();
    error DecentralizedStableCoin__NotZeroAddress();

    DecentralizedStableCoin public dsc;

    uint256 private constant AMOUNT_TO_MINT = 200;
    uint256 private constant AMOUNT_TO_BURN = 50;

    function setUp() external {
        dsc = new DecentralizedStableCoin();
    }

    //////////////////////////////////////
    // constructor Tests                //
    //////////////////////////////////////
    function testDecentralizedStableCoinIsInitializedCorrectly() public view {
        assertEq(dsc.name(), "Decentralized Stable Coin");
        assertEq(dsc.symbol(), "DSC");
    }

    //////////////////////////////////////
    // burn Tests                       //
    //////////////////////////////////////
    function testBurnFailsWhenAmountIsLessOrEqualToZero() public {
        vm.expectRevert(DecentralizedStableCoin__MustBeMoreThanZero.selector);
        dsc.burn(0);
    }

    function testBurnFailsWhenBalanceIsLessThanAmountToBurn() public {
        // We going to burn 1 $DSC, but the $DSC minted is 0
        vm.expectRevert(DecentralizedStableCoin__BurnAmountExceedsBalance.selector);
        dsc.burn(1);
    }

    //////////////////////////////////////
    // mint Tests                       //
    //////////////////////////////////////
    function testMintFailsWhenAddressZero() public {
        vm.expectRevert(DecentralizedStableCoin__NotZeroAddress.selector);
        dsc.mint(address(0), 1);
    }

    function testMintFailsWhenAmountToMintIsZero() public {
        vm.expectRevert(DecentralizedStableCoin__MustBeMoreThanZero.selector);
        dsc.mint(address(this), 0);
    }

    //////////////////////////////////////
    // mint and burn Tests              //
    //////////////////////////////////////
    function testMintAndBurnDsc() public {
        dsc.mint(address(this), AMOUNT_TO_MINT);
        uint256 startingMintedBalance = dsc.balanceOf(address(this));
        assertEq(dsc.totalSupply(), AMOUNT_TO_MINT);
        assertEq(startingMintedBalance, AMOUNT_TO_MINT);

        dsc.burn(AMOUNT_TO_BURN);
        uint256 endingUserBalance = AMOUNT_TO_MINT - AMOUNT_TO_BURN;

        assertEq(dsc.totalSupply(), endingUserBalance);
        assertEq(dsc.balanceOf(address(this)), endingUserBalance);
    }
}
