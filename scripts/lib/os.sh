#!/usr/bin/env bash
# OS detection utilities — source this file, do not execute directly.
#
# After sourcing, these variables are set:
#   OS_ID      — lowercase distro id from /etc/os-release  (e.g. "ubuntu", "fedora")
#   OS_VERSION — VERSION_ID from /etc/os-release            (e.g. "26.04", "44")
#   OS_FAMILY  — "debian" | "fedora" | "unknown"

detect_os() {
  local file
  if [[ -e /etc/os-release ]]; then
    file=/etc/os-release
  else
    file=/usr/lib/os-release
  fi
  OS_ID="$(awk -F '=' '/^ID=/ { gsub(/"/, "", $2); print $2 }' "$file")"
  OS_VERSION="$(awk -F '=' '/^VERSION_ID=/ { gsub(/"/, "", $2); print $2 }' "$file")"
  case "$OS_ID" in
    ubuntu|debian|raspbian|linuxmint|elementary|pop)
      OS_FAMILY="debian" ;;
    fedora|rhel|centos|almalinux|rocky)
      OS_FAMILY="fedora" ;;
    *)
      OS_FAMILY="unknown" ;;
  esac
}

require_supported_os() {
  if [[ "$OS_FAMILY" == "unknown" ]]; then
    echo "ERROR: Unsupported OS '${OS_ID:-unknown}'." >&2
    echo "       Supported: Ubuntu/Debian, Fedora/RHEL." >&2
    exit 1
  fi
}

# Run detection immediately when sourced.
detect_os
