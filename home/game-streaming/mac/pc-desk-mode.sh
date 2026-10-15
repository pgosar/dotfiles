#!/bin/bash
# Restore the PC's physical desk displays via the NAS -> PC ssh path.
LOG="$HOME/.local/share/pc-desk-mode.log"
mkdir -p "$(dirname "$LOG")"
{
  echo "[$(date)] desk mode requested"
  ssh -i "$HOME/.ssh/id_ed25519_nas" -o ConnectTimeout=10 -o BatchMode=yes chilly@100.126.218.82 "ssh -o BatchMode=yes -o ConnectTimeout=8 chilly@100.91.239.107 '~/.local/bin/desk-mode.sh'" 2>&1 | tail -1
} >> "$LOG" 2>&1
