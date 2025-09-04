#!/usr/bin/env bash
set -euo pipefail

echo "== Plain IP ================"
curl -s https://api.ipify.org || echo "(curl failed)"

echo
echo "== Tor via SOCKS (curl --socks5-hostname 127.0.0.1:9050) =="
curl --socks5-hostname 127.0.0.1:9050 -s https://check.torproject.org/api/ip || echo "(curl failed)"

echo
echo "== Proxychains (pc curl) ==="
# Use proxychains if available; otherwise try proxychains4
if command -v proxychains &>/dev/null; then
  proxychains -q curl -s https://api.ipify.org || echo "(proxychains curl failed)"
elif command -v proxychains4 &>/dev/null; then
  proxychains4 -q curl -s https://api.ipify.org || echo "(proxychains4 curl failed)"
else
  echo "proxychains/proxychains4 not found"
fi

echo
echo "== DNS leak test (dig via proxychains) =="
if command -v dig &>/dev/null; then
  (proxychains4 dig +short A cloudflare.com 2>/dev/null) || echo "(proxychains dig failed or blocked)"
else
  echo "dig not installed (sudo apt install -y dnsutils)"
fi
