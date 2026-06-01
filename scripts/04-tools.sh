#!/usr/bin/env bash
# Install CLI tools: eza, fzf, starship, goto, nvm
set -euo pipefail

# eza (modern ls replacement)
if command -v eza &>/dev/null; then
  echo "==> eza already installed."
else
  echo "==> Installing eza..."
  sudo apt-get install -y gpg
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
    | sudo tee /etc/apt/sources.list.d/gierens.list
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  sudo apt-get update -qq
  sudo apt-get install -y eza
fi

# fzf (fuzzy finder)
if command -v fzf &>/dev/null; then
  echo "==> fzf already installed."
else
  echo "==> Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all --no-update-rc
fi

# starship prompt
if command -v starship &>/dev/null; then
  echo "==> starship already installed."
else
  echo "==> Installing starship..."
  curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
fi

# goto - directory bookmarks
if [[ -f "/usr/local/share/goto.sh" ]]; then
  echo "==> goto already installed."
else
  echo "==> Installing goto..."
  GOTO_TMP=$(mktemp -d)
  git clone --depth=1 https://github.com/iridakos/goto.git "$GOTO_TMP/goto"
  sudo cp "$GOTO_TMP/goto/goto.sh" /usr/local/share/goto.sh
  rm -rf "$GOTO_TMP"
fi

# nvm (Node Version Manager)
if [[ -d "$HOME/.nvm" ]]; then
  echo "==> nvm already installed."
else
  echo "==> Installing nvm..."
  NVM_VERSION="v0.40.3"
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
fi

echo "==> Tools installed."
