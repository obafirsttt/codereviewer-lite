#!/usr/bin/env bash
# Creates a v1.0.0 GitHub Release (the "Publicist" achievement).
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/_common.sh"

require_auth
REPO="$(detect_repo)"
info "Using repo: $REPO"

TAG="v1.0.0"

if gh release view "$TAG" --repo "$REPO" >/dev/null 2>&1; then
  warn "Release $TAG already exists. Using a timestamped tag instead."
  TAG="v1.0.0-$TS"
fi

info "Tagging $TAG..."
git tag "$TAG"
git push origin "$TAG"

info "Creating GitHub Release..."
RELEASE_URL="$(gh release create "$TAG" --repo "$REPO" --title "Release $TAG" --notes "Automated release created by scripts/publicist.sh" --generate-notes)"
ok "Release created: $RELEASE_URL"
ok "Publicist achievement conditions met!"
ok "Check your profile: $(profile_url)"
