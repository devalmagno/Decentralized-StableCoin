# Decentralized Stablecoin

This project introduces a crypto-collateralized stablecoin, pegged to the USD, similar to $DAI. It is backed by wETH and wBTC, which serve as collateral for minting the stablecoin.

The entire process is executed on-chain, utilizing the DSCEngine smart contract, eliminating the need for a central authority. To acquire the stablecoin, users lock their wETH or wBTC into the DSCEngine and mint the desired amount while maintaining the health of their collateral.

The DSCEngine ensures the stablecoin remains over-collateralized to guard against price volatility in the underlying assets. For example, minting $1,000 of DSC (Decentralized Stablecoin) requires a deposit of $1,500 in wETH or wBTC, maintaining a 150% collateralization ratio.

Currently, the project is approximately 90% fully tested.

| File                             | % Lines          | % Statements     | % Branches     | % Funcs         |
| -------------------------------- | ---------------- | ---------------- | -------------- | --------------- |
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

- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Quickstart](#quickstart)
    - [Optional Gitpod](#optional-gitpod)
- [Usage](#usage)
  - [Start a local node](#start-a-local-node)
  - [Deploy](#deploy)
  - [Deploy - Other Network](#deploy---other-network)
  - [Testing](#testing)
    - [Test Coverage](#test-coverage)
- [Deployment to a testnet or mainnet](#deployment-to-a-testnet-or-mainnet)
  - [Scripts](#scripts)
  - [Estimate gas](#estimate-gas)
- [Formatting](#formatting)

# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`

## Quickstart

```
git clone https://github.com/Cyfrin/foundry-defi-stablecoin-cu
cd foundry-defi-stablecoin-cu
forge build
```

### Optional Gitpod

If you can't or don't want to run and install locally, you can work with this repo in Gitpod. If you do this, you can skip the `clone this repo` part.

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#github.com/devalmagno/Decentralized-StableCoin)


# Usage

## Start a local node

```
make anvil
```

## Deploy

This will default to your local node. You need to have it running in another terminal in order for it to deploy.

```
make deploy
```

## Deploy - Other Network

[See below](#deployment-to-a-testnet-or-mainnet)

## Testing


1. Unit
2. Integration
3. Forked
4. Staging

In this repo we cover #1 and Fuzzing.

```
forge test
```

### Test Coverage

```
forge coverage
```

and for coverage based testing:

```
forge coverage --report debug
```

# Deployment to a testnet or mainnet

1. Setup environment variables

You'll want to set your `SEPOLIA_RPC_URL` and `PRIVATE_KEY` as environment variables. You can add them to a `.env` file, similar to what you see in `.env.example`.

- `PRIVATE_KEY`: The private key of your account (like from [metamask](https://metamask.io/)). **NOTE:** FOR DEVELOPMENT, PLEASE USE A KEY THAT DOESN'T HAVE ANY REAL FUNDS ASSOCIATED WITH IT.
  - You can [learn how to export it here](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-Export-an-Account-Private-Key).
- `SEPOLIA_RPC_URL`: This is url of the sepolia testnet node you're working with. You can get setup with one for free from [Alchemy](https://alchemy.com/?a=673c802981)

Optionally, add your `ETHERSCAN_API_KEY` if you want to verify your contract on [Etherscan](https://etherscan.io/).

1. Get testnet ETH

Head over to [faucets.chain.link](https://faucets.chain.link/) and get some testnet ETH. You should see the ETH show up in your metamask.

2. Deploy

```
make deploy ARGS="--network sepolia"
```

## Scripts

Instead of scripts, we can directly use the `cast` command to interact with the contract.

For example, on Sepolia:

1. Get some WETH

```
cast send 0xdd13E55209Fd76AfE204dBda4007C227904f0a81 "deposit()" --value 0.1ether --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```

2. Approve the WETH

```
cast send 0xdd13E55209Fd76AfE204dBda4007C227904f0a81 "approve(address,uint256)" 0x091EA0838eBD5b7ddA2F2A641B068d6D59639b98 1000000000000000000 --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```

3. Deposit and Mint DSC

```
cast send 0x091EA0838eBD5b7ddA2F2A641B068d6D59639b98 "depositCollateralAndMintDsc(address,uint256,uint256)" 0xdd13E55209Fd76AfE204dBda4007C227904f0a81 100000000000000000 10000000000000000 --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```

## Estimate gas

You can estimate how much gas things cost by running:

```
forge snapshot
```

And you'll see an output file called `.gas-snapshot`

# Formatting

To run code formatting:

```
forge fmt
```

# Slither

```
slither :; slither . --config-file slither.config.json
```
