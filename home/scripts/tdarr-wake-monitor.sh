#!/usr/bin/env bash
set -euo pipefail

NAS_LAN_IP="${NAS_LAN_IP:-192.168.1.196}"
TDARR_URL="${TDARR_URL:-http://$NAS_LAN_IP:8266}"
TDARR_API_KEY="${TDARR_API_KEY:-}"
TDARR_ENV_FILE="${TDARR_ENV_FILE:-/data/docker/compose/tdarr/.env}"
ENSURE_SCRIPT="${ENSURE_SCRIPT:-/data/docker/compose/nightly-orchestrator/pc-worker-ensure.sh}"
LOG_FILE="${LOG_FILE:-/data/docker/appdata/nightly-orchestrator/tdarr-wake-monitor.log}"
LOCK_FILE="${LOCK_FILE:-/tmp/tdarr-wake-monitor.lock}"
PC_HOST="${PC_HOST:-pc}"
PC_WORKER_DIR="${PC_WORKER_DIR:-~/docker/pc-workers}"
SSH_CONNECT_TIMEOUT="${SSH_CONNECT_TIMEOUT:-5}"
NIGHT_START="${NIGHT_START:-04:00}"
NIGHT_END="${NIGHT_END:-10:00}"
STOP_WORKERS_OUTSIDE_WINDOW="${STOP_WORKERS_OUTSIDE_WINDOW:-true}"
STOP_WORKERS_WHEN_IDLE="${STOP_WORKERS_WHEN_IDLE:-true}"
POWEROFF_PC_WHEN_IDLE="${POWEROFF_PC_WHEN_IDLE:-true}"
PC_POWEROFF_COMMAND="${PC_POWEROFF_COMMAND:-sudo -n systemctl poweroff}"
BLOCK_REMOTE_USER_SESSIONS="${BLOCK_REMOTE_USER_SESSIONS:-true}"
IMMICH_LAST_REQUEST_FILE="${IMMICH_LAST_REQUEST_FILE:-/data/docker/appdata/nightly-orchestrator/immich-ml-last-request}"
IMMICH_ACTIVE_REQUESTS_FILE="${IMMICH_ACTIVE_REQUESTS_FILE:-/data/docker/appdata/nightly-orchestrator/immich-ml-active-requests}"
IMMICH_IDLE_SECONDS="${IMMICH_IDLE_SECONDS:-1800}"
AUTO_WAKE_BOOT_ID_FILE="${AUTO_WAKE_BOOT_ID_FILE:-/data/docker/appdata/nightly-orchestrator/pc-auto-wake-boot-id}"

log() {
  mkdir -p "$(dirname "$LOG_FILE")"
  printf '%s %s\n' "$(date -Is)" "$*" >>"$LOG_FILE"
}

load_api_key() {
  if [ -n "$TDARR_API_KEY" ]; then
    return 0
  fi
  if [ -f "$TDARR_ENV_FILE" ]; then
    TDARR_API_KEY="$(awk -F= '/^TDARR_API_KEY=/{print $2}' "$TDARR_ENV_FILE" | tail -1)"
  fi
  if [ -z "$TDARR_API_KEY" ] && [ -f /data/docker/appdata/tdarr/configs/Tdarr_Server_Config.json ]; then
    TDARR_API_KEY="$(jq -r '.seededApiKey // empty' /data/docker/appdata/tdarr/configs/Tdarr_Server_Config.json)"
  fi
  [ -n "$TDARR_API_KEY" ]
}

tdarr_post() {
  curl -fsS --max-time 15 \
    -H "x-api-key: $TDARR_API_KEY" \
    -H "Content-Type: application/json" \
    "$TDARR_URL/api/v2/cruddb" \
    -d "$1"
}

tdarr_work_count() {
  local response
  if ! response="$(tdarr_post '{"data":{"collection":"FileJSONDB","mode":"getAll"}}')"; then
    log "Tdarr API query failed at $TDARR_URL"
    return 2
  fi
  jq '[.[] | select(
      ((.TranscodeDecisionMaker // "") | test("Queued|Staged|Transcoding|Processing"; "i")) or
      ((.HealthCheck // "") | test("Queued|Staged|Transcoding|Processing"; "i")) or
      ((.ProcessingStatus // "") | test("Queued|Staged|Transcoding|Processing"; "i")) or
      ((.Status // "") | test("Queued|Staged|Transcoding|Processing"; "i"))
    )] | length' <<<"$response"
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

pc_reachable() {
  ssh -o BatchMode=yes -o ConnectTimeout="$SSH_CONNECT_TIMEOUT" "$PC_HOST" 'true' >/dev/null 2>&1
}

stop_pc_workers() {
  ssh -o BatchMode=yes -o ConnectTimeout="$SSH_CONNECT_TIMEOUT" "$PC_HOST" \
    "cd $PC_WORKER_DIR && docker compose stop tdarr-node immich-machine-learning-pc >/dev/null 2>&1"
}

has_work() {
  local count
  count="$(tdarr_work_count)" || return 2
  [ "${count:-0}" -gt 0 ]
}

pc_wake_is_automatic() {
  local expected_boot_id current_boot_id
  [ -f "$AUTO_WAKE_BOOT_ID_FILE" ] || return 1
  expected_boot_id="$(tr -dc '0-9a-fA-F-' <"$AUTO_WAKE_BOOT_ID_FILE")"
  current_boot_id="$(ssh -o BatchMode=yes -o ConnectTimeout="$SSH_CONNECT_TIMEOUT" "$PC_HOST" \
    'cat /proc/sys/kernel/random/boot_id' 2>/dev/null || true)"
  if [ -n "$expected_boot_id" ] && [ "$current_boot_id" = "$expected_boot_id" ]; then
    return 0
  fi

  log "PC boot does not match automatic wake ownership; leaving it powered on"
  rm -f "$AUTO_WAKE_BOOT_ID_FILE"
  return 1
}

immich_recent_or_active() {
  local active now mtime age
  if [ -f "$IMMICH_ACTIVE_REQUESTS_FILE" ]; then
    active="$(tr -dc '0-9' <"$IMMICH_ACTIVE_REQUESTS_FILE" || true)"
    if [ "${active:-0}" -gt 0 ]; then
      log "Immich ML has ${active} active request(s); not stopping PC"
      return 0
    fi
  fi

  if [ ! -e "$IMMICH_LAST_REQUEST_FILE" ]; then
    return 1
  fi

  now="$(date +%s)"
  mtime="$(stat -c %Y "$IMMICH_LAST_REQUEST_FILE")"
  age="$((now - mtime))"
  if [ "$age" -lt "$IMMICH_IDLE_SECONDS" ]; then
    log "Immich ML was active ${age}s ago; waiting for ${IMMICH_IDLE_SECONDS}s idle"
    return 0
  fi
  return 1
}

pc_user_active() {
  ssh -o BatchMode=yes -o ConnectTimeout="$SSH_CONNECT_TIMEOUT" "$PC_HOST" \
    "BLOCK_REMOTE_USER_SESSIONS=$BLOCK_REMOTE_USER_SESSIONS bash -s" <<'REMOTE'
set -euo pipefail
self_sid=""
if [ -f /proc/self/sessionid ]; then
  self_sid="$(cat /proc/self/sessionid)"
fi
self_sid="${self_sid:-$XDG_SESSION_ID}"

while read -r sid uid _user seat _rest; do
  [ -n "${sid:-}" ] || continue
  if [ -n "$self_sid" ] && [ "$sid" = "$self_sid" ]; then
    continue
  fi
  class="$(loginctl show-session "$sid" -p Class --value 2>/dev/null || true)"
  remote="$(loginctl show-session "$sid" -p Remote --value 2>/dev/null || true)"
  active="$(loginctl show-session "$sid" -p Active --value 2>/dev/null || true)"
  idle="$(loginctl show-session "$sid" -p IdleHint --value 2>/dev/null || true)"
  [ "$class" != "greeter" ] || continue
  [ "$class" = "user" ] || continue
  [ "${uid:-0}" -ge 1000 ] || continue
  if { [ "$seat" != "-" ] && [ -n "$seat" ] && [ "$active" = "yes" ] && [ "$idle" = "no" ]; } ||
     { [ "${BLOCK_REMOTE_USER_SESSIONS:-false}" = "true" ] && [ "$remote" = "yes" ]; }; then
    exit 0
  fi
done < <(loginctl list-sessions --no-legend 2>/dev/null || true)
exit 1
REMOTE
}

cleanup_idle_pc() {
  local tdarr_state="$1"

  if [ "$tdarr_state" != "idle" ]; then
    return 0
  fi
  if ! pc_reachable; then
    return 0
  fi
  if ! pc_wake_is_automatic; then
    return 0
  fi
  if immich_recent_or_active; then
    return 0
  fi
  if pc_user_active; then
    log "PC has an active user session; not stopping workers or powering off"
    return 0
  fi

  if [ "$STOP_WORKERS_WHEN_IDLE" = "true" ]; then
    stop_pc_workers || log "failed to stop idle PC worker containers"
  fi
  if [ "$POWEROFF_PC_WHEN_IDLE" = "true" ]; then
    log "Tdarr and Immich workers are idle; powering off PC"
    if ssh -o BatchMode=yes -o ConnectTimeout="$SSH_CONNECT_TIMEOUT" "$PC_HOST" \
      "$PC_POWEROFF_COMMAND" >/dev/null 2>&1; then
      rm -f "$AUTO_WAKE_BOOT_ID_FILE"
    else
      log "failed to power off PC"
    fi
  fi
}

exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  exit 0
fi

if ! load_api_key; then
  log "no Tdarr API key available"
  exit 1
fi

tdarr_state="unknown"

if ! in_night_window; then
  if [ "$STOP_WORKERS_OUTSIDE_WINDOW" = "true" ] && pc_reachable; then
    stop_pc_workers || log "failed to stop PC worker containers outside ${NIGHT_START}-${NIGHT_END}"
  fi
  tdarr_state="idle"
  cleanup_idle_pc "$tdarr_state"
  exit 0
fi

if has_work; then
  tdarr_state="busy"
  log "Tdarr has queued/staged work; ensuring PC worker stack"
  CHECK_TDARR=true "$ENSURE_SCRIPT" >>"$LOG_FILE" 2>&1 || log "pc-worker-ensure failed"
else
  case "$?" in
    0)
      tdarr_state="idle"
      ;;
    1)
      tdarr_state="idle"
      ;;
    *)
      tdarr_state="unknown"
      ;;
  esac
fi

cleanup_idle_pc "$tdarr_state"
