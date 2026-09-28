#!/usr/bin/env zsh

# Focus is on when the DoNotDisturb store holds an active assertion.
FOCUS_ON=$(python3 -c "
import json, os
try:
    p = os.path.expanduser(\"~/Library/DoNotDisturb/DB/Assertions.json\")
    data = json.load(open(p)).get(\"data\", [])
    on = any(e.get(\"storeAssertionRecords\") for e in data if isinstance(e, dict))
except Exception:
    on = False
print(\"on\" if on else \"off\")
" 2>/dev/null)

if [[ $FOCUS_ON == "on" ]]; then
  sketchybar --set $NAME drawing=on
else
  sketchybar --set $NAME drawing=off
fi
