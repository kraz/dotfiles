#!/usr/bin/env bash
# Install base apt packages needed before other scripts run
set -euo pipefail

echo "==> Adding git-core PPA..."
sudo add-apt-repository -y ppa:git-core/ppa

echo "==> Updating apt..."
sudo apt-get update -qq

echo "==> Installing base packages..."
sudo apt-get install -y \
  jq \
  zsh \
  git \
  curl \
  wget \
  unzip \
  gnupg \
  gpg \
  gpg-agent \
  pinentry-curses \
  build-essential \
  ca-certificates \
  apt-transport-https \
  software-properties-common

echo "==> Base packages installed."
