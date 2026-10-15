#!/bin/bash
# Wake the gaming PC through the NAS wake script (which also blanks the
# PC monitors), switch it to the phantom streaming display, wait for
# Sunshine, then open Moonlight.
LOG="$HOME/.local/share/moonlight-wake.log"
mkdir -p "$(dirname "$LOG")"
NAS_SSH=(ssh -i "$HOME/.ssh/id_ed25519_nas" -o ConnectTimeout=10 -o BatchMode=yes chilly@100.126.218.82)
{
  echo "[$(date)] starting"
  # The ~ path is expanded by the NAS shell over ssh, not on this Mac.
  # shellcheck disable=SC2088
  "${NAS_SSH[@]}" "~/.config/dotfiles-scripts/wake-pc.sh" 2>&1 | tail -2
  "${NAS_SSH[@]}" "ssh -o BatchMode=yes -o ConnectTimeout=8 chilly@100.91.239.107 '~/.local/bin/stream-mode.sh'" 2>&1 | tail -1
  for i in $(seq 1 45); do
    if nc -z -G 2 100.91.239.107 47989 2>/dev/null; then echo "[$(date)] sunshine up after ${i} tries"; break; fi
    sleep 2
  done
  open -a Moonlight
  echo "[$(date)] moonlight opened"
} >> "$LOG" 2>&1
