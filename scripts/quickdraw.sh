#!/usr/bin/env bash
# Opens and closes a GitHub issue in under 5 minutes (the "Quickdraw" achievement).
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/_common.sh"

require_auth
REPO="$(detect_repo)"
info "Using repo: $REPO"

TITLE="Quickdraw test issue ($TS)"
BODY="Automated issue created by scripts/quickdraw.sh to trigger the Quickdraw achievement. Safe to ignore/delete."

info "Opening issue..."
ISSUE_URL="$(gh issue create --repo "$REPO" --title "$TITLE" --body "$BODY")"
ok "Issue opened: $ISSUE_URL"

sleep 2

info "Closing issue..."
gh issue close "$ISSUE_URL" --repo "$REPO" --comment "Closing immediately — quickdraw achievement script." >/dev/null

ok "Issue closed within seconds of opening. Quickdraw conditions met!"
ok "Check your profile: $(profile_url)"
