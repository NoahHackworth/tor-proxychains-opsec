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
```
## After you clone on Linux, Run:


Run these once:

1) Make scripts executable (so the kernel can run them directly)
```
chmod +x install.sh uninstall.sh shell/pcsh shell/torcheck
```
2) Install (explained):
- ./install.sh runs with bash (shebang selects /usr/bin/env bash)
- It installs Tor/proxychains/torsocks, writes configs, adds zsh hooks, restarts Tor
```
./install.sh
```
3) Load your new shell config without restarting the terminal
```
source ~/.zshrc
```
4) Enter TOR mode shell (proxychains-wrapped) — prompt shows [ TOR ]
```
pcsh
```
5) Verify routing (prints plain IP, Tor-over-SOCKS IP, proxychains IP, and DNS test)
```
torcheck
```
## All these in one commad:
```
chmod +x install.sh uninstall.sh shell/pcsh shell/torcheck
./install.sh
source ~/.zshrc
pcsh
torcheck
```
