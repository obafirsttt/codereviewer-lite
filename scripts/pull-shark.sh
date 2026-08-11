#!/usr/bin/env bash
# Opens and merges N pull requests. 2 = Bronze, 16 = Silver, 128 = Gold Pull Shark.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/_common.sh"

COUNT="${1:-2}"

case "$COUNT" in
  2)   TIER="Bronze" ;;
  16)  TIER="Silver" ;;
  128) TIER="Gold" ;;
  *)   TIER="Custom ($COUNT)" ;;
esac

require_auth
REPO="$(detect_repo)"
info "Using repo: $REPO"
info "Opening and merging $COUNT PR(s) for Pull Shark tier: $TIER"

for i in $(seq 1 "$COUNT"); do
  BRANCH="pull-shark/${TS}-${i}"
  FILE="pull_shark_${TS}_${i}.md"

  git checkout main >/dev/null 2>&1 || true
  git pull >/dev/null 2>&1 || true
  git checkout -b "$BRANCH"

  echo "# Pull Shark PR #$i" > "$FILE"
  echo "Generated at $TS" >> "$FILE"
  git add "$FILE"
  git commit -m "chore: pull shark PR $i/$COUNT ($TS)"
  git push -u origin "$BRANCH"

  PR_URL="$(gh pr create --repo "$REPO" --title "Pull Shark PR $i/$COUNT ($TS)" --body "Automated PR $i of $COUNT from scripts/pull-shark.sh" --head "$BRANCH" --base main)"
  gh pr merge "$PR_URL" --repo "$REPO" --squash --admin --delete-branch

  ok "[$i/$COUNT] Merged: $PR_URL"
done

git checkout main >/dev/null 2>&1 || true
ok "Completed $COUNT merged PRs — Pull Shark ($TIER) conditions met!"
ok "Check your profile: $(profile_url)"
