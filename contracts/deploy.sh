#!/usr/bin/env bash
# deploy.sh
# Deploy SessionFaucet.sol to Sepolia Testnet.
#
# Run this the NIGHT BEFORE your session.
# Do not deploy live in front of the class.
#
# Usage:
#   cd contracts/
#   bash deploy.sh

set -euo pipefail

# ---- CONFIGURATION ----
MAX_REQUEST_WEI="8000000000000000"    # 0.008 ETH max per student request
FUND_AMOUNT_WEI="50000000000000000"   # 0.05 ETH loaded into the faucet at deploy
# Note: sized for a Sepolia wallet with ~0.105 ETH
# Deploy gas ~0.002 ETH + faucet funding 0.05 ETH + approve gas ~0.005 ETH = ~0.057 ETH total
# Leaves ~0.048 ETH buffer in your wallet
CONTRACT_FILE="SessionFaucet.sol"
CONTRACT_NAME="SessionFaucet"
ENV_FILE=".env.contracts"

# ---- COLOURS ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC}   $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
fail()  { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

echo ""
echo "========================================"
echo "  SessionFaucet - Sepolia Deployment"
echo "========================================"
echo ""

# ---- STEP 1: Foundry check ----
info "Checking Foundry..."
if ! command -v forge &> /dev/null; then
    warn "Foundry not found. Installing now..."
    curl -L https://foundry.paradigm.xyz | bash
    # Try common profile files
    for profile in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
        [ -f "$profile" ] && source "$profile" 2>/dev/null && break
    done
    foundryup
    command -v forge &> /dev/null || fail "Foundry install failed. Visit https://getfoundry.sh and install manually, then re-run this script."
fi
ok "Foundry: $(forge --version | head -1)"

# ---- STEP 2: Environment check ----
info "Checking environment file ($ENV_FILE)..."
if [ ! -f "$ENV_FILE" ]; then
    if [ -f ".env.contracts.example" ]; then
        cp .env.contracts.example "$ENV_FILE"
        fail "Created $ENV_FILE from template. Fill in PRIVATE_KEY and SEPOLIA_RPC_URL then run this script again."
    else
        fail "$ENV_FILE not found. Create it with PRIVATE_KEY and SEPOLIA_RPC_URL."
    fi
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

[ -z "${PRIVATE_KEY:-}" ]    && fail "PRIVATE_KEY is empty in $ENV_FILE"
[ -z "${SEPOLIA_RPC_URL:-}" ] && fail "SEPOLIA_RPC_URL is empty in $ENV_FILE"
ok "Environment loaded"

# ---- STEP 3: Contract file check ----
info "Checking $CONTRACT_FILE..."
[ ! -f "$CONTRACT_FILE" ] && fail "$CONTRACT_FILE not found. Run this script from inside the contracts/ folder."
ok "$CONTRACT_FILE found"

# ---- STEP 4: Compile ----
info "Compiling..."
# Suppress noisy output, only show errors
if ! forge build --root . --contracts . 2>&1; then
    fail "Compilation failed. Fix errors above then re-run."
fi
ok "Compilation passed"

# ---- STEP 5: Deployer wallet and balance ----
info "Checking deployer wallet..."
DEPLOYER=$(cast wallet address --private-key "$PRIVATE_KEY" 2>/dev/null) \
    || fail "Invalid PRIVATE_KEY in $ENV_FILE. Check it is correct."

info "Deployer: $DEPLOYER"
info "Connecting to Sepolia..."

BALANCE_WEI=$(cast balance "$DEPLOYER" --rpc-url "$SEPOLIA_RPC_URL" 2>/dev/null) \
    || fail "Could not connect to Sepolia. Check your SEPOLIA_RPC_URL.\nTry: https://ethereum-sepolia-rpc.publicnode.com"

BALANCE_ETH=$(cast --from-wei "$BALANCE_WEI")
info "Sepolia balance: $BALANCE_ETH ETH"

# Minimum: 0.05 ETH for faucet + ~0.01 ETH buffer for gas
MIN_BALANCE="60000000000000000"
if [ "$(python3 -c "print(1 if int('$BALANCE_WEI') < int('$MIN_BALANCE') else 0)" 2>/dev/null || echo 0)" = "1" ]; then
    warn "Balance is below 0.06 ETH. You need 0.05 ETH for the faucet plus gas."
    warn "Get Sepolia ETH from: https://sepoliafaucet.com"
    echo ""
    read -r -p "Balance may be low. Continue anyway? (y/N): " CONFIRM
    [[ "$CONFIRM" =~ ^[Yy]$ ]] || fail "Cancelled. Top up your Sepolia balance and re-run."
fi

# ---- STEP 6: Deploy ----
echo ""
info "Deploying SessionFaucet..."
info "Max request per student: 0.008 ETH"
info "Faucet funded with: 0.05 ETH"
echo ""

DEPLOY_OUTPUT=$(forge create "$CONTRACT_FILE:$CONTRACT_NAME" \
    --rpc-url "$SEPOLIA_RPC_URL" \
    --private-key "$PRIVATE_KEY" \
    --constructor-args "$MAX_REQUEST_WEI" \
    --value "${FUND_AMOUNT_WEI}wei" \
    --broadcast 2>&1) || {
        echo ""
        echo "$DEPLOY_OUTPUT"
        echo ""
        fail "Deployment transaction failed. See output above."
    }

echo "$DEPLOY_OUTPUT"
echo ""

# ---- STEP 7: Extract address ----
info "Extracting contract address..."

# Primary: grep the "Deployed to:" line
CONTRACT_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep -i "Deployed to:" | awk '{print $NF}' | tr -d '[:space:]')

# Fallback: last 0x address in output
if [ -z "$CONTRACT_ADDRESS" ]; then
    CONTRACT_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep -oE '0x[a-fA-F0-9]{40}' | tail -1)
fi

[ -z "$CONTRACT_ADDRESS" ] && fail "Could not parse contract address from output.\nFind it manually on Etherscan using the transaction hash above.\nSet CONTRACT_ADDRESS in session-info.md manually."

ok "Contract address: $CONTRACT_ADDRESS"

# ---- STEP 8: Verify it is live ----
info "Verifying contract on Sepolia..."
sleep 3  # Give the node a moment to index

FAUCET_BALANCE=$(cast call "$CONTRACT_ADDRESS" "getBalance()(uint256)" \
    --rpc-url "$SEPOLIA_RPC_URL" 2>/dev/null || echo "")

if [ -n "$FAUCET_BALANCE" ] && [ "$FAUCET_BALANCE" != "0" ]; then
    FAUCET_ETH=$(cast --from-wei "$FAUCET_BALANCE")
    ok "Faucet is live. Balance: $FAUCET_ETH ETH"
else
    warn "Balance check returned zero or timed out."
    warn "Check Etherscan manually: https://sepolia.etherscan.io/address/$CONTRACT_ADDRESS"
    warn "If the transaction confirmed, the contract is fine."
fi

# ---- STEP 9: Write to files ----
info "Writing address to files..."

echo "$CONTRACT_ADDRESS" > deployed_address.txt
ok "deployed_address.txt written"

TIMESTAMP=$(date '+%d %B %Y %H:%M %Z')

cat > session-info.md << SESSIONEOF
# Session 3 - Contract Race

Deployed: $TIMESTAMP
Network: Sepolia Testnet
Deployer: $DEPLOYER

## Contract

Address: \`$CONTRACT_ADDRESS\`
Etherscan: https://sepolia.etherscan.io/address/$CONTRACT_ADDRESS
Max per request: 0.008 ETH
Initial balance: 0.05 ETH

## What to put in Slide 5

Faucet address: $CONTRACT_ADDRESS

Paste this into slide 5 on the day. Keep the Etherscan events tab open
in a browser tab during the session so you can see incoming requests.

## Cast Commands for the Session

Check faucet balance:
\`\`\`bash
cast call $CONTRACT_ADDRESS "getBalance()(uint256)" --rpc-url \$SEPOLIA_RPC_URL | cast --from-wei
\`\`\`

Approve a student contract (paste their contract address):
\`\`\`bash
cast send $CONTRACT_ADDRESS "approve(address)" STUDENT_CONTRACT_ADDRESS --private-key \$PRIVATE_KEY --rpc-url \$SEPOLIA_RPC_URL
\`\`\`

Pause requests mid-session if needed:
\`\`\`bash
cast send $CONTRACT_ADDRESS "setPaused(bool)" true --private-key \$PRIVATE_KEY --rpc-url \$SEPOLIA_RPC_URL
\`\`\`

Unpause:
\`\`\`bash
cast send $CONTRACT_ADDRESS "setPaused(bool)" false --private-key \$PRIVATE_KEY --rpc-url \$SEPOLIA_RPC_URL
\`\`\`

Withdraw remaining ETH after the session:
\`\`\`bash
cast send $CONTRACT_ADDRESS "withdraw()" --private-key \$PRIVATE_KEY --rpc-url \$SEPOLIA_RPC_URL
\`\`\`
SESSIONEOF

ok "session-info.md written"

# Update README placeholder if present
if [ -f "../README.md" ] && grep -q "PENDING_DEPLOYMENT" ../README.md 2>/dev/null; then
    sed -i "s|PENDING_DEPLOYMENT|$CONTRACT_ADDRESS|g" ../README.md
    ok "README.md updated"
fi

# ---- STEP 10: Etherscan verification (optional) ----
if [ -n "${ETHERSCAN_API_KEY:-}" ]; then
    info "Verifying source on Etherscan (this takes 30-60 seconds)..."
    CONSTRUCTOR_ARGS=$(cast abi-encode "constructor(uint256)" "$MAX_REQUEST_WEI" 2>/dev/null || echo "")
    if forge verify-contract \
        --chain sepolia \
        --etherscan-api-key "$ETHERSCAN_API_KEY" \
        ${CONSTRUCTOR_ARGS:+--constructor-args "$CONSTRUCTOR_ARGS"} \
        "$CONTRACT_ADDRESS" \
        "$CONTRACT_FILE:$CONTRACT_NAME" 2>&1; then
        ok "Source verified on Etherscan"
    else
        warn "Etherscan verification failed. Contract still works."
    fi
else
    warn "No ETHERSCAN_API_KEY - skipping source verification."
    warn "Get a free key at https://etherscan.io/myapikey to show students the source."
fi

# ---- DONE ----
echo ""
echo "========================================"
echo -e "${GREEN}  DEPLOYMENT COMPLETE${NC}"
echo "========================================"
echo ""
echo -e "  Address : ${GREEN}$CONTRACT_ADDRESS${NC}"
echo ""
echo "  Etherscan:"
echo "  https://sepolia.etherscan.io/address/$CONTRACT_ADDRESS"
echo ""
echo "  Files written:"
echo "  - deployed_address.txt"
echo "  - session-info.md"
echo ""
echo "  Next:"
echo "  1. Open the Etherscan link and confirm the contract tab appears"
echo "  2. Copy the address into slide 5"
echo "  3. Run pre_session_check.sh 30 minutes before the session"
echo ""
