#!/usr/bin/env bash
# Bootstrap a fresh Ubuntu 26.04 development environment.
# Run once after cloning this repo.
#
# Usage:
#   git clone <this-repo> ~/dotfiles
#   cd ~/dotfiles
#   ./install.sh
#
# Individual scripts can be re-run safely on their own:
#   ./scripts/04-tools.sh    # just re-install tools
#   ./scripts/06-link.sh     # just re-link dotfiles
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

echo ""
echo "╭───────────────────────────────────╮"
echo "│  dotfiles bootstrap — Ubuntu LTS  │"
echo "╰───────────────────────────────────╯"
echo ""

run_step() {
  local script="$1"
  echo ""
  echo "──── $script ────"
  bash "$DOTFILES_DIR/scripts/$script"
}

run_step 01-packages.sh
run_step 02-fonts.sh
run_step 03-zsh.sh
run_step 04-tools.sh
run_step 05-docker.sh
run_step 06-link.sh

echo ""
echo "╭───────────────────────────────────────────────────────────────╮"
echo "│  Bootstrap complete!                                          │"
echo "│                                                               │"
echo "│  Next steps:                                                  │"
echo "│  1. Import GPG keys:        ./scripts/import-gpg.sh <key.asc> │"
echo "│  2. Set up git identities:  ./scripts/setup-identities.sh     │"
echo "│  3. Set terminal font to 'JetBrainsMono Nerd Font'            │"
echo "│  4. Log out and back in (zsh default shell + docker group)    │"
echo "╰───────────────────────────────────────────────────────────────╯"
echo ""
