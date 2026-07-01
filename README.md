# Peter Manda - Web3 Portfolio

Johannesburg, South Africa.

I facilitate the blockchain elective at WeThinkCode_, a tuition-free software engineering institute in Johannesburg. Stats SA's Q1 2026 Quarterly Labour Force Survey puts youth unemployment for ages 15-34 at 45.8%, with the 15-24 bracket at 60.9%. The cohort I work with sits inside those numbers. Most are technically capable. What they lack is access to the global market, and tooling that does not assume a Silicon Valley budget.

Co-founder of OffConnectX, building offline blockchain infrastructure for rural African communities on the Lisk blockchain. Cyfrin Updraft Ambassador. Lead researcher at Africa's Blockchain Club.

This repository is a working portfolio of blockchain research, on-chain data science, smart contract development, and education work. Not a collection of slides and notes.

---

## Research Platform - Token Forensic Analysis

A live Streamlit dashboard that generates institutional-grade token audit reports.

**What it does:**

1. Pulls real-time data from DexScreener, CoinGecko, Google News RSS, DefiLlama, and Coinglass
2. Computes liquidity, supply, and risk metrics (Blueprint Score 0-100)
3. Runs three competing AI models (Gemini 2.5 Flash, Llama 4 Maverick, Qwen3-32B) and saves the highest-scoring report
4. Generates a plain-English investment brief using the Anthropic API (Haiku / Sonnet)
5. Exports any report to PDF

**Tech stack:** Python · Streamlit · Anthropic SDK · Google Gemini API · Groq API · Playwright

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
dashboards/app.py           <- Streamlit UI
tools/report_generator.py   <- pipeline orchestrator (log_fn callback for live updates)
  data_engineering/
    fetchers.py             <- DexScreener · CoinGecko · Google News RSS · DefiLlama · Coinglass
    screenshot_bot.py       <- Playwright chart captures
  data_analytics/
    metrics.py              <- liquidity turnover · kill-switch flags
  data_science/
    ai_generator.py         <- multi-model competition (Gemini · Groq)
    anthropic_analyst.py    <- plain-English brief (Haiku default · Sonnet on demand)
blueprints/                 <- token analysis framework (v1.0)
reports/                    <- generated audit reports (markdown + PDF)
```

---

## Articles

Published research and education writing:

- [Automated Market Makers (AMMs)](Articles/Automated_Market_Makers_(AMMs).md): how AMM liquidity pools work, with the constant product formula broken down for non-mathematicians
- [Financial Literacy and DeFi](Articles/Financial_Literacy_and_DeFi.md): why DeFi access matters in the African context

Full writing on [Medium](https://medium.com/@petermanda) and [Substack](https://petermanda.substack.com).

---

## Smart Contracts

Session 3 - Sepolia Testnet deployment for the WeThinkCode_ Blockchain Elective contract race.

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
