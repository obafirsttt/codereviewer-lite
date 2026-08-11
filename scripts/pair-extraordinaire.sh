#!/usr/bin/env bash
# Creates a co-authored, merged PR (the "Pair Extraordinaire" achievement).
# Usage: scripts/pair-extraordinaire.sh "Name" "email@example.com"
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/_common.sh"

NAME="${1:-}"
EMAIL="${2:-}"

if [ -z "$NAME" ] || [ -z "$EMAIL" ]; then
  fail 'Usage: scripts/pair-extraordinaire.sh "Name" "email@example.com"'
fi

require_auth
REPO="$(detect_repo)"
info "Using repo: $REPO"

BRANCH="pair/$TS"
FILE="PAIR_${TS}.md"

git checkout -b "$BRANCH"
echo "# Pair Extraordinaire" > "$FILE"
echo "Co-authored with $NAME <$EMAIL> at $TS" >> "$FILE"
git add "$FILE"

git commit -m "chore: pair programming session ($TS)

Co-authored-by: $NAME <$EMAIL>"

git push -u origin "$BRANCH"

PR_URL="$(gh pr create --repo "$REPO" --title "Pair session with $NAME ($TS)" --body "Co-authored-by: $NAME <$EMAIL>" --head "$BRANCH" --base main)"
ok "PR opened: $PR_URL"

gh pr merge "$PR_URL" --repo "$REPO" --squash --admin --delete-branch

ok "Co-authored PR merged with $NAME <$EMAIL>. Pair Extraordinaire conditions met!"
ok "Check your profile: $(profile_url)"
