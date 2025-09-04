#!/usr/bin/env bash
# Convenience launcher if you prefer a standalone command (same behavior as function)
if ! ss -ltn '( sport = :9050 )' | grep -q 9050; then
  echo "[pcsh] Tor is not listening on 127.0.0.1:9050."
  echo "       Start it: sudo systemctl start tor"
  exit 1
fi
# Export the same flag the zsh snippet uses to paint the prompt
export PC_TOR_MODE=1
exec proxychains4 zsh -i
