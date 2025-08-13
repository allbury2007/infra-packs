#!/usr/bin/env bash
set -Eeuo pipefail
HOST="$(hostname -s)"
LOG="/var/log/restic-backup-${HOST}.log"
mkdir -p /var/log
exec >>"$LOG" 2>&1
echo "[$(date -Is)] start (${HOST})"

export HOME=/root
export RESTIC_PASSWORD_FILE="${RESTIC_PASSWORD_FILE:-/root/.restic_pass}"
export RESTIC_REPOSITORY="${RESTIC_REPOSITORY:-sftp:restic@10.128.0.40:.}"

INCLUDE_FILE="${INCLUDE_FILE:-/etc/restic-backup/include}"
EXCLUDE_FILE="${EXCLUDE_FILE:-/etc/restic-backup/exclude}"

ionice -c2 -n7 -t true 2>/dev/null || true
nice -n 10 true || true

command -v restic >/dev/null
[[ -r "$RESTIC_PASSWORD_FILE" ]]
[[ -r "$INCLUDE_FILE" ]] || { echo "[ERROR] missing $INCLUDE_FILE"; exit 1; }

TAG_DATE="$(date -u +'%Y-%m-%d')"
restic snapshots --host "$HOST" >/dev/null || restic init
restic backup --one-file-system --files-from "$INCLUDE_FILE" ${EXCLUDE_FILE:+--exclude-file "$EXCLUDE_FILE"} \
  --host "$HOST" --tag "host=${HOST}" --tag "date=${TAG_DATE}"
restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune --host "$HOST"

install -d -m 755 /var/lib/node_exporter/textfile_collector
TS="$(date +%s)"
cat > /var/lib/node_exporter/textfile_collector/backup_last_success.prom <<EOM
# HELP backup_last_success_timestamp_seconds Timestamp
# TYPE backup_last_success_timestamp_seconds gauge
backup_last_success_timestamp_seconds ${TS}
EOM
echo "[$(date -Is)] done"
