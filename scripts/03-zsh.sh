#!/usr/bin/env bash
# Install oh-my-zsh and required custom plugins
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/os.sh
source "$SCRIPTS_DIR/lib/os.sh"

# oh-my-zsh
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  echo "==> oh-my-zsh already installed, skipping."
else
  echo "==> Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestions
if [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  echo "==> zsh-autosuggestions already installed."
else
  echo "==> Installing zsh-autosuggestions..."
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# Make zsh the default shell.
#
# ACTUAL_USER: prefer $SUDO_USER (set by sudo to the original caller) so the
# correct account is targeted whether the script is run directly or via
# "sudo ./install.sh" (where $USER would resolve to "root").
ACTUAL_USER="${SUDO_USER:-$USER}"
ZSH_PATH="$(which zsh)"

# Ensure zsh is listed as a valid login shell.
if ! grep -qx "$ZSH_PATH" /etc/shells; then
  echo "==> Registering $ZSH_PATH in /etc/shells..."
  echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
fi

# Read the current shell from the passwd database — more reliable than $SHELL,
# which reflects the invoking process, not the stored default.
CURRENT_SHELL="$(getent passwd "$ACTUAL_USER" | cut -d: -f7)"

if [[ "$CURRENT_SHELL" == "$ZSH_PATH" ]]; then
  echo "==> Default shell is already zsh for '$ACTUAL_USER'."
else
  echo "==> Changing default shell to zsh for '$ACTUAL_USER'..."
  sudo usermod -s "$ZSH_PATH" "$ACTUAL_USER"

  # Verify the change landed in the passwd database.
  NEW_SHELL="$(getent passwd "$ACTUAL_USER" | cut -d: -f7)"
  if [[ "$NEW_SHELL" != "$ZSH_PATH" ]]; then
    echo "ERROR: shell change did not take effect (still: $NEW_SHELL)" >&2
    exit 1
  fi

  echo "==> Shell changed. Log out and back in for it to take effect."
fi

if [[ "$OS_FAMILY" == "fedora" ]]; then
  # Konsole stores its own shell setting per-profile and ignores /etc/passwd.
  # We create a profile that launches zsh and set it as the default.
  KONSOLE_DIR="$HOME/.local/share/konsole"
  mkdir -p "$KONSOLE_DIR"
  cat > "$KONSOLE_DIR/zsh.profile" <<EOF
[General]
Command=$ZSH_PATH
Name=zsh
Parent=FALLBACK/
EOF

  # kwriteconfig is the KDE-native tool for updating INI-style config files.
  # Plasma 6 (Fedora 44) ships kwriteconfig6; Plasma 5 ships kwriteconfig5.
  if command -v kwriteconfig6 &>/dev/null; then
    kwriteconfig6 --file konsolerc --group "Desktop Entry" --key "DefaultProfile" "zsh.profile"
  elif command -v kwriteconfig5 &>/dev/null; then
    kwriteconfig5 --file konsolerc --group "Desktop Entry" --key "DefaultProfile" "zsh.profile"
  else
    echo "  WARNING: kwriteconfig not found; set Konsole's default profile to 'zsh' manually." >&2
  fi
  echo "==> Konsole default profile set to zsh."

  # Also export SHELL for the Plasma session at large. SDDM launches the session
  # via a bash script that resets $SHELL to /bin/bash before KDE starts; scripts
  # in plasma-workspace/env/ are sourced by KDE afterwards and win.
  PLASMA_ENV_DIR="$HOME/.config/plasma-workspace/env"
  mkdir -p "$PLASMA_ENV_DIR"
  echo "export SHELL=$ZSH_PATH" > "$PLASMA_ENV_DIR/zsh.sh"
  echo "==> Wrote KDE Plasma SHELL override to $PLASMA_ENV_DIR/zsh.sh"
fi

echo "==> zsh setup complete."
