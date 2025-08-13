#!/usr/bin/env bash
set -Eeuo pipefail

# --------------------------------------------------------
# gen-crl.sh
# Generate a Certificate Revocation List (CRL) with Easy-RSA.
# Environment variables:
#   PKI_DIR - path to Easy-RSA directory (default: /srv/pki/easy-rsa)
# --------------------------------------------------------

PKI_DIR="${PKI_DIR:-/srv/pki/easy-rsa}"

cd "$PKI_DIR"
easyrsa gen-crl

echo "[INFO] CRL generated in $PKI_DIR/pki/crl.pem"
