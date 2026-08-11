#!/usr/bin/env bash
# Shared helpers sourced by the other scripts/*.sh in this repo.
set -euo pipefail

TS="$(date +%Y%m%d-%H%M%S)"

color() { local c="$1"; shift; printf "\033[%sm%s\033[0m\n" "$c" "$*"; }
info()  { color "1;34" "ℹ $*"; }
ok()    { color "1;32" "✔ $*"; }
warn()  { color "1;33" "⚠ $*"; }
fail()  { color "1;31" "✘ $*"; exit 1; }

require_gh() {
  if ! command -v gh >/dev/null 2>&1; then
    fail "GitHub CLI (gh) is not installed. Install it: https://cli.github.com/ then re-run this script."
  fi
}

require_auth() {
  require_gh
  if ! gh auth status >/dev/null 2>&1; then
    fail "You're not logged into GitHub CLI. Fix it with: gh auth login   (then re-run this script)"
  fi
}

detect_repo() {
  require_auth
  if ! REPO_SLUG="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)"; then
    fail "Could not auto-detect the repo. Run this from inside a git repo that's pushed to GitHub, or run: gh repo set-default"
  fi
  echo "$REPO_SLUG"
}

profile_url() {
  local user
  user="$(gh api user -q .login 2>/dev/null || echo "")"
  if [ -n "$user" ]; then
    echo "https://github.com/$user"
  else
    echo "https://github.com/settings/profile"
  fi
}
