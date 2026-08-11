#!/usr/bin/env bash
# Interactive menu to run any (or all, "Full Blast") of the achievement scripts.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/_common.sh"

print_menu() {
  echo ""
  color "1;36" "==================================================="
  color "1;36" "  codereviewer-lite — Achievement Unlock Menu"
  color "1;36" "==================================================="
  echo "  1) Quickdraw            (scripts/quickdraw.sh)"
  echo "  2) YOLO                 (scripts/yolo.sh)"
  echo "  3) Publicist             (scripts/publicist.sh)"
  echo "  4) Pull Shark - Bronze   (scripts/pull-shark.sh 2)"
  echo "  5) Pull Shark - Silver   (scripts/pull-shark.sh 16)"
  echo "  6) Pull Shark - Gold     (scripts/pull-shark.sh 128)"
  echo "  7) Pair Extraordinaire   (scripts/pair-extraordinaire.sh)"
  echo "  8) Full Blast            (run everything above, Bronze tier for Pull Shark)"
  echo "  9) Track progress        (npm run tracker)"
  echo "  0) Exit"
  echo ""
}

run_pair() {
  read -rp "Co-author name: " pname
  read -rp "Co-author email: " pemail
  bash "$DIR/pair-extraordinaire.sh" "$pname" "$pemail"
}

full_blast() {
  warn "Full Blast will run quickdraw, yolo, publicist, pull-shark (Bronze), and prompt for a pair session."
  read -rp "Continue? [y/N] " confirm
  [ "$confirm" = "y" ] || [ "$confirm" = "Y" ] || { warn "Cancelled."; return; }
  bash "$DIR/quickdraw.sh"
  bash "$DIR/yolo.sh"
  bash "$DIR/publicist.sh"
  bash "$DIR/pull-shark.sh" 2
  run_pair
  ok "Full Blast complete — check your profile: $(profile_url)"
}

require_auth

while true; do
  print_menu
  read -rp "Choose an option: " choice
  case "$choice" in
    1) bash "$DIR/quickdraw.sh" ;;
    2) bash "$DIR/yolo.sh" ;;
    3) bash "$DIR/publicist.sh" ;;
    4) bash "$DIR/pull-shark.sh" 2 ;;
    5) bash "$DIR/pull-shark.sh" 16 ;;
    6) bash "$DIR/pull-shark.sh" 128 ;;
    7) run_pair ;;
    8) full_blast ;;
    9) npm run --silent tracker ;;
    0) ok "Bye!"; exit 0 ;;
    *) warn "Invalid option." ;;
  esac
done
