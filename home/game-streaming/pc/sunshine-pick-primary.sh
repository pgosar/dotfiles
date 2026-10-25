#!/usr/bin/env bash
# Point Sunshine at whichever output KDE currently calls primary.
# Connector names (DP-1/DP-2) can shuffle across reboots; priority does not lie.
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/1000}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/1000/bus}"
if [ -z "${WAYLAND_DISPLAY:-}" ]; then
  for s in /run/user/1000/wayland-*; do
    case "$s" in *.lock) ;; *) export WAYLAND_DISPLAY="$(basename "$s")"; break ;; esac
  done
fi
CONF="$HOME/.config/sunshine/sunshine.conf"
primary=""
for attempt in $(seq 1 10); do
  primary="$(kscreen-doctor -o 2>/dev/null | sed "s/\x1b\[[0-9;]*m//g" | awk "/^Output:/ {name=\$3} /priority 1/ {print name; exit}")"
  [ -n "$primary" ] && break
  sleep 2
done
[ -z "$primary" ] && { echo "sunshine-pick-primary: no primary output found, leaving config unchanged"; exit 0; }
touch "$CONF"
if grep -q "^output_name" "$CONF"; then
  sed -i "s/^output_name.*/output_name = $primary/" "$CONF"
else
  echo "output_name = $primary" >> "$CONF"
fi
echo "sunshine-pick-primary: output_name set to $primary"
