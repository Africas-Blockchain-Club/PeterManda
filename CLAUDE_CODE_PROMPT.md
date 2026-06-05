# Claude Code Instructions: PeterManda Web3 Journey Repo

## STEP 0 — READ THIS FIRST. NO EXCEPTIONS.

Before you read any other file in this repository, open and read all four files
in the `/resources` folder at the root of the repo:

- `/resources/about-me.md`
- `/resources/my_writing_style.md`
- `/resources/anti-ai-writing-style.md`
- `/resources/cant_prompt_blindly.md`

Apply everything in those files to every piece of text you write in this codebase:
comments, README text, error messages, UI copy, variable names where naming
reflects intent, and any documentation. Do not announce that you have read them.
Just apply them.

---
## STEP 0.5 — FIX CONTRACT FILE EXTENSIONS

Before doing anything else in the contracts folder, check for any files that
were saved as text documents instead of Solidity files.

Run this from the repo root:

```bash
for f in contracts/*_sol.txt; do
    [ -f "$f" ] && mv "$f" "contracts/$(basename "$f" _sol.txt).sol" && echo "Renamed: $f"
done
```

Also check if any .sol files are present but empty:

```bash
for f in contracts/*.sol; do
    [ -f "$f" ] && [ ! -s "$f" ] && echo "WARNING: $f is empty"
done
```

If any .sol file is empty, ask Peter to re-download the _sol.txt version and rename it.

Note: Windows labels .sol files as "Text Document" because it does not recognise
the extension. This is cosmetic. Remix and Foundry compile them correctly.

---


## REPO STRUCTURE

```
PeterManda/
├── resources/              # Read first. Always.
│   ├── about-me.md
│   ├── my_writing_style.md
│   ├── anti-ai-writing-style.md
│   └── cant_prompt_blindly.md
├── research-team/          # The token analysis platform. Your work area.
├── ABC_Fundamentals_Exercises/
├── Articles/
├── SDG1_No_Poverty/
├── SDG2_Zero_Hunger/
├── README.md
└── LICENSE
```

---

## YOUR TASK — THREE PHASES

Work through these phases in order. Do not skip to the next phase until the
current one is done and reported.

---

### PHASE 1: ANALYSE (read and report before writing any code)

Map the `research-team/` directory. For every file and folder, write one sentence
describing what it does or what it appears to do.

Then answer these four questions:

1. What is the tech stack? Is this a Streamlit app, Flask app, React frontend,
   CLI tool, or Python scripts that print to terminal?
2. What is the entry point? Which file do you run to start the platform?
3. What is the data flow? Where does token data come in, how is it processed,
   and what does the output look like right now?
4. What is broken or incomplete?

Report all of this in plain text. Do not change any files yet.

---

### PHASE 2: PLAN (propose before touching anything)

Based on Phase 1, write a short plan covering:

- Whether the current structure should stay or be refactored
- Where the Anthropic API integration should sit (which file, which function)
- What the AI layer will do: take the existing token analysis output as input,
  return a plain-English investment brief using the voice in `/resources/about-me.md`
- How the platform will load the resources files into the model system prompt

State the plan. Wait for confirmation before moving to Phase 3.

---

### PHASE 3: INTEGRATE ANTHROPIC API

Add an AI analysis layer to the platform using the Anthropic Python SDK.

**Model rules:**
- Default model: `claude-haiku-4-5`
- Escalation model: `claude-sonnet-4-6` — only when the user explicitly
  requests a deep analysis. Never escalate automatically.
- API key: loaded from environment variable `ANTHROPIC_API_KEY`. Never hardcode it.
- max_tokens: 1024 for Haiku, 2048 for Sonnet

**System prompt rules:**
Every API call must load the content of all four `/resources` files and pass
them as the system prompt. The AI output must sound like it was written by
the person described in `about-me.md`, not like a generic chatbot response.
Apply the anti-AI writing rules from `anti-ai-writing-style.md` to the
instructions you give the model.

**Cost tracking:**
After each API call, log the following to `/research-team/usage_log.txt`:
```
[timestamp] model=<model> input_tokens=<n> output_tokens=<n> est_cost_usd=<x>
```

Use these rates for estimates:
- Haiku: $0.00000025 per input token, $0.00000125 per output token
- Sonnet: $0.000003 per input token, $0.000015 per output token

---

### PHASE 4: MAKE THE DEMO INTERACTIVE

The platform will be used in a live teaching session with software engineering
prospects. The flow must be simple enough to run in front of a room:

1. User enters a token name or contract address
2. Platform fetches data using the existing pipeline
3. The Anthropic model analyses the data and returns a plain-English brief
4. Brief is displayed clearly — not as a wall of text, not as a JSON dump
5. A "deep analysis" button or command escalates to Sonnet for that query only
6. Show the estimated cost of the current query somewhere on the output

Do not redesign the entire platform. Add the AI layer on top of what already
works. Preserve existing functionality.

---

## RULES — NON-NEGOTIABLE

**Language:**
- British English in all user-facing text
- No contractions in any copy or comments
- No em dashes — use hyphens or semi-colons
- No AI filler: no "dive into," "leverage," "cutting-edge," "it is worth noting,"
  "navigate," "unleash," "game-changer"
- Write for clarity, not for impressiveness

**Code:**
- Python: snake_case for variables and functions
- Comments explain the why, not the what
- No hardcoded secrets — everything sensitive goes in `.env`
- Add a `.env.example` file so anyone can set up the project

**Output files after Phase 4 is complete:**
- `/research-team/README.md` — updated with how to run the platform,
  how to set the API key, and what the platform does
- `/research-team/requirements.txt` — updated to include `anthropic`
- `/research-team/.env.example` — shows required environment variables
- `/research-team/usage_log.txt` — created on first run if it does not exist
- A working demo that runs with `python main.py` or the equivalent entry point

---

## IF SOMETHING IS UNCLEAR

Read Phase 1 output again before asking a question. Most questions are answered
by the codebase itself. If you still need clarification after re-reading, ask
one specific question — not a list of five.

---

## PHASE 5: DEPLOY SESSION FAUCET

This phase deploys `contracts/SessionFaucet.sol` to Sepolia Testnet.
Run this phase separately from Phases 1-4. It touches the blockchain.

### Step 1 - Organise the contracts folder

Create a `contracts/` folder at the root of the repo if it does not exist.
Copy these files into it:
- `SessionFaucet.sol`
- `StudentRequest.sol`
- `foundry.toml`
- `.env.contracts.example`
- `deploy.sh`
- `pre_session_check.sh`
- `README.md` (the contracts README, not the repo root README)

### Step 2 - Check Foundry

Run: `forge --version`

If Foundry is not installed:
```bash
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc
foundryup
```

Verify with `forge --version` again before continuing.

### Step 3 - Check environment

Check if `contracts/.env.contracts` exists.
If not, copy from `contracts/.env.contracts.example` and stop.
Tell Peter to fill in PRIVATE_KEY and SEPOLIA_RPC_URL then run Phase 5 again.

If it exists, confirm PRIVATE_KEY and SEPOLIA_RPC_URL are not empty.

### Step 4 - Compile

Run from the `contracts/` directory:
```bash
forge build --root . --contracts .
```

If compilation fails, fix the error. Do not continue until compilation passes.

### Step 5 - Run the deployment script

```bash
cd contracts/
bash deploy.sh
```

This script handles everything: balance check, deploy, address capture, file writes.
Read its output carefully. If it fails, read the error message - it tells you exactly
what to fix.

### Step 6 - Confirm files were written

After deploy.sh completes, confirm these files exist in `contracts/`:
- `deployed_address.txt` - one line, just the address
- `session-info.md` - full session info including cast commands

If either file is missing, check the deploy.sh output for the contract address
and write `deployed_address.txt` manually.

### Step 7 - Update repo README

In the repo root `README.md`, find or add a Session 3 section.
Write the contract address and the Etherscan link there.
Format:
```
## Session 3 - Contract Race

Faucet: `<address>`
Etherscan: https://sepolia.etherscan.io/address/<address>
```

### Step 8 - Report back

When Phase 5 is done, report:
- The contract address
- The Etherscan link
- The faucet balance (from deploy.sh output)
- Which files were written

Do not mark Phase 5 complete until you have confirmed the contract address
is in `deployed_address.txt`, `session-info.md`, and the root `README.md`.
