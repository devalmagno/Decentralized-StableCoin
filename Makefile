-include .env

.PHONY

install:; forge install OpenZeppelin/openzeppelin-contracts --no-commit && forge install smartcontractkit/chainlink-brownie-contracts --no-commit