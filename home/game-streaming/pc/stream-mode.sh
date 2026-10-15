#!/usr/bin/env bash
# Streaming layout: only the phantom display (DP-3) at 3840x2160@120,
# scale 1.5 (same 2560x1440 logical desktop as the desk), SDR — the
# driver rejects HDR on the forced connector, and an SDR capture also
# ends the HDR-to-SDR washed-out stream problem. Physical panels are
# disabled, so stream input can never light them.
# Changes are applied stepwise: one atomic batch was rejected whole
# by the driver when it still contained the HDR request.
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/1000}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/1000/bus}"
if [ -z "${WAYLAND_DISPLAY:-}" ]; then
  for s in /run/user/1000/wayland-*; do
    case "$s" in *.lock) ;; *) WAYLAND_DISPLAY="$(basename "$s")"; export WAYLAND_DISPLAY; break ;; esac
  done
fi
mode_id() {
  kscreen-doctor -o 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | awk -v out="$1" -v want="$2" '
    /^Output:/ { cur = ($3 == out) }
    cur && /Modes:/ {
      line = $0
      while (match(line, /[0-9]+:[0-9]+x[0-9]+@[0-9.]+/)) {
        tok = substr(line, RSTART, RLENGTH)
        split(tok, a, ":")
        if (a[2] == want) { print a[1]; exit }
        line = substr(line, RSTART + RLENGTH)
      }
    }'
}
apply() {
  out="$(kscreen-doctor "$@" 2>&1)"
  case "$out" in *failed*) echo "stream-mode: FAILED at: $*" >&2; echo "$out" >&2; exit 1 ;; esac
  sleep 1
}
MID="$(mode_id DP-3 3840x2160@120.00)"
[ -z "$MID" ] && { echo "stream-mode: DP-3 4K120 mode not found" >&2; exit 1; }
apply output.DP-3.enable
apply output.DP-3.mode.$MID output.DP-3.scale.1.5 output.DP-3.position.0,0
apply output.DP-3.priority.1
apply output.DP-2.disable
apply output.DP-1.disable
echo "stream-mode: phantom DP-3 active (mode $MID), physical panels disabled"
systemctl --user restart app-dev.lizardbyte.app.Sunshine.service
nohup ~/.local/bin/phantom-watcher.sh >/dev/null 2>&1 &
