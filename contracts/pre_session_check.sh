#!/usr/bin/env bash
# pre_session_check.sh
# Run this 30 minutes before Session 3.
# It confirms the faucet is live, funded, and ready.
#
# Usage:
#   cd contracts/
#   bash pre_session_check.sh

set -euo pipefail

ENV_FILE=".env.contracts"
DEPLOYED_FILE="deployed_address.txt"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; FAILED=1; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
info() { echo -e "${BLUE}[CHECK]${NC} $1"; }

FAILED=0

echo ""
echo "========================================"
echo "  Pre-Session Check - Session 3"
echo "========================================"
echo ""

# ---- Check 1: Environment ----
info "Environment file..."
if [ ! -f "$ENV_FILE" ]; then
    fail "$ENV_FILE not found. Run deploy.sh first."
else
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
    ok "Environment loaded"
fi

# ---- Check 2: Deployed address on file ----
info "Deployed address..."
if [ ! -f "$DEPLOYED_FILE" ]; then
    fail "deployed_address.txt not found. Run deploy.sh first."
else
    CONTRACT_ADDRESS=$(cat "$DEPLOYED_FILE" | tr -d '[:space:]')
    ok "Address: $CONTRACT_ADDRESS"
fi

# ---- Check 3: Foundry ----
info "Foundry (cast)..."
command -v cast &> /dev/null && ok "cast available" || fail "cast not found. Run deploy.sh to install Foundry."

# ---- Check 4: RPC connection ----
info "Sepolia RPC connection..."
if cast block latest --rpc-url "${SEPOLIA_RPC_URL:-}" &> /dev/null; then
    ok "Connected to Sepolia"
else
    fail "Cannot connect to Sepolia. Check SEPOLIA_RPC_URL in $ENV_FILE."
fi

# ---- Check 5: Faucet is live ----
info "Faucet contract is live..."
FAUCET_BALANCE=$(cast call "$CONTRACT_ADDRESS" "getBalance()(uint256)" \
    --rpc-url "${SEPOLIA_RPC_URL:-}" 2>/dev/null || echo "")

if [ -z "$FAUCET_BALANCE" ]; then
    fail "Could not reach faucet at $CONTRACT_ADDRESS. Contract may not be deployed."
else
    ok "Faucet responds"
fi

# ---- Check 6: Faucet has ETH ----
info "Faucet balance..."
if [ -n "$FAUCET_BALANCE" ] && [ "$FAUCET_BALANCE" != "0" ]; then
    FAUCET_ETH=$(cast --from-wei "$FAUCET_BALANCE")
    ok "Faucet balance: $FAUCET_ETH ETH"
    # Warn if low
    if python3 -c "exit(0 if float('$FAUCET_ETH') >= 0.1 else 1)" 2>/dev/null; then
        ok "Balance sufficient for session"
    else
        warn "Balance is below 0.1 ETH. May not be enough for all students."
        warn "Top up via MetaMask: send Sepolia ETH directly to $CONTRACT_ADDRESS"
    fi
else
    fail "Faucet balance is zero. Send Sepolia ETH to $CONTRACT_ADDRESS before the session."
fi

# ---- Check 7: Paused status ----
info "Pause status..."
PAUSED=$(cast call "$CONTRACT_ADDRESS" "paused()(bool)" \
    --rpc-url "${SEPOLIA_RPC_URL:-}" 2>/dev/null || echo "unknown")

if [ "$PAUSED" = "false" ]; then
    ok "Faucet is open - students can request"
elif [ "$PAUSED" = "true" ]; then
    warn "Faucet is currently PAUSED. Students cannot request until you unpause."
    warn "To unpause:"
    warn "  cast send $CONTRACT_ADDRESS \"setPaused(bool)\" false --private-key \$PRIVATE_KEY --rpc-url \$SEPOLIA_RPC_URL"
else
    warn "Could not determine pause status. Check Etherscan."
fi

# ---- Summary ----
echo ""
echo "========================================"
if [ "$FAILED" = "0" ]; then
    echo -e "${GREEN}  ALL CHECKS PASSED${NC}"
    echo ""
    echo "  Faucet: $CONTRACT_ADDRESS"
    echo "  Etherscan events tab (keep open during session):"
    echo "  https://sepolia.etherscan.io/address/$CONTRACT_ADDRESS#events"
    echo ""
    echo "  You are ready. Start the session."
else
    echo -e "${RED}  CHECKS FAILED - DO NOT START UNTIL RESOLVED${NC}"
    echo ""
    echo "  Fix the failures above and run this script again."
fi
echo "========================================"
echo ""
