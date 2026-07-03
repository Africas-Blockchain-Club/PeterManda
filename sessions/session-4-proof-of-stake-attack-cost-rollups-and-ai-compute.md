# Session 4 - Proof of Stake, the Cost of Attacking a Blockchain, Layer 2 Rollups, and Decentralised AI Compute

**Exclusive Friday Web3 & AI Workshop Series**

---

## The story of this session

Last session the platform started taking real payments: 1.10 USDC, about R20, paid from a wallet on Base Sepolia. This session followed that one payment all the way down. Who confirmed it? Why did they not steal it? Why was the network fee a fraction of a cent? And once the money was decentralised, why was the AI that wrote the report still owned by one company? Four questions, one transaction.

## What this session teaches

1. **Proof of Stake.** A blockchain has no bank to check transactions, so strangers called validators do it - and each one must first lock up 32 ETH as a deposit. Cheat, and the protocol burns the deposit automatically (slashing). Honesty pays a yield; theft costs the deposit. Think of a stokvel where the person counting the money had to put the largest amount into the pot first.
2. **The cost of attacking a blockchain.** To stall Ethereum an attacker needs roughly a third of all staked ETH; to control it, more than half. Price that in rand and the number runs into the trillions - and buying that much ETH drives the price up, a successful attack crashes the value of everything the attacker bought, and slashing burns the deposits on the way down. A blockchain is not secure because attack is impossible. It is secure because the attack is a fire that burns the arsonist first. Small chains with cheap security do get attacked - which is why our platform settles on a chain anchored to Ethereum.
3. **Layer 2 rollups.** Ethereum security at spaza-shop prices. A rollup such as Base collects hundreds of transactions, squashes them into one bundle, and posts that bundle to Ethereum - like fifteen passengers splitting one taxi fare instead of each hiring a private car. The honest caveat: most rollups today still have a single sequencer ordering the queue, so liveness depends on one company even though the funds inherit Ethereum's security.
4. **Decentralised AI compute.** Our payment travels through a system no single company controls - and then pays a single company to write the report. AI today is where money was before blockchain. Networks like Akash, Render, io.net, and Bittensor apply the validator pattern to computing power: strangers contribute a resource, stake something, earn for honest work. The open problem is verifiable compute - proving a stranger's machine really ran your model. Session 6 returns to it.

## What was built in the platform

- **The Attack Cost page.** A new dashboard page that prices an attack on Ethereum live: enter the total staked ETH (read it from beaconcha.in), pull the live ETH price, choose the attack (34% to stall finality, 51% to control consensus), and see the cost in US Dollars and Rand - including how many of our 1.10 USDC reports it would take to fund it. Code: the `Attack Cost` page in `research-team/dashboards/app.py`.
- The page has a defined off state: if the price feed is down, it says so and the presenter drives the numbers by hand. The lesson survives an outage.

Try it yourself:

```bash
cd research-team/
streamlit run dashboards/app.py
# Open "Attack Cost" in the sidebar
```

## Where the platform stood after this session

Nothing about the product changed for a paying user - and that is the point. This session was about the ground the payment already stands on: the validators who confirm it, the economics that keep them honest, and the rollup that makes it affordable. The platform gained a teaching instrument that prices that trust in rand.

## Key takeaways

- Security is a budget, not a property. Know what it costs to attack the chain you build on.
- A rollup borrows Ethereum's security the way a taxi borrows the road - you split the toll.
- The next frontier repeats the same pattern: money was decentralised first, transaction ordering second, computing power is next.
