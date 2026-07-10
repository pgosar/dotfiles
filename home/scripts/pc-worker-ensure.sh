#!/usr/bin/env bash
set -euo pipefail

PC_HOST="${PC_HOST:-pc}"
PC_IP="${PC_IP:-pc}"
PC_WORKER_DIR="${PC_WORKER_DIR:-~/docker/pc-workers}"
LOG_FILE="${LOG_FILE:-/data/docker/appdata/nightly-orchestrator/pc-worker-ensure.log}"
WAKE_SCRIPT="${WAKE_SCRIPT:-$HOME/.config/dotfiles-scripts/wake-pc}"
SSH_CONNECT_TIMEOUT="${SSH_CONNECT_TIMEOUT:-5}"
SSH_WAIT_SECONDS="${SSH_WAIT_SECONDS:-300}"
SERVICE_WAIT_SECONDS="${SERVICE_WAIT_SECONDS:-180}"
AUTO_WAKE_BOOT_ID_FILE="${AUTO_WAKE_BOOT_ID_FILE:-/data/docker/appdata/nightly-orchestrator/pc-auto-wake-boot-id}"
CHECK_TDARR="${CHECK_TDARR:-false}"
CHECK_IMMICH_ML="${CHECK_IMMICH_ML:-false}"
IMMICH_ML_URL="${IMMICH_ML_URL:-http://$PC_IP:3003}"
NIGHT_ONLY="${NIGHT_ONLY:-true}"
NIGHT_START="${NIGHT_START:-04:00}"
NIGHT_END="${NIGHT_END:-10:00}"

log() {
  mkdir -p "$(dirname "$LOG_FILE")"
  printf '%s %s\n' "$(date -Is)" "$*" | tee -a "$LOG_FILE"
}

pc_reachable() {
  ssh -o BatchMode=yes -o ConnectTimeout="$SSH_CONNECT_TIMEOUT" "$PC_HOST" 'true' >/dev/null 2>&1
}

record_auto_wake_boot_id() {
  local boot_id temp_file
  boot_id="$(ssh -o BatchMode=yes -o ConnectTimeout="$SSH_CONNECT_TIMEOUT" "$PC_HOST" \
    'cat /proc/sys/kernel/random/boot_id')"
  if [[ ! "$boot_id" =~ ^[0-9a-fA-F-]{36}$ ]]; then
    log "warning: PC returned an invalid boot ID; automatic shutdown will remain disabled"
    return 1
  fi

  mkdir -p "$(dirname "$AUTO_WAKE_BOOT_ID_FILE")"
  temp_file="${AUTO_WAKE_BOOT_ID_FILE}.tmp.$$"
  printf '%s\n' "$boot_id" >"$temp_file"
  mv -f "$temp_file" "$AUTO_WAKE_BOOT_ID_FILE"
  log "Recorded automatic wake ownership for the current PC boot"
}

minutes_since_midnight() {
  local value="$1"
  printf '%d\n' "$((10#${value%:*} * 60 + 10#${value#*:}))"
}

in_night_window() {
  local now start end
  now="$(minutes_since_midnight "$(date +%H:%M)")"
  start="$(minutes_since_midnight "$NIGHT_START")"
  end="$(minutes_since_midnight "$NIGHT_END")"

  if [ "$start" -eq "$end" ]; then
    return 0
  elif [ "$start" -lt "$end" ]; then
    [ "$now" -ge "$start" ] && [ "$now" -lt "$end" ]
  else
    [ "$now" -ge "$start" ] || [ "$now" -lt "$end" ]
  fi
}

wait_for_pc() {
  local deadline
  deadline=$((SECONDS + SSH_WAIT_SECONDS))
  while [ "$SECONDS" -lt "$deadline" ]; do
    if pc_reachable; then
      return 0
    fi
    sleep 5
  done
  return 1
}

pc_container_running() {
  local container="$1"
  ssh -o BatchMode=yes -o ConnectTimeout="$SSH_CONNECT_TIMEOUT" "$PC_HOST" \
    "docker inspect -f '{{.State.Running}}' '$container' 2>/dev/null | grep -qx true"
}

start_worker_service() {
  local service="$1"
  ssh -o BatchMode=yes -o ConnectTimeout="$SSH_CONNECT_TIMEOUT" "$PC_HOST" \
    "cd $PC_WORKER_DIR && docker compose up -d '$service'"
}

wait_for_url() {
  local url="$1"
  local deadline
  deadline=$((SECONDS + SERVICE_WAIT_SECONDS))
  while [ "$SECONDS" -lt "$deadline" ]; do
    if curl -fsS --max-time 5 "$url" >/dev/null 2>&1; then
      return 0
    fi
    sleep 5
  done
  return 1
}

wait_for_tdarr_node() {
  local deadline
  deadline=$((SECONDS + SERVICE_WAIT_SECONDS))
  while [ "$SECONDS" -lt "$deadline" ]; do
    if ssh -o BatchMode=yes -o ConnectTimeout="$SSH_CONNECT_TIMEOUT" "$PC_HOST" \
      'docker inspect -f "{{.State.Running}}" tdarr-node-pc 2>/dev/null | grep -qx true'; then
      return 0
    fi
    sleep 5
  done
  return 1
}

if [ "$NIGHT_ONLY" = "true" ] && ! in_night_window; then
  log "Outside worker window ${NIGHT_START}-${NIGHT_END}; not waking or starting PC workers"
  exit 0
fi

pc_was_woken=false
if ! pc_reachable; then
  log "PC is not reachable; dispatching Wake-on-LAN"
  wake_dispatched=false
  if "$WAKE_SCRIPT" >>"$LOG_FILE" 2>&1; then
    wake_dispatched=true
  else
    log "Wake-on-LAN dispatch reported an error; automatic shutdown will remain disabled"
  fi
  if ! wait_for_pc; then
    log "PC did not become reachable within ${SSH_WAIT_SECONDS}s"
    exit 1
  fi
  pc_was_woken="$wake_dispatched"
fi

if [ "$pc_was_woken" = "true" ]; then
  record_auto_wake_boot_id || true
fi

if [ "$CHECK_TDARR" = "true" ]; then
  if pc_container_running tdarr-node-pc; then
    log "Tdarr PC node container is already running"
  else
    log "Starting Tdarr PC node"
    start_worker_service tdarr-node >>"$LOG_FILE" 2>&1
  fi
fi

if [ "$CHECK_IMMICH_ML" = "true" ]; then
  if pc_container_running immich_machine_learning_pc; then
    log "Immich PC ML container is already running"
  else
    log "Starting Immich PC ML"
    start_worker_service immich-machine-learning-pc >>"$LOG_FILE" 2>&1
  fi
fi

if [ "$CHECK_TDARR" != "true" ] && [ "$CHECK_IMMICH_ML" != "true" ]; then
  log "No specific worker requested; starting full worker compose stack"
  start_worker_service tdarr-node >>"$LOG_FILE" 2>&1
  start_worker_service immich-machine-learning-pc >>"$LOG_FILE" 2>&1
fi

if [ "$CHECK_TDARR" = "true" ]; then
  if wait_for_tdarr_node; then
    log "Tdarr PC node is running"
  else
    log "Tdarr PC node did not become ready within ${SERVICE_WAIT_SECONDS}s"
    exit 1
  fi
fi

if [ "$CHECK_IMMICH_ML" = "true" ]; then
  if wait_for_url "$IMMICH_ML_URL"; then
    log "Immich PC ML endpoint is reachable at $IMMICH_ML_URL"
  else
    log "Immich PC ML endpoint did not become ready within ${SERVICE_WAIT_SECONDS}s"
    exit 1
  fi
fi

log "PC worker ensure complete"
