#!/usr/bin/env python3
import sys
import json
import subprocess
import re

if len(sys.argv) < 2:
    sys.exit(1)

direction = sys.argv[1] # "up" or "down"

def get_current_workspace():
    res = subprocess.run(['niri', 'msg', '-j', 'focused-workspace'], capture_output=True, text=True)
    if res.returncode != 0:
        return None
    data = json.loads(res.stdout)
    return data.get('name')

current_name = get_current_workspace()
if current_name is None:
    sys.exit(0)

match = re.match(r'w(\d+)_[LR]', str(current_name))
if match is None:
    sys.exit(0)

current_idx = int(match.group(1))

if direction == "up":
    target_idx = current_idx - 1
elif direction == "down":
    target_idx = current_idx + 1
else:
    sys.exit(1)

if target_idx < 1 or target_idx > 10:
    # Wrap around or clamp. We'll clamp for simplicity and safety.
    sys.exit(0)

subprocess.run(["~/.config/niri/workspace_wrap.py", str(target_idx)])
