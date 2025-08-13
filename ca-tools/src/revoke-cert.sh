#!/usr/bin/env bash
set -Eeuo pipefail

# --------------------------------------------------------
# revoke-cert.sh
# Revoke a certificate using Easy-RSA and regenerate the CRL.
# Usage: ./revoke-cert.sh <name>
# Environment variables:
#   PKI_DIR - path to Easy-RSA directory (default: /srv/pki/easy-rsa)
# --------------------------------------------------------

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <name>"
  exit 1
fi

NAME="$1"
PKI_DIR="${PKI_DIR:-/srv/pki/easy-rsa}"

cd "$PKI_DIR"
easyrsa revoke "$NAME"
easyrsa gen-crl

echo "[INFO] Certificate $NAME revoked and CRL updated."
