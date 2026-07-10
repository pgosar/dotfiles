#!/usr/bin/env bash
set -euo pipefail

PC_HOST="${PC_HOST:-pc}"
PC_IP="${PC_IP:-192.168.1.197}"
WINDOW_START="${WINDOW_START:-04:00}"
WINDOW_END="${WINDOW_END:-10:00}"
LOG_FILE="${LOG_FILE:-/data/docker/appdata/nightly-orchestrator/nightly-pc-jobs.log}"
STOP_OUTSIDE_WINDOW="${STOP_OUTSIDE_WINDOW:-true}"
AUTO_WAKE_BOOT_ID_FILE="${AUTO_WAKE_BOOT_ID_FILE:-/data/docker/appdata/nightly-orchestrator/pc-auto-wake-boot-id}"

log() {
  mkdir -p "$(dirname "$LOG_FILE")"
  printf '%s %s\n' "$(date -Is)" "$*" | tee -a "$LOG_FILE"
}

minutes() {
  IFS=: read -r h m <<EOF
$1
EOF
  printf '%s\n' "$((10#$h * 60 + 10#$m))"
}

in_window() {
  local now start end
  now="$(date +%H:%M)"
  now="$(minutes "$now")"
  start="$(minutes "$WINDOW_START")"
  end="$(minutes "$WINDOW_END")"
  if [ "$start" -le "$end" ]; then
    [ "$now" -ge "$start" ] && [ "$now" -lt "$end" ]
  else
    [ "$now" -ge "$start" ] || [ "$now" -lt "$end" ]
  fi
}

pc_reachable() {
  ssh -o BatchMode=yes -o ConnectTimeout=5 "$PC_HOST" 'true' >/dev/null 2>&1
}

pc_idle() {
  ssh -o BatchMode=yes -o ConnectTimeout=5 "$PC_HOST" '
    set -eu
    if loginctl list-sessions --no-legend 2>/dev/null | grep -q " seat0 "; then
      idle_hint="$(loginctl show-user "$USER" -p IdleHint --value 2>/dev/null || true)"
      [ "$idle_hint" = "yes" ]
    fi
  '
}

record_auto_wake_boot_id() {
  local boot_id temp_file
  boot_id="$(ssh -o BatchMode=yes -o ConnectTimeout=5 "$PC_HOST" \
    'cat /proc/sys/kernel/random/boot_id')"
  if [[ ! "$boot_id" =~ ^[0-9a-fA-F-]{36}$ ]]; then
    log "warning: PC returned an invalid boot ID; automatic shutdown will remain disabled"
    return 1
  fi

  mkdir -p "$(dirname "$AUTO_WAKE_BOOT_ID_FILE")"
  temp_file="${AUTO_WAKE_BOOT_ID_FILE}.tmp.$$"
  printf '%s\n' "$boot_id" >"$temp_file"
  mv -f "$temp_file" "$AUTO_WAKE_BOOT_ID_FILE"
  log "recorded automatic wake ownership for the current PC boot"
}

if ! in_window; then
  if [ "$STOP_OUTSIDE_WINDOW" = "true" ] && pc_reachable; then
    log "outside nightly window $WINDOW_START-$WINDOW_END; stopping PC workers"
    ssh -o BatchMode=yes "$PC_HOST" 'cd ~/docker/pc-workers && docker compose down' >>"$LOG_FILE" 2>&1 || true
  fi
  log "outside nightly window $WINDOW_START-$WINDOW_END; skipping"
  exit 0
fi

pc_was_woken=false
if ! pc_reachable; then
  log "PC is not reachable; waking it"
  "$HOME/.config/dotfiles-scripts/wake-pc"
  for _ in $(seq 1 60); do
    pc_reachable && break
    sleep 10
  done
  pc_was_woken=true
fi

if ! pc_reachable; then
  log "PC did not become reachable; skipping"
  exit 0
fi

if [ "$pc_was_woken" = "true" ]; then
  record_auto_wake_boot_id || true
fi

if ! pc_idle; then
  log "PC appears active; skipping worker start"
  exit 0
fi

log "starting PC workers"
ssh -o BatchMode=yes "$PC_HOST" 'cd ~/docker/pc-workers && docker compose up -d'
