#!/usr/bin/env bash
# Install Nerd Fonts (required for starship prompt icons and eza icons)
# Uses JetBrainsMono — change FONT_NAME below to prefer another family.
# Full list: https://github.com/ryanoasis/nerd-fonts/releases
set -euo pipefail

FONT_NAME="JetBrainsMono"
FONT_VERSION="3.4.0"
FONT_DIR="$HOME/.local/share/fonts"

if fc-list | grep -qi "JetBrainsMono"; then
  echo "==> Nerd Font '$FONT_NAME' already installed, skipping."
  exit 0
fi

echo "==> Installing Nerd Font: $FONT_NAME v$FONT_VERSION..."
mkdir -p "$FONT_DIR"

TMP=$(mktemp -d)
curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/v${FONT_VERSION}/${FONT_NAME}.tar.xz" \
  -o "$TMP/${FONT_NAME}.tar.xz"
tar -xf "$TMP/${FONT_NAME}.tar.xz" -C "$TMP"
find "$TMP" -name "*.ttf" -exec cp {} "$FONT_DIR/" \;
rm -rf "$TMP"

mkdir -p "$HOME/.cache/fontconfig"
fc-cache -fv "$FONT_DIR" > /dev/null || true

echo "==> Font installed. Set your terminal to use 'JetBrainsMono Nerd Font'."
