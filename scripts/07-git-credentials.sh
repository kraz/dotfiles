#!/usr/bin/env bash
# Build/install git-credential-libsecret.
# Credentials are stored via the Secret Service API (GNOME Keyring on Ubuntu,
# KWallet on Fedora/KDE) and unlocked automatically at login — no plaintext
# files, no timeouts.
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/os.sh
source "$SCRIPTS_DIR/lib/os.sh"
require_supported_os

HELPER="/usr/local/bin/git-credential-libsecret"

if [[ -x "$HELPER" ]]; then
  echo "==> git-credential-libsecret already installed."
  exit 0
fi

case "$OS_FAMILY" in
  debian)
    SRC_DIR="/usr/share/doc/git/contrib/credential/libsecret"
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
    ;;

  fedora)
    # Fedora 44's git RPM does not ship a pre-built git-credential-libsecret binary,
    # so we build it from the upstream git source tree matching the installed version.
    # If a future Fedora release does include the binary, the symlink path will be
    # taken instead and the build is skipped.
    FEDORA_BIN="/usr/libexec/git-core/git-credential-libsecret"

    if [[ -x "$FEDORA_BIN" ]]; then
      echo "==> Installing libsecret runtime library..."
      sudo dnf install -y libsecret
      echo "==> Symlinking $FEDORA_BIN -> $HELPER"
      sudo ln -sf "$FEDORA_BIN" "$HELPER"
    else
      echo "==> Building git-credential-libsecret from source..."
      sudo dnf install -y libsecret libsecret-devel pkgconf-pkg-config gcc make

      GIT_VERSION="$(git --version | awk '{print $3}')"
      BUILD_TMP=$(mktemp -d)
      trap 'rm -rf "$BUILD_TMP"' EXIT

      echo "==> Downloading git ${GIT_VERSION} source for credential helper..."
      curl -fsSL \
        "https://github.com/git/git/archive/refs/tags/v${GIT_VERSION}.tar.gz" \
        -o "$BUILD_TMP/git.tar.gz"
      tar -xf "$BUILD_TMP/git.tar.gz" \
        -C "$BUILD_TMP" \
        "git-${GIT_VERSION}/contrib/credential/libsecret/"

      make -C "$BUILD_TMP/git-${GIT_VERSION}/contrib/credential/libsecret"
      sudo install -m 0755 \
        "$BUILD_TMP/git-${GIT_VERSION}/contrib/credential/libsecret/git-credential-libsecret" \
        "$HELPER"

      echo "==> Removing build-only dependencies..."
      sudo dnf remove -y libsecret-devel
      sudo dnf autoremove -y
    fi
    ;;
esac

echo "==> git-credential-libsecret installed at $HELPER"
echo ""
echo "  Credentials are stored via the Secret Service API."
echo "  On Ubuntu: GNOME Keyring is unlocked automatically at login."
echo "  On Fedora/KDE: KWallet provides the Secret Service interface."
echo "  First push will prompt once; subsequent pushes are silent."
