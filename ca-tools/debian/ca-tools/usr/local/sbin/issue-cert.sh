#!/usr/bin/env bash
set -Eeuo pipefail

# --------------------------------------------------------
# issue-cert.sh
# Generate and sign a new certificate with Easy-RSA.
# Usage: ./issue-cert.sh <name> <type>
#   <name> - common name for the certificate
#   <type> - "client" or "server"
# Environment variables:
#   PKI_DIR - path to Easy-RSA directory (default: /srv/pki/easy-rsa)
# --------------------------------------------------------

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <name> <client|server>"
  exit 1
fi

NAME="$1"
TYPE="$2"
PKI_DIR="${PKI_DIR:-/srv/pki/easy-rsa}"

cd "$PKI_DIR"

case "$TYPE" in
  client)
    easyrsa gen-req "$NAME" nopass
    easyrsa sign-req client "$NAME"
    ;;
  server)
    easyrsa gen-req "$NAME" nopass
    easyrsa sign-req server "$NAME"
    ;;
  *)
    echo "[ERROR] Type must be 'client' or 'server'"
    exit 1
    ;;
esac
