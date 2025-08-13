#!/usr/bin/env bash
set -Eeuo pipefail
# Build a client .ovpn with inline certs/keys.
# Usage: build-ovpn.sh <client-name>
KEY_DIR="${KEY_DIR:-$HOME/clients/keys}"
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/clients/files}"
BASE_CONFIG="${BASE_CONFIG:-$HOME/clients/base.conf}"
[[ $# -eq 1 ]] || { echo "Usage: $0 <client-name>"; exit 1; }
CLIENT="$1"
[[ -f "$BASE_CONFIG" ]] || { echo "Error: missing $BASE_CONFIG"; exit 1; }
for f in "$KEY_DIR/ca.crt" "$KEY_DIR/$CLIENT.crt" "$KEY_DIR/$CLIENT.key" "$KEY_DIR/ta.key"; do
  [[ -f "$f" ]] || { echo "Error: missing $f"; exit 1; }
done
mkdir -p "$OUTPUT_DIR"
cat "$BASE_CONFIG" \
  <(echo -e "<ca>") "$KEY_DIR/ca.crt" \
  <(echo -e "</ca>\n<cert>") "$KEY_DIR/$CLIENT.crt" \
  <(echo -e "</cert>\n<key>") "$KEY_DIR/$CLIENT.key" \
  <(echo -e "</key>\n<tls-crypt>") "$KEY_DIR/ta.key" \
  <(echo -e "</tls-crypt>") \
  > "$OUTPUT_DIR/$CLIENT.ovpn"
echo "Config created: $OUTPUT_DIR/$CLIENT.ovpn"
