# Session 3 - Contracts

Sepolia deployment for the Web3 Identity session contract race.

## Deployed Contract

**SessionFaucet address:** `0xe225F39BaD67510E1a220785dB95B7d8c434983C`

Etherscan: https://sepolia.etherscan.io/address/0xe225F39BaD67510E1a220785dB95B7d8c434983C

---

## Setup (run once before your session)

### 1. Install Foundry (if not already installed)

```bash
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup
```

Verify: `forge --version`

### 2. Configure environment

```bash
cp .env.contracts.example .env.contracts
```

Open `.env.contracts` and fill in:
- `PRIVATE_KEY` - your MetaMask deployer wallet private key
- `SEPOLIA_RPC_URL` - get a free endpoint from Alchemy or Infura
- `ETHERSCAN_API_KEY` - optional, from etherscan.io

### 3. Get Sepolia ETH

You need at least 0.35 ETH on Sepolia (0.3 for the faucet, rest for gas).

Faucets:
- https://sepoliafaucet.com
- https://faucet.quicknode.com/ethereum/sepolia
- https://faucets.chain.link (requires Chainlink account)

### 4. Deploy

```bash
cd contracts/
bash deploy.sh
```

The script will:
- Compile the contract
- Deploy to Sepolia
- Fund the faucet with 0.3 ETH
- Write the address to `deployed_address.txt` and `session-info.md`

### 5. Verify deployment

Open `session-info.md` and confirm the contract address is written.
Open the Etherscan link and confirm the Contract tab appears.

---

## Session Day

30 minutes before the session:

```bash
cd contracts/
bash pre_session_check.sh
```

All checks must pass before you start.

Then:
1. Copy the address from `deployed_address.txt` into slide 5
2. Open the Etherscan events tab in a browser tab
3. Share `StudentRequest.sol` with the cohort

---

## Contract Files

| File | Purpose |
|------|---------|
| `SessionFaucet.sol` | Peter's faucet - deploy this |
| `StudentRequest.sol` | Template for students - share this |
| `deploy.sh` | Deployment script |
| `pre_session_check.sh` | Pre-session verification |
| `.env.contracts` | Environment variables |
| `deployed_address.txt` | Written by deploy.sh after deploy |
| `session-info.md` | Full session info - written by deploy.sh |

---

## During the Session

Keep this tab open in your browser:

```
https://sepolia.etherscan.io/address/0xe225F39BaD67510E1a220785dB95B7d8c434983C#events
```

Every student request triggers a `FundRequest` event. You see it here.
Copy the requester address and run the approve command from `session-info.md`.

---

## After the Session

Withdraw remaining Sepolia ETH:

```bash
cast send $(cat deployed_address.txt) "withdraw()" \
    --private-key $PRIVATE_KEY \
    --rpc-url $SEPOLIA_RPC_URL
```
