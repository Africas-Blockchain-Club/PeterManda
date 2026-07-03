# Session 3 - Web3 Identity, Self-Custody Trade-offs, and AI Agents That Hold and Spend Crypto

**Exclusive Friday Web3 & AI Workshop Series**

---

## The story of this session

Every account you own on the internet is borrowed. Your email, your banking profile, your social media - a company holds the keys and lends you access. Lose the provider's goodwill, or their password reset flow, and the identity is gone. A wallet is different: the keys live with you, and no company sits between you and your money. In this session the research platform grew a wallet, and both kinds of identity started working side by side in the same product.

## What this session teaches

1. **Web2 identity vs Web3 identity.** Web2 identity is an account a provider controls (email plus password, recoverable, suspendable). Web3 identity is a key pair you control (a wallet address, unrecoverable if lost, unsuspendable by anyone). Neither is simply better - they trade convenience for sovereignty.
2. **The self-custody trade-off, honestly.** Self-custody means no password reset, no fraud department, no undo button. The price of nobody being able to freeze your money is that nobody can rescue it either. Products that respect users offer both paths and let them choose.
3. **AI agents that hold and spend crypto - the first look.** An AI agent cannot open a bank account, but it can hold a private key. That single fact makes crypto the native money of software. The platform's `x402/` folder holds a working demo of a client that pays a paywall automatically - the seed of an agent that buys its own data.

## What was built in the platform

Both identities now live in the product, and the contrast is the lesson:

- **Pay with your Web3 identity.** The Pay to Unlock panel connects a browser wallet (MetaMask or any EIP-1193 wallet), switches to Base Sepolia, and sends 1.10 USDC in one click. The wallet address - not a username - is who paid. Code: `research-team/dashboards/wallet_pay/index.html` plus the payment gate in `dashboards/app.py`.
- **Receive with your Web2 identity.** The finished report and receipt are emailed to an address the payer chooses. Email is still the best delivery channel humans actually check - Web2 identity earns its place. Code: `research-team/emailer.py`.
- **Sign in with your wallet.** The sidebar lets a returning payer connect their wallet and see the reports that address has unlocked. No account was ever created; the address is the account. Code: `research-team/dashboards/wallet_connect/index.html` and `db.get_payments_by_payer`.
- **The self-custody fallback.** Users without a wallet extension can pay manually from any wallet or exchange and paste a transaction hash - because self-custody has friction, and a real product plans for it.
- **The agent seed.** `research-team/x402/` contains a mock paywall server and a wallet client that detects an HTTP 402 Payment Required response, pays it, and retries - no human in the loop. Session 6 grows this seed.

Try it yourself:

```bash
cd research-team/
streamlit run dashboards/app.py
# Fetch data for a token, then click "Pay ... USDC with your wallet"
```

## Where the platform stood after this session

A researcher that earns. Payments verify on-chain before a single AI token is spent, purchase history belongs to a wallet address, and delivery still meets users where they are - their inbox.

## Key takeaways

- A wallet address is an identity nobody can suspend; an email address is an identity somebody else administers. A good product can use both deliberately.
- Self-custody is a trade, not an upgrade. Know what you gain and what you give up.
- The moment software can hold a key, software can hold money. Everything that follows in this series builds on that.
