#!/usr/bin/env bash
set -Eeuo pipefail

# --------------------------------------------------------
# init-ca.sh
# Initialization of a new PKI structure with Easy-RSA.
# If PKI already exists, it will skip creation.
# Environment variables:
#   PKI_DIR - path to Easy-RSA directory (default: /srv/pki/easy-rsa)
# --------------------------------------------------------

PKI_DIR="${PKI_DIR:-/srv/pki/easy-rsa}"
mkdir -p "$PKI_DIR"
cd "$PKI_DIR"

if [[ ! -d ./pki ]]; then
  easyrsa init-pki
  easyrsa build-ca nopass
else
  echo "[INFO] PKI already exists in $PKI_DIR"
fi
