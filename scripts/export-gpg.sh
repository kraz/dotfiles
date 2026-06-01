#!/usr/bin/env bash
# GPG key export helper
# Lists installed secret keys and lets you choose which ones to export.
# Each selected key is exported to a separate .asc file in the current directory.
#
# Usage:
#   ./scripts/export-gpg.sh [output-directory]
#
# Then copy the exported files to the new machine and run:
#   ./scripts/import-gpg.sh personal.key.gpg.asc work.key.gpg.asc ownertrust.txt
set -euo pipefail

OUTDIR="${1:-.}"

if [[ ! -d "$OUTDIR" ]]; then
  echo "Error: output directory '$OUTDIR' does not exist."
  exit 1
fi

echo "==> Installed secret keys:"
echo ""
gpg --list-secret-keys --keyid-format LONG
echo ""

# Build an array of key fingerprints
mapfile -t FINGERPRINTS < <(gpg --list-secret-keys --with-colons | awk -F: '/^fpr:/{print $10}')

if [[ ${#FINGERPRINTS[@]} -eq 0 ]]; then
  echo "No secret keys found in keyring."
  exit 0
fi

# Build a display list of keys (fingerprint + uid)
declare -a KEY_LABELS=()
for fpr in "${FINGERPRINTS[@]}"; do
  uid=$(gpg --list-secret-keys --with-colons "$fpr" 2>/dev/null \
        | awk -F: '/^uid:/{print $10; exit}')
  KEY_LABELS+=("${fpr: -16}  ${uid}")
done

echo "Select keys to export (space-separated numbers, or 'all'):"
for i in "${!KEY_LABELS[@]}"; do
  printf "  %d) %s\n" "$((i+1))" "${KEY_LABELS[$i]}"
done
echo ""
read -rp "Your choice: " SELECTION

# Resolve selection to indices
declare -a CHOSEN_INDICES=()
if [[ "$SELECTION" == "all" ]]; then
  for i in "${!FINGERPRINTS[@]}"; do
    CHOSEN_INDICES+=("$i")
  done
else
  for token in $SELECTION; do
    if ! [[ "$token" =~ ^[0-9]+$ ]] || (( token < 1 || token > ${#FINGERPRINTS[@]} )); then
      echo "Error: '$token' is not a valid selection."
      exit 1
    fi
    CHOSEN_INDICES+=("$((token - 1))")
  done
fi

if [[ ${#CHOSEN_INDICES[@]} -eq 0 ]]; then
  echo "No keys selected, nothing exported."
  exit 0
fi

echo ""
for idx in "${CHOSEN_INDICES[@]}"; do
  fpr="${FINGERPRINTS[$idx]}"
  short_id="${fpr: -16}"
  uid="${KEY_LABELS[$idx]#*  }"
  # Derive a safe filename from the uid (lowercase, spaces→underscores, strip unsafe chars)
  safe_name=$(echo "$uid" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd '[:alnum:]_.-')
  outfile="${OUTDIR}/${safe_name}.key.gpg.asc"

  echo "==> Exporting $short_id ($uid) -> $outfile"
  gpg --armor --export-secret-keys "$fpr" > "$outfile"
done

TRUST_FILE="${OUTDIR}/ownertrust.txt"
echo ""
echo "==> Exporting ownertrust -> $TRUST_FILE"
gpg --armor --export-ownertrust > "$TRUST_FILE"

echo ""
echo "==> Exported files:"
for idx in "${CHOSEN_INDICES[@]}"; do
  uid="${KEY_LABELS[$idx]#*  }"
  safe_name=$(echo "$uid" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd '[:alnum:]_.-')
  echo "    ${OUTDIR}/${safe_name}.key.gpg.asc"
done
echo "    ${TRUST_FILE}"
echo ""
echo "==> Transfer these files securely (encrypted USB, encrypted transfer, etc.)"
echo "    then import on the new machine with:"
echo "    ./scripts/import-gpg.sh *.key.gpg.asc ownertrust.txt"
