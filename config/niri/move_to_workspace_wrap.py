#!/usr/bin/env python3
import sys
import json
import subprocess

if len(sys.argv) < 2:
    sys.exit(1)

target_ws = int(sys.argv[1]) # e.g., 1

def get_monitors_and_focus():
    out_res = subprocess.run(['niri', 'msg', '-j', 'outputs'], capture_output=True, text=True)
    f_out_res = subprocess.run(['niri', 'msg', '-j', 'focused-output'], capture_output=True, text=True)
    
    if out_res.returncode != 0 or f_out_res.returncode != 0:
        return None, None, None
        
    outputs = json.loads(out_res.stdout)
    f_out_data = json.loads(f_out_res.stdout)
    focused_output_name = f_out_data.get('name')
    
    sorted_outputs = sorted(outputs.values(), key=lambda x: x.get('logical', {}).get('x', 0))
    if len(sorted_outputs) < 2:
        return None, None, focused_output_name
        
    return sorted_outputs[0].get('name'), sorted_outputs[-1].get('name'), focused_output_name

left_output_name, right_output_name, focused_output_name = get_monitors_and_focus()

if not left_output_name or not right_output_name:
    # Single monitor fallback
    subprocess.run(['niri', 'msg', 'action', 'move-column-to-workspace', f'w{target_ws:02d}'])
    sys.exit(0)

# If the window is currently on the left monitor, send to target_ws_L
# If it is on the right monitor, send to target_ws_R
if focused_output_name == left_output_name:
    subprocess.run(['niri', 'msg', 'action', 'move-column-to-workspace', f'w{target_ws:02d}_L'])
else:
    # Default to right if it's the right or any other edge case
    subprocess.run(['niri', 'msg', 'action', 'move-column-to-workspace', f'w{target_ws:02d}_R'])
