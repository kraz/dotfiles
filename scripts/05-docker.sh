#!/usr/bin/env bash
# Install Docker Engine (CE) and grant the current user rootless access.
# Follows the official Docker docs for Ubuntu:
# https://docs.docker.com/engine/install/ubuntu/
set -euo pipefail

# Remove old conflicting packages shipped by Ubuntu
OLD_PKGS=(docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc)
for pkg in "${OLD_PKGS[@]}"; do
  if dpkg -l "$pkg" &>/dev/null 2>&1; then
    echo "==> Removing old package: $pkg"
    sudo apt-get remove -y "$pkg"
  fi
done

if command -v docker &>/dev/null; then
  echo "==> Docker already installed ($(docker --version)), skipping."
else
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
  echo "==> Group change applied. You must log out and back in (or run 'newgrp docker')"
  echo "    before running docker commands without sudo."
fi

echo "==> Docker setup complete."
