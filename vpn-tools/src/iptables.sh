#!/usr/bin/env bash
set -Eeuo pipefail
# Usage: sudo iptables.sh <wan-iface> <proto> <port>
# Example: sudo iptables.sh eth0 udp 1194
eth="${1:-eth0}"; proto="${2:-udp}"; port="${3:-1194}"
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i "$eth" -m state --state NEW -p "$proto" --dport "$port" -j ACCEPT
iptables -A INPUT -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -o "$eth" -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i "$eth" -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o "$eth" -j MASQUERADE
if command -v netfilter-persistent >/dev/null 2>&1; then
  iptables-save > /etc/iptables/rules.v4
  netfilter-persistent save || true
else
  iptables-save > /etc/iptables/rules.v4
  echo "[INFO] Saved to /etc/iptables/rules.v4. Consider: apt install iptables-persistent"
fi
echo "[DONE] iptables rules applied for OpenVPN on ${eth}/${proto}/${port}"
