#!/usr/bin/env bash
# Symlink dotfiles from this repo into the home directory.
# Safe to re-run: backs up any existing file before replacing it.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

link() {
  local src="$1"
  local dst="$2"

  if [[ -e "$dst" && ! -L "$dst" ]]; then
    mkdir -p "$BACKUP_DIR"
    echo "  Backing up existing $dst -> $BACKUP_DIR/"
    mv "$dst" "$BACKUP_DIR/"
  fi

  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  echo "  Linked $dst -> $src"
}

echo "==> Linking dotfiles from $DOTFILES_DIR..."

link "$DOTFILES_DIR/home/.zshrc"            "$HOME/.zshrc"
link "$DOTFILES_DIR/home/.gitconfig"        "$HOME/.gitconfig"
link "$DOTFILES_DIR/home/.gitignore"        "$HOME/.gitignore"
link "$DOTFILES_DIR/config/starship.toml"   "$HOME/.config/starship.toml"

link "$DOTFILES_DIR/claude/settings.json"          "$HOME/.claude/settings.json"
link "$DOTFILES_DIR/claude/statusline-command.sh"  "$HOME/.claude/statusline-command.sh"

# Identity files (~/.gitconfig-personal, ~/.gitconfig-work-*, ~/.gitconfig.local)
# are generated — not symlinked. Run scripts/setup-identities.sh to create them.

echo "==> Done."
[[ -d "$BACKUP_DIR" ]] && echo "==> Old files backed up to $BACKUP_DIR"
