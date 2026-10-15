#!/usr/bin/env bash
# Desk layout: main panel DP-2 (3840x2160@239.99, scale 1.5, primary) at
# 0,0 and DP-1 (2560x1440@179.95, scale 1) to its right. Phantom disabled.
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/1000}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/1000/bus}"
if [ -z "${WAYLAND_DISPLAY:-}" ]; then
  for s in /run/user/1000/wayland-*; do
    case "$s" in *.lock) ;; *) WAYLAND_DISPLAY="$(basename "$s")"; export WAYLAND_DISPLAY; break ;; esac
  done
fi
mode_id() {
  # $1 = output name, $2 = mode spec e.g. 3840x2160@239.99
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
M2="$(mode_id DP-2 3840x2160@239.99)"
M1="$(mode_id DP-1 2560x1440@179.95)"
[ -z "$M2" ] || [ -z "$M1" ] && { echo "desk-mode: panel modes not found" >&2; exit 1; }
kscreen-doctor output.DP-2.enable output.DP-2.priority.1 output.DP-2.position.0,0 output.DP-2.mode.$M2 output.DP-2.scale.1.5 output.DP-1.enable output.DP-1.priority.2 output.DP-1.position.2560,0 output.DP-1.mode.$M1 output.DP-1.scale.1 output.DP-3.disable
echo "desk-mode: physical panels restored (DP-2 mode $M2, DP-1 mode $M1), phantom disabled"
systemctl --user restart app-dev.lizardbyte.app.Sunshine.service
sleep 2
kscreen-doctor --dpms off >/dev/null 2>&1
echo "desk-mode: panels left dark until local input"
