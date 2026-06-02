#!/usr/bin/env bash
# Build and install git-credential-libsecret.
# Credentials are stored in GNOME Keyring (or any Secret Service provider)
# and unlocked automatically when you log in — no plaintext files, no timeouts.
set -euo pipefail

HELPER="/usr/local/bin/git-credential-libsecret"
SRC_DIR="/usr/share/doc/git/contrib/credential/libsecret"

if [[ -x "$HELPER" ]]; then
  echo "==> git-credential-libsecret already installed."
  exit 0
fi

if [[ ! -d "$SRC_DIR" ]]; then
  echo "ERROR: Source not found at $SRC_DIR" >&2
  echo "  Ensure 'git' is installed from the git-core PPA (run 01-packages.sh first)." >&2
  exit 1
fi

echo "==> Installing build dependencies..."
sudo apt-get install -y libsecret-1-0 libsecret-1-dev pkg-config

echo "==> Building git-credential-libsecret..."
BUILD_TMP=$(mktemp -d)
trap 'rm -rf "$BUILD_TMP"' EXIT
cp -r "$SRC_DIR"/. "$BUILD_TMP/"
make -C "$BUILD_TMP" git-credential-libsecret
sudo install -m 0755 "$BUILD_TMP/git-credential-libsecret" "$HELPER"

echo "==> Removing build-only dependency (libsecret-1-dev)..."
sudo apt-get remove -y libsecret-1-dev --autoremove

echo "==> git-credential-libsecret installed at $HELPER"
echo ""
echo "  Credentials will be stored in the GNOME Keyring / Secret Service."
echo "  The keyring is unlocked automatically at login."
echo "  First push will prompt once; subsequent pushes are silent."
