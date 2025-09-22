# Strategies for OmniFarming

This is a repo that aggregates, stores, and builds strategies for OmniFarming V2. The strategies are written in the ERC4626 standard.

# Contracts

### OffChainStrategy

OffChain Strategy is a strategy that integrates ROFL with the purpose of farming through off-chain logic. The strategy is designed with an authorized address to be able to withdraw funds from the strategy, farm them outside, and update profits to the vault.

### Deployment

| Vault           | Strategy          | Address                                    |
| --------------- | ----------------- | ------------------------------------------ |
| USDC V2 on Base | Offchain Strategy | 0xD2a9dB8f22707166e82EdF89534340237780eDA3 |
