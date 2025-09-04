# Tor + Proxychains OPSEC Shell

One-command setup for a **Tor + proxychains** workflow in Kali (or Debian/Ubuntu):
- Installs/starts Tor
- Drops in a hardened `proxychains.conf` (DNS over proxy, dynamic chaining, sane timeouts)
- Adds a **[ TOR ]** visual prompt for a dedicated proxychains-wrapped Zsh shell
- Provides `pc` alias (`proxychains4`) and `pcsh` (“Tor mode” shell)
- Includes `torcheck` to verify paths (plain vs SOCKS vs proxychains)

> ⚠️ OPSEC: `sudo` usually disables `LD_PRELOAD`, so commands run with `sudo` will **bypass proxychains**. Use `pcsh` for networking and avoid `sudo` there.

## Usage Instructions

1) Install once:
./install.sh

2) New shell (or source ~/.zshrc), then start Tor mode:
pcsh

3) Verify routing:
torcheck

4) Use shorthand:
pc nmap -sT example.com
pc curl https://api.ipify.org

## Quick start

```bash
git clone https://github.com/yourname/tor-proxychains-opsec.git
cd tor-proxychains-opsec
chmod +x install.sh
./install.sh
