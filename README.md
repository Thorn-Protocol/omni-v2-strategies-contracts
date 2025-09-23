# Strategies for OmniFarming

This is a repo that aggregates, stores, and builds strategies for OmniFarming V2. The strategies are written in the ERC4626 standard.

# Contracts

### Wasabi Strategy

Wasabi Strategy is to generate profit by providing liquidity to the protocol for leverage trading. The contract is deployed by Wasabi itself, compliant with the ERC4626 standard so just plug it directly into the vault to integrate.

- Pool info: https://app.wasabi.xyz/earn?chain=base&vault=sUSDC&network=base
- Address: `0x1C4a802FD6B591BB71dAA01D8335e43719048B24`

### Off-chain Strategy

OffChain Strategy is a strategy that integrates ROFL with the purpose of farming through off-chain logic. The strategy is designed with an authorized address to be able to withdraw funds from the strategy, farm them outside, and update profits to the vault.

- Off-chain Agent repo: https://github.com/Thorn-Protocol/omni-v2-off-chain-server

### Deployment

| Vault           | Strategy          | Address                                    |
| --------------- | ----------------- | ------------------------------------------ |
| USDC V2 on Base | Offchain Strategy | 0xD2a9dB8f22707166e82EdF89534340237780eDA3 |
|                 | Wasabi Strategy   | 0x1C4a802FD6B591BB71dAA01D8335e43719048B24 |
