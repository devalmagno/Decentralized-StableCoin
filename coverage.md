Compiling 46 files with Solc 0.8.26
Solc 0.8.26 finished in 2.06s
Compiler run successful with warnings:
Warning (3420): Source file does not specify required compiler version! Consider adding "pragma solidity ^0.8.26;"
--> test/fuzz/OpenInvariantTest.t.sol

Analysing contracts...
Running tests...

Ran 18 tests for test/unit/DSCEngineTest.t.sol:DSCEngineTest
[PASS] testBurnDsc() (gas: 277334)
[PASS] testCanDepositCollateralAndGetAccountInfo() (gas: 146455)
[PASS] testDepositCollateralAndMintDsc() (gas: 234808)
[PASS] testDepositCollateralRevertWhenCollateralTokenIsNotAllowed() (gas: 932090)
[PASS] testDepositCollateralRevertsIfAmountIsZero() (gas: 41472)
[PASS] testGetTokenAmountFromUsd() (gas: 43885)
[PASS] testGetUsdValue() (gas: 43865)
[PASS] testLiquidateFailsWhenUserHealthFactorIsOk() (gas: 236313)
[PASS] testMintDscRevertsIfAmountIsZero() (gas: 9500)
[PASS] testMintDscRevertsIfHealthFactorIsBroken() (gas: 179943)
[PASS] testRedeemCollateralAndBurnDsc() (gas: 323795)
[PASS] testRedeemCollateralRevertsWhenAmountIsZero() (gas: 12055)
[PASS] testRedeemCollateralRevertsWhenHealthFactorIsBroken() (gas: 217617)
[PASS] testRevertsIfTokenLengthDoesntMatchPriceFeeds() (gas: 182685)
[PASS] testUserCanDepositCollateral() (gas: 143218)
[PASS] testUserCanMintDsc() (gas: 232058)
[PASS] testUserCanRedeemCollateralWhenDSCBalanceIsZero() (gas: 141593)
[PASS] testUserCanRedeemCollateralWhenDscBalanceIsNotZero() (gas: 266070)
Suite result: ok. 18 passed; 0 failed; 0 skipped; finished in 30.65s (33.74ms CPU time)

Ran 2 tests for test/fuzz/InvariantTest.t.sol:InvariantTest
[PASS] invariant__gettersShouldNotRevert() (runs: 128, calls: 16384, reverts: 0)
[PASS] invariant__protocolMustHaveMoreValueThanTotalSupply() (runs: 128, calls: 16384, reverts: 0)
Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 41.28s (71.93s CPU time)

Ran 2 test suites in 41.28s (71.93s CPU time): 20 tests passed, 0 failed, 0 skipped (20 total tests)
| File                             | % Lines          | % Statements     | % Branches     | % Funcs         |
|----------------------------------|------------------|------------------|----------------|-----------------|
| script/DeployDSC.s.sol           | 100.00% (10/10)  | 100.00% (14/14)  | 100.00% (0/0)  | 100.00% (1/1)   |
| script/HelperConfig.s.sol        | 0.00% (0/15)     | 0.00% (0/19)     | 0.00% (0/3)    | 0.00% (0/3)     |
| src/DSCEngine.sol                | 79.75% (63/79)   | 80.20% (81/101)  | 36.36% (4/11)  | 100.00% (25/25) |
| src/DecentralizedStableCoin.sol  | 66.67% (8/12)    | 69.23% (9/13)    | 0.00% (0/4)    | 66.67% (2/3)    |
| src/libraries/OracleLib.sol      | 100.00% (5/5)    | 85.71% (6/7)     | 0.00% (0/1)    | 100.00% (1/1)   |
| src/libraries/PriceConverter.sol | 100.00% (10/10)  | 100.00% (17/17)  | 100.00% (0/0)  | 100.00% (4/4)   |
| test/fuzz/Handler.t.sol          | 90.32% (56/62)   | 91.03% (71/78)   | 100.00% (6/6)  | 85.71% (6/7)    |
| test/mocks/ERC20Mock.sol         | 50.00% (1/2)     | 50.00% (1/2)     | 100.00% (0/0)  | 66.67% (2/3)    |
| test/mocks/MockV3Aggregator.sol  | 5.88% (1/17)     | 5.88% (1/17)     | 100.00% (0/0)  | 16.67% (1/6)    |
| Total                            | 72.64% (154/212) | 74.63% (200/268) | 40.00% (10/25) | 79.25% (42/53)  |
