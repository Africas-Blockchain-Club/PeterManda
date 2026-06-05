# Session 3 - Contract Race - Session Info

**Contract**: SessionFaucet  
**Network**: Sepolia Testnet  
**Address**: `0xe225F39BaD67510E1a220785dB95B7d8c434983C`  
**Etherscan**: https://sepolia.etherscan.io/address/0xe225F39BaD67510E1a220785dB95B7d8c434983C  
**Tx Hash**: `0x9cb75b573ad830609a468209cf63be7861ae728a622cbe9f71b3b99d01d4fd52`  
**Block**: 10995809  
**Deployer**: `0x95CD2382EB8DF97fC1e0f3adAA1A9a97FB2b9431`  
**Deployed**: 2026-06-05  

---

## Faucet Settings

| Setting | Value |
|---------|-------|
| Max request per student | 0.008 ETH |
| Faucet balance at deploy | 0.05 ETH |
| Paused at deploy | false (active) |

---

## Cast Commands (run from contracts/ folder)

```bash
source .env.contracts

# Check faucet balance
cast balance 0xe225F39BaD67510E1a220785dB95B7d8c434983C --rpc-url $SEPOLIA_RPC_URL

# Approve a student request
cast send 0xe225F39BaD67510E1a220785dB95B7d8c434983C "approve(address)" <STUDENT_ADDRESS> --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY

# Deny a student request
cast send 0xe225F39BaD67510E1a220785dB95B7d8c434983C "deny(address,string)" <STUDENT_ADDRESS> "reason" --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY

# Pause requests
cast send 0xe225F39BaD67510E1a220785dB95B7d8c434983C "setPaused(bool)" true --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY

# Unpause requests
cast send 0xe225F39BaD67510E1a220785dB95B7d8c434983C "setPaused(bool)" false --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY

# Withdraw remaining ETH after session
cast send 0xe225F39BaD67510E1a220785dB95B7d8c434983C "withdraw()" --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```
