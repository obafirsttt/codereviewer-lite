#!/usr/bin/env bash
# Creates a branch, opens a PR, and merges it without review (the "YOLO" achievement).
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/_common.sh"

require_auth
REPO="$(detect_repo)"
info "Using repo: $REPO"

BRANCH="yolo/$TS"
FILE="YOLO_${TS}.md"

info "Creating branch $BRANCH..."
git checkout -b "$BRANCH"

echo "# YOLO merge log" > "$FILE"
echo "Created by scripts/yolo.sh at $TS" >> "$FILE"
git add "$FILE"
git commit -m "chore: yolo merge marker ($TS)"

info "Pushing branch..."
git push -u origin "$BRANCH"

info "Opening PR..."
PR_URL="$(gh pr create --repo "$REPO" --title "YOLO merge ($TS)" --body "Automated PR from scripts/yolo.sh." --head "$BRANCH" --base main)"
ok "PR opened: $PR_URL"

info "Merging without review (--admin, squash)..."
gh pr merge "$PR_URL" --repo "$REPO" --squash --admin --delete-branch

ok "PR merged without review. YOLO achievement conditions met!"
ok "Check your profile: $(profile_url)"
