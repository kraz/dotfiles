#!/usr/bin/env bash
# GPG key import helper
# Your private keys are NOT stored in this repo.
# Export them from your current machine and import on the new one.
#
# On the SOURCE machine, run:
#   gpg --armor --export-secret-keys ABC1234567890123 > personal.key.gpg.asc
#   gpg --armor --export-secret-keys DEF1234567890123 > work.key.gpg.asc
#   gpg --armor --export-ownertrust > ownertrust.txt
#
# Copy those files to the new machine (encrypted USB, encrypted transfer, etc.)
# Then run this script:
#   ./scripts/import-gpg.sh personal.key.gpg.asc work.key.gpg.asc ownertrust.txt
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <key-file.asc> [key-file2.asc ...] [ownertrust.txt]"
  echo ""
  echo "Export keys from source machine first:"
  echo "  gpg --armor --export-secret-keys ABC1234567890123 > personal.key.gpg.asc"
  echo "  gpg --armor --export-secret-keys DEF1234567890123 > work.key.gpg.asc"
  echo "  gpg --armor --export-ownertrust > ownertrust.txt"
  exit 1
fi

for file in "$@"; do
  if [[ "$file" == *ownertrust* ]]; then
    echo "==> Importing ownertrust from $file..."
    gpg --import-ownertrust < "$file"
  else
    echo "==> Importing key from $file..."
    gpg --import "$file"
  fi
done

echo ""
echo "==> Imported keys:"
gpg --list-secret-keys --keyid-format LONG

echo ""
echo "==> Done. Verify signing works with:"
echo "    echo test | gpg --clearsign"
