#!/usr/bin/env bash
set -Eeuo pipefail

# --------------------------------------------------------
# backup-pki.sh
# Create a tar.gz backup of the Easy-RSA PKI directory.
# Environment variables:
#   PKI_DIR   - path to Easy-RSA directory (default: /srv/pki/easy-rsa)
#   BACKUP_DIR - path to store backups (default: /var/backups/pki)
# --------------------------------------------------------

PKI_DIR="${PKI_DIR:-/srv/pki/easy-rsa}"
BACKUP_DIR="${BACKUP_DIR:-/var/backups/pki}"

mkdir -p "$BACKUP_DIR"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
ARCHIVE="$BACKUP_DIR/pki-backup-$TIMESTAMP.tar.gz"

tar czf "$ARCHIVE" -C "$PKI_DIR" pki

echo "[INFO] PKI backup created: $ARCHIVE"
