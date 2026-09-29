#!/usr/bin/env bash
# (Re)launch JankyBorders using the generated macOS pywal theme.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME="$SCRIPT_DIR/theme-macos.json"

BORDERS=$(command -v borders)
if [ -z "$BORDERS" ]; then
  echo "borders not found on PATH; skipping" >&2
  exit 0
fi

ACTIVE=0xffe1e3e4
INACTIVE=0xff494d64
if [ -f "$THEME" ]; then
  # fall back to defaults if the theme JSON fails to parse
  read -r PARSED_ACTIVE PARSED_INACTIVE <<< "$(python3 -c "
import json, sys
t = json.load(open(sys.argv[1]))
print('0xff' + t['peach'].lstrip('#'), '0xff' + t['surface'].lstrip('#'))
" "$THEME" 2>/dev/null)" || true
  [ -n "$PARSED_ACTIVE" ] && ACTIVE="$PARSED_ACTIVE"
  [ -n "$PARSED_INACTIVE" ] && INACTIVE="$PARSED_INACTIVE"
fi

pkill -x borders 2> /dev/null
# detach stdio so callers over ssh don't hang on the backgrounded process
"$BORDERS" active_color="$ACTIVE" inactive_color="$INACTIVE" width=5.0 style=round hidpi=off > /dev/null 2>&1 < /dev/null &
