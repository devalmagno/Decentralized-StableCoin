Compiling 48 files with Solc 0.8.26
Solc 0.8.26 finished in 2.25s
Compiler run successful with warnings:
Warning (3420): Source file does not specify required compiler version! Consider adding "pragma solidity ^0.8.26;"
--> test/fuzz/OpenInvariantTest.t.sol

Analysing contracts...
Running tests...

Ran 6 tests for test/unit/DecentralizedStableCoinTest.t.sol:DecentralizedStableCoinTest
[PASS] testBurnFailsWhenAmountIsLessOrEqualToZero() (gas: 13560)
[PASS] testBurnFailsWhenBalanceIsLessThanAmountToBurn() (gas: 13584)
[PASS] testDecentralizedStableCoinIsInitializedCorrectly() (gas: 19527)
[PASS] testMintAndBurnDsc() (gas: 71328)
[PASS] testMintFailsWhenAddressZero() (gas: 11920)
[PASS] testMintFailsWhenAmountToMintIsZero() (gas: 11941)
Suite result: ok. 6 passed; 0 failed; 0 skipped; finished in 917.89µs (1.53ms CPU time)

Ran 2 tests for test/unit/HelperConfigTest.t.sol:HelperConfigTest
[PASS] testGetOrCreateAnvilConfig() (gas: 30449)
[PASS] testGetSepoliaEthConfig() (gas: 189)
Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 1.40ms (337.74µs CPU time)

Ran 20 tests for test/unit/DSCEngineTest.t.sol:DSCEngineTest
[PASS] testBurnDsc() (gas: 273493)
[PASS] testCanDepositCollateralAndGetAccountInfo() (gas: 142636)
[PASS] testDepositCollateralAndMintDsc() (gas: 230989)
[PASS] testDepositCollateralRevertWhenCollateralTokenIsNotAllowed() (gas: 932090)
[PASS] testDepositCollateralRevertsIfAmountIsZero() (gas: 41428)
[PASS] testGetTokenAmountFromUsd() (gas: 43885)
[PASS] testGetUsdValue() (gas: 43865)
[PASS] testLiquidateFailsWhenHealthFactorIsNotImproved() (gas: 546535)
[PASS] testLiquidateFailsWhenUserHealthFactorIsOk() (gas: 232469)
[PASS] testLiquidateImprovesUserHealthFactor() (gas: 558362)
[PASS] testMintDscRevertsIfAmountIsZero() (gas: 9567)
[PASS] testMintDscRevertsIfHealthFactorIsBroken() (gas: 176168)
[PASS] testRedeemCollateralAndBurnDsc() (gas: 320431)
[PASS] testRedeemCollateralRevertsWhenAmountIsZero() (gas: 12077)
[PASS] testRedeemCollateralRevertsWhenHealthFactorIsBroken() (gas: 214615)
[PASS] testRevertsIfTokenLengthDoesntMatchPriceFeeds() (gas: 182534)
[PASS] testUserCanDepositCollateral() (gas: 139377)
[PASS] testUserCanMintDsc() (gas: 228217)
[PASS] testUserCanRedeemCollateralWhenDSCBalanceIsZero() (gas: 138609)
[PASS] testUserCanRedeemCollateralWhenDscBalanceIsNotZero() (gas: 264729)
Suite result: ok. 20 passed; 0 failed; 0 skipped; finished in 30.15s (43.11ms CPU time)

Ran 3 tests for test/fuzz/InvariantTest.t.sol:InvariantTest
[PASS] invariant__dscEngineGettersShouldNotRevert() (runs: 128, calls: 16384, reverts: 0)
[PASS] invariant__helperConfigGettersShouldNotRevert() (runs: 128, calls: 16384, reverts: 0)
[PASS] invariant__protocolMustHaveMoreValueThanTotalSupply() (runs: 128, calls: 16384, reverts: 0)
Suite result: ok. 3 passed; 0 failed; 0 skipped; finished in 45.72s (100.10s CPU time)

Ran 4 test suites in 45.72s (75.87s CPU time): 31 tests passed, 0 failed, 0 skipped (31 total tests)
| File                             | % Lines          | % Statements     | % Branches     | % Funcs         |
|----------------------------------|------------------|------------------|----------------|-----------------|
| script/DeployDSC.s.sol           | 100.00% (10/10)  | 100.00% (14/14)  | 100.00% (0/0)  | 100.00% (1/1)   |
| script/HelperConfig.s.sol        | 70.37% (19/27)   | 71.43% (25/35)   | 100.00% (3/3)  | 57.14% (4/7)    |
| src/DSCEngine.sol                | 91.14% (72/79)   | 93.14% (95/102)  | 45.45% (5/11)  | 100.00% (26/26) |
| src/DecentralizedStableCoin.sol  | 100.00% (12/12)  | 100.00% (13/13)  | 100.00% (4/4)  | 100.00% (3/3)   |
| src/libraries/OracleLib.sol      | 100.00% (5/5)    | 85.71% (6/7)     | 0.00% (0/1)    | 100.00% (1/1)   |
| src/libraries/PriceConverter.sol | 100.00% (10/10)  | 100.00% (17/17)  | 100.00% (0/0)  | 100.00% (4/4)   |
| test/fuzz/Handler.t.sol          | 90.32% (56/62)   | 91.03% (71/78)   | 100.00% (6/6)  | 85.71% (6/7)    |
| test/mocks/ERC20Mock.sol         | 50.00% (1/2)     | 50.00% (1/2)     | 100.00% (0/0)  | 66.67% (2/3)    |
| test/mocks/MockV3Aggregator.sol  | 41.18% (7/17)    | 41.18% (7/17)    | 100.00% (0/0)  | 33.33% (2/6)    |
| Total                            | 85.71% (192/224) | 87.37% (249/285) | 72.00% (18/25) | 84.48% (49/58)  |
