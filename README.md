1. Relative Stability: Anchored or Pegged -> $1.00
   1. Chainlink Price feed.
   2. Set a function to exchange ETH & BTC -> $$$
2. Stability Mechanism (Minting): Algorithmic (Decentralized)
   1. People can only mint the stablecoin with enough collateral (coded)
3. Collateral: Exogenous (Crypto)
   1. wETH
   2. wBTC

| File                             | % Lines          | % Statements     | % Branches     | % Funcs         |
| -------------------------------- | ---------------- | ---------------- | -------------- | --------------- |
| script/DeployDSC.s.sol           | 100.00% (10/10)  | 100.00% (14/14)  | 100.00% (0/0)  | 100.00% (1/1)   |
| script/HelperConfig.s.sol        | 0.00% (0/15)     | 0.00% (0/19)     | 0.00% (0/3)    | 0.00% (0/3)     |
| src/DSCEngine.sol                | 91.14% (72/79)   | 93.14% (95/102)  | 45.45% (5/11)  | 100.00% (26/26) |
| src/DecentralizedStableCoin.sol  | 100.00% (12/12)  | 100.00% (13/13)  | 100.00% (4/4)  | 100.00% (3/3)   |
| src/libraries/OracleLib.sol      | 100.00% (5/5)    | 85.71% (6/7)     | 0.00% (0/1)    | 100.00% (1/1)   |
| src/libraries/PriceConverter.sol | 100.00% (10/10)  | 100.00% (17/17)  | 100.00% (0/0)  | 100.00% (4/4)   |
| test/fuzz/Handler.t.sol          | 90.32% (56/62)   | 91.03% (71/78)   | 100.00% (6/6)  | 85.71% (6/7)    |
| test/mocks/ERC20Mock.sol         | 50.00% (1/2)     | 50.00% (1/2)     | 100.00% (0/0)  | 66.67% (2/3)    |
| test/mocks/MockV3Aggregator.sol  | 41.18% (7/17)    | 41.18% (7/17)    | 100.00% (0/0)  | 33.33% (2/6)    |
| Total                            | 81.60% (173/212) | 83.27% (224/269) | 60.00% (15/25) | 83.33% (45/54)  |
