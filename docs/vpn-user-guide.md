# VPN User Guide

This guide explains how to use your OpenVPN profile to connect securely.

## What you receive
- A personal **.ovpn** profile (sometimes embedded with certs/keys).
- Delivered via a one-time secure link (e.g., PrivateBin).

## Install the client
### Windows
1. Download and install **OpenVPN Community Client**: https://openvpn.net/community-downloads/
2. Save your `.ovpn` file to:
   ```
   C:\Users\<YourName>\OpenVPN\config
   ```
3. Start **OpenVPN GUI**, then right‑click the tray icon to see your profile.

### macOS
- Install **Tunnelblick**: https://tunnelblick.net/  
- Double‑click the `.ovpn` file to import.

### Linux
- Install `openvpn` from your distro. Connect with:
  ```bash
  sudo openvpn --config /path/to/your.ovpn
  ```

### iOS / Android
- Install **OpenVPN Connect** from the App Store / Google Play.
- Import the `.ovpn` (open the file on the device or share via Files/Drive).

## Connect / Disconnect
- Click **Connect** on your profile, enter credentials if prompted.
- Click **Disconnect** when done.

## Updating / Removing a profile
- If you receive a new `.ovpn`, remove the old one from the config folder.
- On Windows, profiles are listed from the folder above; deleting the `.ovpn` removes it from the tray menu.

## Troubleshooting
- **Cannot connect**: check internet, try again; ensure correct profile.
- **DNS issues**: reconnect; contact IT if internal names don’t resolve.
- **Expired/Revoked cert**: request a fresh profile from IT.
