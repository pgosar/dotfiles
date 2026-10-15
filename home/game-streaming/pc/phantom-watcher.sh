#!/usr/bin/env bash
# Backstop for the phantom streaming layout: while stream mode is on,
# watch the stream's conntrack flows. Once a stream has been seen and
# the flows have then been absent for ~3 minutes, restore the desk
# layout. Exits on its own if the desk layout is already back.
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/1000}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/1000/bus}"
if [ -z "${WAYLAND_DISPLAY:-}" ]; then
  for s in /run/user/1000/wayland-*; do
    case "$s" in *.lock) ;; *) WAYLAND_DISPLAY="$(basename "$s")"; export WAYLAND_DISPLAY; break ;; esac
  done
fi
STATE_DIR="$HOME/.local/state"
mkdir -p "$STATE_DIR"
LOG="$STATE_DIR/phantom-watcher.log"
PIDFILE="$STATE_DIR/phantom-watcher.pid"
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then exit 0; fi
echo "$$" > "$PIDFILE"
trap 'rm -f "$PIDFILE"' EXIT
stream_active() {
  sudo -n grep -aE "dport=(47998|47999|48000)([^0-9]|$)" /proc/net/nf_conntrack 2>/dev/null | grep -q "ASSURED"
}
in_stream_mode() {
  kscreen-doctor -o 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | awk '/^Output:/ {o=$3} /^\t(enabled|disabled)$/ {if (o=="DP-2") print $1}' | grep -q disabled
}
echo "$(date '+%F %T') watcher started" >> "$LOG"
seen=0
absent=0
for i in $(seq 1 1440); do
  if ! in_stream_mode; then
    echo "$(date '+%F %T') desk layout already active, watcher exiting" >> "$LOG"
    exit 0
  fi
  if stream_active; then
    if [ "$seen" = 0 ]; then echo "$(date '+%F %T') stream seen" >> "$LOG"; fi
    seen=1
    absent=0
  elif [ "$seen" = 1 ]; then
    absent=$((absent+1))
    if [ "$absent" -ge 36 ]; then
      echo "$(date '+%F %T') stream gone for ~3 min, restoring desk layout" >> "$LOG"
      "$HOME/.local/bin/desk-mode.sh" >> "$LOG" 2>&1
      exit 0
    fi
  else
    # No stream yet: give it 10 minutes to start, then restore desk.
    if [ "$i" -ge 120 ]; then
      echo "$(date '+%F %T') no stream started within 10 min, restoring desk layout" >> "$LOG"
      "$HOME/.local/bin/desk-mode.sh" >> "$LOG" 2>&1
      exit 0
    fi
  fi
  sleep 5
done
echo "$(date '+%F %T') watcher timed out, exiting" >> "$LOG"
