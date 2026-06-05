# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Read First — Always

Before writing any text (copy, comments, README content, UI strings), read all four files in `/resources/`:

- `resources/about-me.md` — identity and authority context
- `resources/my_writing_style.md` — universal voice rules, banned words, platform rules
- `resources/anti-ai-writing-style.md` — patterns to eliminate from all output
- `resources/cant_prompt_blindly.md` — prompting discipline

Apply them without announcing it. British English, no contractions, no em dashes, no banned words. See `resources/my_writing_style.md` for the full self-check list.

---

## Repository Overview

Peter Manda's blockchain research and project repository. Two main active areas:

- **`research-team/`** — AI-powered token forensic audit platform (Streamlit + Python)
- **`contracts/`** — Solidity smart contracts for teaching sessions (Foundry)

Supporting content: `Articles/`, `SDG1_No_Poverty/`, `SDG2_Zero_Hunger/`, `ABC_Fundamentals_Exercises/`

---

## research-team — Commands

```bash
cd research-team
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt

# System dependencies (Linux/WSL — one-time)
sudo apt-get install -y libcairo2-dev pkg-config python3-dev

# Start the dashboard
streamlit run dashboards/app.py
# Opens at http://localhost:8501
```

**Required `.env`** (in `research-team/`):
```
OPENROUTER_API_KEY=sk-or-...
GOOGLE_API_KEY=AIza...
GROQ_API_KEY=gsk_...
COINGLASS_API_KEY=...   # optional
```

---

## research-team — Architecture

The platform is a four-stage pipeline triggered from the Streamlit dashboard or directly via `tools/report_generator.py`:

```
dashboards/app.py  (Streamlit UI)
       │
       └─► tools/report_generator.py  (orchestrator — calls all three layers)
                │
                ├─► data_engineering/fetchers.py       — DexScreener, CoinGecko, CoinMarketCap,
                │                                        DeFiLlama, CoinGlass, DuckDuckGo search
                ├─► data_engineering/screenshot_bot.py — Playwright chart screenshots
                ├─► data_analytics/metrics.py          — liquidity turnover, kill-switch flags
                └─► data_science/ai_generator.py       — AI prompt + multi-model runner
```

**Multi-model competition**: `report_generator.py` runs all three models in parallel, extracts the Blueprint Score (0–100) from each report, and saves only the highest-scoring result. Models: `google/gemini-2.5-flash`, `groq/llama-4-maverick`, `groq/qwen3-32b`.

**Report output**: saved as `reports/{TOKEN}_audit_report.md` with a YAML metadata header (`Token`, `Score`, `Verdict`, `Screenshot`) that the dashboard reads without regex-scanning the full body.

**Blueprint**: `blueprints/token-analysis-blueprint-v1.0.md` defines the five-phase forensic report structure. The AI system prompt in `data_science/ai_generator.py` enforces it exactly — phase headings must not be renamed or the tab parser breaks.

**Adding a new token type or task**: create `blueprints/new-task-blueprint-v1.0.md` following the existing structure. No code changes needed; the dashboard auto-detects blueprints and reports.

---

## contracts — Commands

```bash
# Check Foundry
forge --version
# Install if missing:
curl -L https://foundry.paradigm.xyz | bash && source ~/.bashrc && foundryup

# Compile (from contracts/ directory)
forge build --root . --contracts .

# Deploy to Sepolia
cd contracts/
bash deploy.sh
```

**Required `contracts/.env.contracts`** (copy from `.env.contracts.example`):
```
PRIVATE_KEY=0x...
SEPOLIA_RPC_URL=https://...
```

**Note**: `.sol.txt` files in `contracts/` are Windows-renamed Solidity files. Rename them before compiling:
```bash
for f in contracts/*_sol.txt; do
    [ -f "$f" ] && mv "$f" "contracts/$(basename "$f" _sol.txt).sol"
done
```

---

## Code Conventions

- Python: `snake_case` for variables and functions
- All secrets in `.env`; never hardcoded
- Comments explain the why, not the what
- Plain text markdown only — no LaTeX (`\frac`, `$$ $$`) anywhere; PDF rendering breaks
- Currency values in reports: USD with ZAR equivalent in brackets
