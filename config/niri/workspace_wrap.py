#!/usr/bin/env python3
import sys
import json
import subprocess

if len(sys.argv) < 2:
    sys.exit(1)

target_ws = int(sys.argv[1]) # e.g., 1

# We need to know which monitors are left and right.
def get_monitors():
    out_res = subprocess.run(['niri', 'msg', '-j', 'outputs'], capture_output=True, text=True)
    if out_res.returncode != 0:
        return None, None
    outputs = json.loads(out_res.stdout)
    sorted_outputs = sorted(outputs.values(), key=lambda x: x.get('logical', {}).get('x', 0))
    if len(sorted_outputs) < 2:
        return None, None
    return sorted_outputs[0].get('name'), sorted_outputs[-1].get('name')

def get_focused_output():
    f_out_res = subprocess.run(['niri', 'msg', '-j', 'focused-output'], capture_output=True, text=True)
    if f_out_res.returncode == 0:
        return json.loads(f_out_res.stdout).get('name')
    return None

left_output_name, right_output_name = get_monitors()
if not left_output_name or not right_output_name:
    # Fallback to simple focus
    subprocess.run(['niri', 'msg', 'action', 'focus-workspace', f'w{target_ws}'])
    sys.exit(0)

original_output = get_focused_output()

# Focus left output and switch workspace
subprocess.run(['niri', 'msg', 'action', 'focus-monitor', str(left_output_name)])
subprocess.run(['niri', 'msg', 'action', 'focus-workspace', f'w{target_ws:02d}_L'])

# Focus right output and switch workspace
subprocess.run(['niri', 'msg', 'action', 'focus-monitor', str(right_output_name)])
subprocess.run(['niri', 'msg', 'action', 'focus-workspace', f'w{target_ws:02d}_R'])

# Restore original output focus
if original_output:
    subprocess.run(['niri', 'msg', 'action', 'focus-monitor', original_output])
