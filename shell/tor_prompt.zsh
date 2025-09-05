# Tor-mode prompt + pcsh function for zsh
autoload -U add-zsh-hook

# Remember base prompt so we can restore later
if [[ -z ${PROMPT_BASE+x} ]]; then
  PROMPT_BASE="$PROMPT"
fi

pc_prompt_guard() {
  if [[ -n "$PC_TOR_MODE" ]]; then
    PROMPT="%F{red}[ TOR ]%f $PROMPT_BASE"
    RPROMPT=""
  else
    PROMPT="$PROMPT_BASE"
  fi
}
add-zsh-hook precmd pc_prompt_guard

# Launch a proxychains-wrapped zsh after verifying Tor is listening
pcsh() {
  # ss -ltn : list listening TCP sockets; filter for port 9050
  if ! ss -ltn '( sport = :9050 )' | grep -q 9050; then
    echo "[pcsh] Tor is not listening on 127.0.0.1:9050."
    echo "       Start it: sudo systemctl start tor"
    return 1
  fi
  # PC_TOR_MODE=1 sets a flag for this shell and children; precmd hook paints the prompt
  PC_TOR_MODE=1 proxychains4 zsh -i
}
