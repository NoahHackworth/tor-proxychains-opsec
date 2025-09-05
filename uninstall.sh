#!/usr/bin/env bash
set -euo pipefail

echo "Reverting proxychains.conf if backup exists..."
if [ -f /etc/proxychains.conf.bak ]; then
  sudo mv -v /etc/proxychains.conf.bak /etc/proxychains.conf
fi

echo "Removing Zsh injection from ~/.zshrc..."
if [ -f "$HOME/.zshrc" ]; then
  sed -i '/### TOR_PROXYCHAINS_OPSEC_BEGIN/,/### TOR_PROXYCHAINS_OPSEC_END/d' "$HOME/.zshrc"
fi

echo "Removing helper files..."
rm -rf "$HOME/.tor-proxychains-opsec"
rm -f "$HOME/.local/bin/pcsh" "$HOME/.local/bin/torcheck"

echo "Optional: remove packages with 'sudo apt remove tor proxychains4 torsocks'"
echo "Done."
