# Infrastructure Roadmap

## Current Setup

| Purpose               | Hostname          | Internal IP | External IP       | Services                       |
|-----------------------|-------------------|-------------|------------------|---------------------------------|
| Certificate Authority | ca-server         | 10.128.0.10 | —                | Easy-RSA PKI (manual issuance)  |
| VPN Gateway           | vpn-server        | 10.128.0.20 | 34.xxx.xxx.xxx   | OpenVPN (entry point for users) |
| Monitoring            | monitoring-server | 10.128.0.30 | 34.xxx.xxx.xxx   | Prometheus, Grafana             |
| Backups               | backup-server     | 10.128.0.40 | —                | Restic repositories (SFTP only) |

---

## Planned Improvements

| Purpose               | Hostname           | Internal IP | External IP     | Services / Notes                                                                 |
|-----------------------|-------------------|-------------|------------------|----------------------------------------------------------------------------------|
| Certificate Authority | ca-server         | 10.128.0.10 | —                | PKI automation: issue 1-year certs, renewal reminders, CRL enforcement           |
| VPN Gateway           | vpn-server        | 10.128.0.20 | 34.xxx.xxx.xxx   | OpenVPN; cert lifecycle integration; MFA option in roadmap                       |
| Monitoring            | monitoring-server | 10.128.0.30 | 34.xxx.xxx.xxx   | Prometheus + Grafana; alerts for expiring certs, failed backups, disk thresholds |
| Backups               | backup-server     | 10.128.0.40 | —                | Restic with retention policies, periodic restore tests, monitoring integration   |
| Secrets Sharing       | secrets-server    | 10.128.0.50 | (optional) ext IP| PrivateBin (VPN-only). Optional bootstrap instance with short-lived HTTPS access |
| Database (future)     | db-server         | 10.128.0.60 | — or limited     | PostgreSQL/MySQL for apps; regular restic backups, internal-only                 |

---

## Roadmap Notes

### 1. Certificate Authority (ca-server)
- Current: manual Easy-RSA usage; certs issued ad-hoc.  
- Improvements:
  - Standardize client cert validity to **1 year**.  
  - Renewal policy: notify users at **30/14/7 days**.  
  - Implement **Certificate Revocation List (CRL)** distribution via VPN and monitoring.  
  - Automate renewal requests and signed profile delivery through PrivateBin.

### 2. VPN Gateway (vpn-server)
- Current: OpenVPN with static cert distribution.  
- Improvements:
  - Tighten lifecycle: cert renewal required annually.  
  - Future option: **MFA (2FA plugin)** for critical accounts.  
  - Restrict external access: only port **1194/UDP** and **22 (IAP/management)** open.  
  - Integrate monitoring for connected clients and expired certs.

### 3. Monitoring (monitoring-server)
- Current: Prometheus + Grafana with basic rules.  
- Improvements:
  - Add alerting for:
    - Certs nearing expiry.  
    - Failed/missing backups.  
    - Disk usage thresholds (80/90%).  
  - Deliver alerts via **Slack/Telegram/email**.  
  - Harden access: Grafana behind VPN or with SSO.

### 4. Backup Server (backup-server)
- Current: restic repos per host, nightly cron via systemd.  
- Improvements:
  - Enforce retention: `--keep-daily=7 --keep-weekly=4 --keep-monthly=6`.  
  - Monthly **test restore** procedure documented.  
  - Add Prometheus exporter for restic stats.  
  - Keep server **internal-only**, no public IP.

### 5. Secrets Sharing (planned secrets-server)
- Current: no secure sharing channel.  
- Improvements:
  - Deploy **PrivateBin** with burn-after-reading, short TTL (e.g., 24h).  
  - VPN-only by default.  
  - Optional “bootstrap” mode: short-lived HTTPS exposure for onboarding new clients.  
  - Disable file uploads, text-only secrets.

### 6. Database Server (future db-server)
- Purpose: central DB for internal apps.  
- Design:
  - No external IP.  
  - Backups to backup-server with restic.  
  - Monitor replication lag & DB health.  
  - Prepare disaster recovery (documented restore steps).

---

## Summary

- Short-term: certificate lifecycle automation, PrivateBin deployment, improved monitoring alerts.  
- Medium-term: test restore procedures, enforce retention, secure Grafana behind VPN/SSO.  
- Long-term: optional MFA for VPN, introduce central database, formalize DR plans.