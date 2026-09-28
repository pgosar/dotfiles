#!/usr/bin/env bash
# (Re)launch JankyBorders using the generated macOS pywal theme.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME="$SCRIPT_DIR/theme-macos.json"

if [ -f "$THEME" ]; then
  read -r ACTIVE INACTIVE <<< "$(python3 -c "
import json, sys
t = json.load(open(sys.argv[1]))
print('0xff' + t['peach'].lstrip('#'), '0xff' + t['surface'].lstrip('#'))
" "$THEME")"
else
  ACTIVE=0xffe1e3e4
  INACTIVE=0xff494d64
fi

pkill -x borders 2> /dev/null
# detach stdio so callers over ssh don't hang on the backgrounded process
/opt/homebrew/bin/borders active_color="$ACTIVE" inactive_color="$INACTIVE" width=5.0 style=round hidpi=off > /dev/null 2>&1 < /dev/null &
