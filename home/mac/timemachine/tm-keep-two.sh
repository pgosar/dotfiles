#!/bin/bash
# Keep two Time Machine backups: the newest, and the newest one that
# is at least a week old. Every backup is a complete restorable copy,
# so these two are the current and the week-old recovery points.
# Runs daily as root; no-ops while a backup is running.
TM="${TMUTIL:-/usr/bin/tmutil}"
"$TM" status 2>/dev/null | grep -q 'Running = 1' && exit 0
backups="$("$TM" listbackups 2>/dev/null)" || exit 0
[ -z "$backups" ] && exit 0
now="$(date +%s)"
week_ago=$((now - 604800))
keep_newest=""
keep_week=""
candidates=()
while IFS= read -r path; do
  case "$path" in /*) candidates+=("$path");; esac
done <<< "$backups"
total=${#candidates[@]}
[ "$total" -le 2 ] && exit 0
keep_newest="${candidates[$((total - 1))]}"
for ((i = total - 2; i >= 0; i--)); do
  name="$(basename "${candidates[$i]}")"
  ts="${name%.backup}"
  epoch="$(date -j -f '%Y-%m-%d-%H%M%S' "$ts" +%s 2>/dev/null)" || continue
  if [ "$epoch" -le "$week_ago" ]; then
    keep_week="${candidates[$i]}"
    break
  fi
done
for path in "${candidates[@]}"; do
  if [ "$path" != "$keep_newest" ] && [ "$path" != "$keep_week" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') deleting: $path"
    "$TM" delete -p "$path" || echo "$(date '+%Y-%m-%d %H:%M:%S') delete failed for: $path"
  fi
done
exit 0
