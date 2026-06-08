#!/usr/bin/env bash
# Install base packages needed before other scripts run.
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/os.sh
source "$SCRIPTS_DIR/lib/os.sh"
require_supported_os

case "$OS_FAMILY" in
  debian)
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
    ;;

  fedora)
    echo "==> Refreshing dnf metadata and upgrading..."
    sudo dnf upgrade -y --refresh --quiet

    echo "==> Installing base packages..."
    # @development-tools provides gcc, make, and related build utilities.
    # pinentry-qt integrates with KDE Wallet for GUI passphrase prompts.
    sudo dnf install -y \
      jq \
      zsh \
      git \
      curl \
      wget \
      unzip \
      gnupg2 \
      pinentry \
      pinentry-qt \
      @development-tools \
      ca-certificates
    ;;
esac

echo "==> Base packages installed."
