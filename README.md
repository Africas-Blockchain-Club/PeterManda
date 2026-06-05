# Peter Manda — Blockchain Research & Education Portfolio

Johannesburg, South Africa. Co-founder of OffConnectX. Lead Facilitator at WeThinkCode_. Cyfrin Updraft Ambassador.

This repository is a working portfolio of blockchain research, on-chain data science, smart contract development, and education work — not a collection of slides and notes.

---

## Research Platform — Token Forensic Analysis

A live Streamlit dashboard that generates institutional-grade token audit reports.

**What it does:**

1. Pulls real-time data from DexScreener, CoinGecko, CryptoPanic, DefiLlama, and Coinglass
2. Computes liquidity, supply, and risk metrics (Blueprint Score 0–100)
3. Runs three competing AI models (Gemini 2.5 Flash, Llama 4 Maverick, Qwen3-32B) — saves the highest-scoring report
4. Generates a plain-English investment brief using the Anthropic API (Claude Haiku / Sonnet)
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
dashboards/app.py           ← Streamlit UI
tools/report_generator.py   ← pipeline orchestrator (log_fn callback for live updates)
  data_engineering/
    fetchers.py             ← DexScreener · CoinGecko · CryptoPanic · DefiLlama · Coinglass
    screenshot_bot.py       ← Playwright chart captures
  data_analytics/
    metrics.py              ← liquidity turnover · kill-switch flags
  data_science/
    ai_generator.py         ← multi-model competition (Gemini · Groq)
    anthropic_analyst.py    ← plain-English brief (Haiku default · Sonnet on demand)
blueprints/                 ← token analysis framework (v1.0)
reports/                    ← generated audit reports (markdown + PDF)
```

---

## Articles

Published research and education writing:

- [Automated Market Makers (AMMs)](Articles/Automated_Market_Makers_(AMMs).md) — how AMM liquidity pools work, with the constant product formula broken down for non-mathematicians
- [Financial Literacy and DeFi](Articles/Financial_Literacy_and_DeFi.md) — why DeFi access matters in the African context

Full writing on [Medium](https://medium.com/@petermanda) and [Substack](https://petermanda.substack.com).

---

## Smart Contracts

Session 3 — Sepolia Testnet deployment for the WeThinkCode_ Blockchain Elective contract race.

**SessionFaucet:** `0xe225F39BaD67510E1a220785dB95B7d8c434983C`  
**Etherscan:** https://sepolia.etherscan.io/address/0xe225F39BaD67510E1a220785dB95B7d8c434983C

Students interact with `StudentRequest.sol` to request testnet ETH. The facilitator approves or denies each request on-chain during the session.

**Stack:** Solidity 0.8.19 · Foundry · Sepolia Testnet

---

## SDG Projects

Blockchain project ideation aligned to the UN Sustainable Development Goals.

| SDG | Project Area |
|-----|-------------|
| [SDG 1 — No Poverty](SDG1_No_Poverty/) | Blockchain-based financial inclusion for unbanked communities |
| [SDG 2 — Zero Hunger](SDG2_Zero_Hunger/) | Supply chain transparency for food distribution |

Each folder contains the project brief, blockchain stack rationale, and implementation notes.

---

## ABC Fundamentals Exercises

Hands-on exercises from the Africa's Blockchain Club fundamentals track — smart contract patterns, on-chain data analysis, and DeFi protocol interactions.

See [`ABC_Fundamentals_Exercises/`](ABC_Fundamentals_Exercises/).

---

## Contact

- LinkedIn: [Peter Manda](https://www.linkedin.com/in/peter-manda)
- X: [@PeterManda_](https://x.com/PeterManda_)
- Email: peter@wethinkcode.co.za
