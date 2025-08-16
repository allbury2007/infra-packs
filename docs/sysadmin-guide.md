# System Administrator Guide

This guide explains how to deploy, configure, and maintain the reference infrastructure.

## 1. Architecture (baseline)
| Role                  | Hostname           | Internal IP | External IP      | Ports (ingress)                 |
|-----------------------|--------------------|-------------|------------------|---------------------------------|
| Certificate Authority | ca-server          | 10.128.0.10 | — (internal only)| SSH 22 (VPC / IAP), Easy-RSA    |
| VPN                   | vpn-server         | 10.128.0.20 | Public (static)  | 22/tcp, 1194/udp                |
| Monitoring            | monitoring-server  | 10.128.0.30 | Public (static)  | 22/tcp, 9090/tcp (Prometheus), 3000/tcp (Grafana) |
| Backups               | backup-server      | 10.128.0.40 | — (internal only)| 22/tcp (SFTP for restic)        |

> Principle: CA and Backup have **no public IP**. Access them via VPN or IAP (Identity-Aware Proxy) only.

---

## 2. Prerequisites
- Cloud: GCP (or any provider) with a VPC like **10.128.0.0/20**.
- OS: Debian 12 LTS / Ubuntu 24.04 LTS or above for all hosts.
- SSH keys for admin access.
- GitHub access to `allbury2007/infra-packs` Releases (.deb packages).

Recommended machine sizes:
- CA/Backup: 1 vCPU, 1–2 GB RAM, 10–20 GB disk.
- VPN/Monitoring: 2 vCPU, 4 GB RAM, 20–30 GB disk.

---

## 3. Provisioning
1. **Create VMs** and reserve internal IPs as in the table. Give public IP **only** to `vpn-server` and `monitoring-server` if it's necessary.
2. **Firewall** (examples):
   - Allow **SSH 22** only from trusted sources or **GCP IAP (35.235.240.0/20)**.
   - Open **1194/udp** to the world for VPN.
   - Open **9090, 3000/tcp** to trusted sources (or later move behind VPN).
   - Allow **intra-VPC** traffic among all 10.128.0.0/20 hosts.
3. **System bootstrap (all hosts)**:
   ```bash
   sudo apt update && sudo apt -y upgrade
   sudo apt install -y curl git rsync
   ```
4. **Clone repo** (optional, docs & examples):
   ```bash
   git clone https://github.com/allbury2007/infra-packs.git
   cd infra-packs
   ```

---

## 4. Package Installation

After cloning the repository, install the provided `.deb` packages:

```bash
sudo dpkg -i restic-backup_0.1.0_all.deb
sudo dpkg -i vpn-tools_0.1.0_all.deb
sudo dpkg -i ca-tools_0.1.0_all.deb
sudo dpkg -i monitoring-rules_0.1.0_all.deb
```

---

## 4.1 Certificate Authority (`ca-server`)

The CA is initialized with:

```bash
init-ca.sh
```

Client certificates are issued via:

```bash
issue-cert.sh client_name
```

Revocation and CRL generation:

```bash
revoke-cert.sh client_name
gen-crl.sh
```

# 4.2 Export client bundle
To prepare a client key bundle for VPN:

```bash
backup-pki.sh client_name
```

This creates a tar.gz archive in `/srv/pki/exports/client_name.tar.gz`.

---

## 5. VPN server (`vpn-server`)

Install OpenVPN via `vpn-tools` package.  
Scripts provided:

- `build-ovpn.sh` – generates final `.ovpn` client profiles.  
- `iptables.sh` – applies firewall/NAT rules.  

# 6. Import client certs
Workflow to import client certificates from CA:

1. On **CA server**, generate bundle:

   ```bash
   backup-pki.sh client_name
   ```

   Copy the resulting `client_name.tar.gz` to Google Cloud Shell:

   ```bash
   gcloud compute scp ca-server:/srv/pki/exports/client_name.tar.gz . --zone=europe-west3-a --tunnel-through-iap
   ```

2. From Cloud Shell, copy bundle to VPN server:

   ```bash
   gcloud compute scp client_name.tar.gz vpn-server:/tmp/ --zone=europe-west3-a --tunnel-through-iap
   ```

3. On **VPN server**, build `.ovpn` profile:

   ```bash
   sudo build-ovpn.sh /tmp/client_name.tar.gz
   ```

   Output: `/srv/ovpn/exports/client_name.ovpn`

---

## 7. Backup system
Installed via `restic-backup` package.

**Main script:**
- `/usr/local/bin/run-restic-backup.sh`  
  Automates daily backups using Restic:
  - Logs to `/var/log/restic-backup-<hostname>.log`
  - Uses `/root/.restic_pass` for repo password
  - Includes from `/etc/restic-backup/include`, excludes from `/etc/restic-backup/exclude`
  - Initializes repo if needed
  - Runs backup with host/date tags
  - Retention: 7 daily, 4 weekly, 6 monthly
  - Prunes old snapshots
  - Exports Prometheus metric `backup_last_success_timestamp_seconds`

Systemd:
- `restic-backup.service` — runs backup manually/on demand
- `restic-backup.timer` — schedules nightly run at 00:00

Check logs:
```bash
journalctl -u restic-backup.service -f
less /var/log/restic-backup-$(hostname -s).log
```

List snapshots:
```bash
restic snapshots --host $(hostname -s)
```

---

## 6. Security notes
- No public IPs on CA/Backup. Use VPN or IAP.
- SFTP account for restic is **command-restricted** (no shell).
- Rotate CA and VPN CRL periodically.
- Keep Prometheus/Grafana behind VPN (or auth + IP allowlist).

---

## 7. Maintenance checklist
- OS updates monthly: `apt update && apt upgrade -y`
- Backups: verify `restic snapshots` and restore test monthly.
- Monitoring: silence/alert tune; check disk space & TLS certs.
- CA: rotate keys annually; revoke stale client certs.

---
