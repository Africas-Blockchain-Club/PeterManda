# Peter Manda - Web3 Portfolio - WTC-JSZRJKC9

Johannesburg, South Africa.

I facilitate the blockchain elective at WeThinkCode_, a tuition-free software engineering institute in Johannesburg. Stats SA's Q1 2026 Quarterly Labour Force Survey puts youth unemployment for ages 15-34 at 45.8%, with the 15-24 bracket at 60.9%. The cohort I work with sits inside those numbers. Most are technically capable. What they lack is access to the global market, and tooling that does not assume a Silicon Valley budget.

Co-founder of OffConnectX, building offline blockchain infrastructure for rural African communities on the Lisk blockchain. Cyfrin Updraft Ambassador. Lead researcher at Africa's Blockchain Club.

This repository is a working portfolio of blockchain research, on-chain data science, smart contract development, and education work. Not a collection of slides and notes.

---

## Research Platform - Blockchain Research That Earns

A live Streamlit dashboard that researches a token and the blockchain it lives on, produces an institutional-grade forensic report, and gets paid for it in USDC before a single AI token is spent.

This platform is also the protagonist of the **Exclusive Friday Web3 & AI Workshop series**: every session's topic becomes a working feature, documented after each session in [`sessions/`](sessions/) and in the [Build Journey](research-team/README.md#the-build-journey). Fork the repo and keep pulling - the next feature lands after the next Friday.

**What it does:**

1. Pulls real-time data from DexScreener, CoinGecko, CryptoPanic, DeFiLlama, and CoinGlass
2. Computes liquidity, supply, and risk metrics, with a Kill Switch checklist for structural red flags
3. Gates report generation behind a real on-chain payment: one click connects a browser wallet, sends 1.10 USDC on Base Sepolia, and the platform verifies the transaction on-chain before generating
4. Generates the report with any current Claude model (Haiku through Fable), following the [Blockchain Research Protocol v2.0](research-team/blueprints/blockchain-research-blueprint-v2.0.md) - two scores per report: a Blueprint Score for entry timing and a Long-Term Conviction Score for the 1-5 year chain, protocol, and token outlook
5. Emails the finished report and payment receipt to the payer, and exports to PDF
6. Lets returning payers sign in with their wallet - the address is the account

**Tech stack:** Python · Streamlit · Anthropic SDK · SQLAlchemy · Playwright · Base Sepolia (USDC payments, EIP-1193 wallets)

**Run it locally:**

```bash
cd research-team
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env  # fill in your API keys
streamlit run dashboards/app.py
```

**Architecture:**

```
dashboards/app.py           <- Streamlit UI + payment gate + wallet sign-in
dashboards/wallet_pay/      <- one-click USDC payment component (plain HTML, no build step)
dashboards/wallet_connect/  <- sign-in-with-wallet component
payment_verifier.py         <- on-chain USDC verification (RPC first, explorer fallbacks)
db.py                       <- payments and reports (Postgres or SQLite)
emailer.py                  <- report + receipt delivery over SMTP
tools/report_generator.py   <- pipeline orchestrator (free data stage, paid AI stage)
  data_engineering/
    fetchers.py             <- DexScreener · CoinGecko · CryptoPanic · DeFiLlama · CoinGlass
    screenshot_bot.py       <- Playwright chart captures
  data_analytics/
    metrics.py              <- liquidity turnover · kill-switch flags
  data_science/
    ai_generator.py         <- Claude report generation (model selectable per request)
    anthropic_analyst.py    <- plain-English investment brief
blueprints/                 <- Blockchain Research Protocol (v2.0)
reports/                    <- generated audit reports (markdown + PDF)
x402/                       <- demo: an AI agent that pays for its own data
```

---

## Articles

Published research and education writing:

- [Automated Market Makers (AMMs)](Articles/Automated_Market_Makers_(AMMs).md): how AMM liquidity pools work, with the constant product formula broken down for non-mathematicians
- [Financial Literacy and DeFi](Articles/Financial_Literacy_and_DeFi.md): why DeFi access matters in the African context

Full writing on [Medium](https://medium.com/@petermanda) and [Substack](https://petermanda.substack.com).

---

## Smart Contracts

Sepolia Testnet deployments for the WeThinkCode_ Blockchain Elective contract race - the hands-on artefacts from the smart contracts and security stage of the workshop series ([lesson notes](sessions/session-2-smart-contracts-and-security.md)).

**SessionFaucet:** `0xe225F39BaD67510E1a220785dB95B7d8c434983C`  
**Etherscan:** https://sepolia.etherscan.io/address/0xe225F39BaD67510E1a220785dB95B7d8c434983C

Software engineering prospects interact with `StudentRequest.sol` to request testnet ETH. The facilitator approves or denies each request on-chain during the session.

**Stack:** Solidity 0.8.19 · Foundry · Sepolia Testnet

---

## SDG Projects

Blockchain project ideation aligned to the UN Sustainable Development Goals.

| SDG | Project Area |
|-----|-------------|
| [SDG 1 - No Poverty](sdg/SDG1_No_Poverty/) | Blockchain-based financial inclusion for unbanked communities |
| [SDG 2 - Zero Hunger](sdg/SDG2_Zero_Hunger/) | Supply chain transparency for food distribution |

Each folder contains the project brief, blockchain stack rationale, and implementation notes.

---

## Workshop Sessions

Lesson notes from the Exclusive Friday Web3 & AI Workshop series, written for the cohort and anyone following the repo. Each note covers what the session taught, what feature it added to the research platform, and how to run it yourself. See [`sessions/`](sessions/) - documented after each session runs, so keep pulling.

---

## ABC Fundamentals Exercises

Hands-on exercises from the Africa's Blockchain Club fundamentals track: smart contract patterns, on-chain data analysis, and DeFi protocol interactions.

See [`ABC_Fundamentals_Exercises/`](ABC_Fundamentals_Exercises/).

---

## How I Build With AI

Every project in this repository is built working alongside Claude. [`resources/`](resources/) holds the template versions of the four files that drive that collaboration: identity and voice, writing rules, anti-AI-tells, and a prompting-discipline protocol. Fork the repo, copy each `*.template.md` to its real filename, fill in your own answers, and your fork starts teaching Claude your method instead of mine.

---

## Contact

- LinkedIn: [Peter Manda](https://za.linkedin.com/in/peter-manda-72a48091)
- X: [@LevelsENTPtyLtd](https://x.com/LevelsENTPtyLtd)
- GitHub: [MrPeterManda](https://github.com/MrPeterManda)
- Telegram: [petermanda](https://t.me/petermanda)
- Discord: pmanda19_80129
- Email: peter@wethinkcode.co.za
