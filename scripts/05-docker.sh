#!/usr/bin/env bash
# Install Docker Engine (CE) and grant the current user rootless access.
# References:
#   Ubuntu: https://docs.docker.com/engine/install/ubuntu/
#   Fedora: https://docs.docker.com/engine/install/fedora/
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/os.sh
source "$SCRIPTS_DIR/lib/os.sh"
require_supported_os

case "$OS_FAMILY" in
  debian)
    # Remove old conflicting packages shipped by Ubuntu
    OLD_PKGS=(docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc)
    for pkg in "${OLD_PKGS[@]}"; do
      if dpkg -l "$pkg" &>/dev/null 2>&1; then
        echo "==> Removing old package: $pkg"
        sudo apt-get remove -y "$pkg"
      fi
    done

    if ! command -v docker &>/dev/null; then
      echo "==> Adding Docker's official GPG key and apt repository..."
      sudo apt-get update -qq
      sudo apt-get install -y ca-certificates curl

      sudo install -m 0755 -d /etc/apt/keyrings
      sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        -o /etc/apt/keyrings/docker.asc
      sudo chmod a+r /etc/apt/keyrings/docker.asc

      sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

      echo "==> Installing Docker Engine..."
      sudo apt-get update -qq
      sudo apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
    fi
    ;;

  fedora)
    # Remove old conflicting packages
    OLD_PKGS=(docker docker-client docker-client-latest docker-common docker-latest
              docker-latest-logrotate docker-logrotate docker-selinux
              docker-engine-selinux docker-engine)
    for pkg in "${OLD_PKGS[@]}"; do
      if rpm -q "$pkg" &>/dev/null 2>&1; then
        echo "==> Removing old package: $pkg"
        sudo dnf remove -y "$pkg"
      fi
    done

    if ! command -v docker &>/dev/null; then
      echo "==> Adding Docker's official Fedora repository..."
      sudo dnf config-manager addrepo \
        --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo

      echo "==> Installing Docker Engine..."
      sudo dnf install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
    fi
    ;;
esac

if command -v docker &>/dev/null; then
  echo "==> Docker installed ($(docker --version))."
fi

# Enable and start the daemon
echo "==> Enabling docker service..."
sudo systemctl enable --now docker

# Add the current user to the docker group so no sudo is needed
if id -nG "$USER" | grep -qw docker; then
  echo "==> User '$USER' is already in the docker group."
else
  echo "==> Adding '$USER' to the docker group..."
  sudo usermod -aG docker "$USER"
  echo "==> Group change applied. Please reboot (a logout/login is not sufficient on"
  echo "    Fedora/KDE Plasma). To use docker immediately without rebooting, run: newgrp docker"
fi

echo "==> Docker setup complete."
