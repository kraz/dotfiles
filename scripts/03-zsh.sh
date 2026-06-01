#!/usr/bin/env bash
# Install oh-my-zsh and required custom plugins
set -euo pipefail

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

# Make zsh the default shell
if [[ "$SHELL" != "$(which zsh)" ]]; then
  echo "==> Changing default shell to zsh..."
  chsh -s "$(which zsh)"
  echo "==> Shell changed. Log out and back in (or reboot) for it to take effect."
fi

echo "==> zsh setup complete."
