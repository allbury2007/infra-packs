# Backup System Documentation

This document explains how the automated backup works.

---

## Components
- **Restic** — backup engine
- **restic-backup** package — ships automation scripts & systemd units
- **backup-server** — central repository host (SFTP only)

---

## Main script
`/usr/local/bin/run-restic-backup.sh`

Tasks performed:
- Logs to `/var/log/restic-backup-<hostname>.log`
- Reads repo password from `/root/.restic_pass`
- Includes/excludes from `/etc/restic-backup/{include,exclude}`
- Initializes repo if first run
- Backs up with tags (`host`, `date`)
- Retention: keep 7 daily, 4 weekly, 6 monthly, prune old
- Exports Prometheus metric to `/var/lib/node_exporter/textfile_collector/backup_last_success.prom`

---

## Systemd integration
Two units are installed:

- **restic-backup.service**  
  Runs `run-restic-backup.sh` once.

- **restic-backup.timer**  
  Triggers the service nightly at 00:00.

Enable & start:
```bash
systemctl enable --now restic-backup.timer
```

Manual run:
```bash
systemctl start restic-backup.service
```

Check logs:
```bash
journalctl -u restic-backup.service -f
```

List snapshots:
```bash
restic snapshots --host $(hostname -s)
```

---

