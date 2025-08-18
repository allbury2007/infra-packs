# Infrastructure for Small Business

This repository contains infrastructure configuration and tools for a small business environment deployed in the cloud (e.g., GCP, Yandex Cloud, etc.).  
It includes PKI management, VPN access, centralized monitoring, and automated backups.

## Infrastructure Overview

| Purpose                                   | Hostname           | Internal IP  | External IP      | Ports                              | Services                  |
|-------------------------------------------|--------------------|--------------|------------------|-------------------------------------|---------------------------|
| Certificate Authority (CA)                | ca-server          | 10.128.0.10  | —                | 22 (internal only)                  | Easy-RSA PKI               |
| VPN server                                | vpn-server         | 10.128.0.20  | —                | 22, 1194/UDP                        | OpenVPN                    |
| Monitoring (Prometheus + Grafana)         | monitoring-server  | 10.128.0.30  | 34.xxx.xxx.xxx   | 22, 3000/TCP, 9090/TCP               | Prometheus, Grafana        |
| Backup server                             | backup-server      | 10.128.0.40  | —                | 22 (internal only)                  | Restic SFTP repository     |

---

## Network Diagram

![Infrastructure diagram](docs/network-diagram.png)

---

## Components

- **restic-backup** – Automated backup scripts for all servers
- **vpn-tools** – VPN management scripts
- **ca-tools** – Easy-RSA Certificate Authority management scripts
- **monitoring-rules** – Prometheus alert rules

## Installation

Download `.deb` packages from [Releases](https://github.com/allbury2007/infra-packs/releases) and install:

```bash
# example: install all four packages
sudo dpkg -i   ca-tools_0.1.1_all.deb   vpn-tools_0.1.1_all.deb   restic-backup_0.1.1_all.deb   monitoring-rules_0.1.1_all.deb

# if dpkg reports missing dependencies:
sudo apt-get -f install
```

> You can install without GPG verification, but for production use you should verify signatures (see below).

## Verification (recommended)

### 1. Verify SHA256 checksums
On the release page, download `SHA256SUMS.txt` and the selected `.deb` files, then:

```bash
sha256sum -c SHA256SUMS.txt
# Expected output: each file: OK
```

### 2. Verify GPG signatures (provenance)
This project publishes a GPG public key in [`docs/KEYS.asc`](./docs/KEYS.asc) and signs release artifacts (`*.changes`, `*.buildinfo`).

Import the key and verify signatures:

```bash
# Import public key
curl -fsSL https://raw.githubusercontent.com/allbury2007/infra-packs/main/docs/KEYS.asc | gpg --import

# Verify .changes and .buildinfo (download them from the release)
gpg --verify restic-backup_0.1.1_amd64.changes
gpg --verify restic-backup_0.1.1_amd64.buildinfo
gpg --verify vpn-tools_0.1.1_amd64.changes
gpg --verify vpn-tools_0.1.1_amd64.buildinfo
gpg --verify ca-tools_0.1.1_amd64.changes
gpg --verify ca-tools_0.1.1_amd64.buildinfo
gpg --verify monitoring-rules_0.1.1_amd64.changes
gpg --verify monitoring-rules_0.1.1_amd64.buildinfo
```

Successful verification proves the packages were built and signed by the project’s author (matching the key in `docs/KEYS.asc`).

## Documentation

- [System Administrator Guide](docs/sysadmin-guide.md)
- [VPN User Guide](docs/vpn-user-guide.md)
- [Backup System](docs/backup-system.md)
- [Infrastructure Roadmap](docs/infrastructure-roadmap.md)

## License
MIT License — see [LICENSE](./LICENSE) for details.
