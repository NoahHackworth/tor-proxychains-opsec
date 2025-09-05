#!/usr/bin/env bash
set -euo pipefail

# --- Helper: print section
section() { printf "\n\033[1;34m==> %s\033[0m\n" "$*"; }

section "Installing packages (tor, proxychains4, torsocks)"
# sudo: escalate once here; explain flags:
# -y auto-confirms; it's safe here to avoid interactive prompts in automation
sudo apt update && sudo apt install -y tor proxychains4 torsocks zsh curl

section "Enabling and starting Tor service"
# systemctl enable: start at boot; start: run now
sudo systemctl enable tor
sudo systemctl start tor || sudo systemctl start tor@default

section "Verifying Tor is listening on 9050"
if ! ss -ltn '( sport = :9050 )' | grep -q 9050; then
  echo "Tor doesn't appear to be listening on 127.0.0.1:9050."
  echo "Check Tor logs: sudo journalctl -u tor -n 100"
  exit 1
fi

# Paths
REPO_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
CONF_DST="/etc/proxychains.conf"
CONF_SRC="$REPO_DIR/config/proxychains.conf"
TOR_APPEND_SRC="$REPO_DIR/config/torrc.append"
ZSH_SNIPPET="$REPO_DIR/shell/tor_prompt.zsh"
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

section "Installing hardened proxychains.conf"
# backup existing once
if [ -f "$CONF_DST" ] && [ ! -f "${CONF_DST}.bak" ]; then
  sudo cp -v "$CONF_DST" "${CONF_DST}.bak"
fi
sudo cp -v "$CONF_SRC" "$CONF_DST"

section "Appending minimal Tor options (IPv4 only toggle is optional)"
# Append lines if not already present
sudo grep -q "^# Added by tor-proxychains-opsec" /etc/tor/torrc 2>/dev/null || \
  (echo "" | sudo tee -a /etc/tor/torrc >/dev/null && \
   sudo tee -a /etc/tor/torrc < "$TOR_APPEND_SRC" >/dev/null)

section "Installing helper scripts (pcsh, torcheck)"
install -m 0755 "$REPO_DIR/shell/pcsh" "$BIN_DIR/pcsh"
install -m 0755 "$REPO_DIR/shell/torcheck" "$BIN_DIR/torcheck"

# Ensure ~/.local/bin is in PATH for zsh
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
fi

section "Injecting Zsh prompt + alias into ~/.zshrc"
# Add alias 'pc' (proxychains4) and the prompt guard + pcsh function
if ! grep -q "### TOR_PROXYCHAINS_OPSEC_BEGIN" "$HOME/.zshrc" 2>/dev/null; then
  cat >> "$HOME/.zshrc" <<'EOF'

### TOR_PROXYCHAINS_OPSEC_BEGIN
# Shorthand: 'pc' runs proxychains4 with the provided command.
alias pc='proxychains4'

# Load Tor-mode prompt + pcsh launcher
source "$HOME/.tor-proxychains-opsec/tor_prompt.zsh" 2>/dev/null || true
### TOR_PROXYCHAINS_OPSEC_END
EOF
fi

# Place the snippet in a dot-folder so sourcing path is stable
mkdir -p "$HOME/.tor-proxychains-opsec"
cp -v "$ZSH_SNIPPET" "$HOME/.tor-proxychains-opsec/tor_prompt.zsh"

section "Restarting Tor to apply torrc additions (if any)"
sudo systemctl restart tor || true

section "Done!"
echo "Open a new terminal (or 'source ~/.zshrc') and run: pcsh"
echo "Then check routing with: torcheck"
