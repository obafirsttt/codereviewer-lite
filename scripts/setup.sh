#!/usr/bin/env bash
# Checks dependencies and makes all scripts executable.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/_common.sh"

info "Checking dependencies for codereviewer-lite..."

MISSING=0

check() {
  local name="$1" cmd="$2" hint="$3"
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$name found ($(command -v "$cmd"))"
  else
    warn "$name NOT found. $hint"
    MISSING=1
  fi
}

check "Node.js" node "Install from https://nodejs.org/ (v20+ recommended)"
check "npm" npm "Comes bundled with Node.js"
check "git" git "Install from https://git-scm.com/downloads"
check "GitHub CLI" gh "Install from https://cli.github.com/"

if command -v gh >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then
    ok "GitHub CLI is authenticated"
  else
    warn "GitHub CLI is installed but not authenticated. Fix it with: gh auth login"
  fi
fi

info "Making scripts/*.sh executable..."
chmod +x "$DIR"/*.sh
ok "All scripts are now executable."

if [ "$MISSING" -eq 1 ]; then
  warn "Some dependencies are missing — install them above, then re-run: bash scripts/setup.sh"
  exit 1
fi

ok "Setup complete! Try: npm install && npm test"
