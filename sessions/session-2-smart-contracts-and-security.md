# Session 2 — Smart Contracts and Security

**Exclusive Friday Web3 & AI Workshop Series**
**Recording:** https://youtu.be/Uy6vNMs6VRE
**Slides:** https://amb013-uj.my.canva.site/session-2-smart-contracts-amp-security

---

## The story of this session

A contract on paper needs a lawyer, a court, and months of patience to enforce. A smart contract enforces itself: the rules are code, the code lives on a blockchain, and nobody - not even the person who wrote it - can bend them after deployment. In this session the cohort stopped reading about smart contracts and deployed one.

## What this session teaches

1. **What a smart contract actually is.** A program stored on a blockchain that holds money and enforces rules without a middleman. Once deployed, it runs exactly as written - which is both its superpower and its danger.
2. **Why security is the whole job.** A bug in normal software gets patched on Tuesday. A bug in a deployed smart contract is permanent and often drains real money. Writing less code, checking every assumption, and testing before deploying is not good practice here - it is survival.
3. **The deploy workflow.** Write in Solidity, compile and test with Foundry, fund a wallet with testnet ETH, deploy to the Sepolia testnet, and verify the contract on a block explorer where anyone can read it.
4. **Reading a contract on a block explorer.** A deployed contract is public. Anyone in the world can inspect its code, its balance, and every call ever made to it. Transparency is the default, not a feature.

## What was built in the platform

The `contracts/` folder is the fossil record of this stage:

- **`SessionFaucet.sol`** - a faucet contract deployed on Sepolia that hands out small amounts of testnet ETH, with a per-student cap and a pause switch. It is the class treasury, run by code.
- **`StudentRequest.sol`** - the challenge contract: each cohort member deploys their own contract that must successfully call `requestFunds()` on the faucet. Your contract talking to my contract - composability, met in week two.
- **`deploy.sh`** and `foundry.toml` - the deploy pipeline, so the process is repeatable rather than magic.

Try it yourself:

```bash
cd contracts/
forge build --root . --contracts .
# See contracts/contracts_README.md and session-info.md for the faucet address and cast commands
```

## Where the platform stood after this session

A research platform that could analyse tokens, plus a proven ability to put our own code on a public blockchain. The two had not met yet. That happens next.

## Key takeaways

- Code that holds money must be treated differently from code that does not.
- Deployment is permanent. Test on a testnet until boredom sets in, then test again.
- A block explorer is the single most useful tool in this industry: learn to read one.
