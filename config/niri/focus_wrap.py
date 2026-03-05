#!/usr/bin/env python3
import sys
import json
import subprocess

def get_niri_state():
    try:
        focused_window_id = None
        result = subprocess.run(['niri', 'msg', '-j', 'focused-window'], capture_output=True, text=True)
        if result.returncode == 0:
            data = json.loads(result.stdout)
            if data is not None:
                focused_window_id = data.get('id')
        
        # We also need outputs to check which output we are on (Left or Right)
        out_res = subprocess.run(['niri', 'msg', '-j', 'outputs'], capture_output=True, text=True)
        if out_res.returncode != 0:
            return focused_window_id, None
            
        outputs = json.loads(out_res.stdout)
        # Niri returns a dict where values have the details.
        # Find which output the current workspace/window is on by looking at the focused output
        f_out_res = subprocess.run(['niri', 'msg', '-j', 'focused-output'], capture_output=True, text=True)
        if f_out_res.returncode != 0:
            return focused_window_id, None
        f_out_data = json.loads(f_out_res.stdout)
        focused_output_name = f_out_data.get('name')
        
        # Sort outputs by logical X mapping to know which is technically left vs right
        # Output with x=0 is left, output with x > 0 is right.
        sorted_outputs = sorted(outputs.values(), key=lambda x: x.get('logical', {}).get('x', 0))
        
        is_left_monitor = False
        is_right_monitor = False
        if len(sorted_outputs) >= 2:
            if sorted_outputs[0].get('name') == focused_output_name:
                is_left_monitor = True
            elif sorted_outputs[-1].get('name') == focused_output_name:
                is_right_monitor = True
        
        return focused_window_id, (is_left_monitor, is_right_monitor)
        
    except Exception:
        return None, None

if len(sys.argv) < 2:
    sys.exit(1)

direction = sys.argv[1]

prev_id, monitor_pos = get_niri_state()

if not monitor_pos:
    # Single monitor fallback
    subprocess.run(['niri', 'msg', 'action', f'focus-column-{direction}'])
    sys.exit(0)

is_left_monitor, is_right_monitor = monitor_pos

if direction == 'left':
    subprocess.run(['niri', 'msg', 'action', 'focus-column-left'])
    new_id, _ = get_niri_state()
    if prev_id == new_id:
        # Hit a left bound.
        # Are we on the right monitor? If so, jump the seam to the left monitor.
        if is_right_monitor:
            subprocess.run(['niri', 'msg', 'action', 'focus-monitor-left'])
            subprocess.run(['niri', 'msg', 'action', 'focus-column-last'])
        # If we are on the left monitor, do nothing! Hard edge ultrawide.
elif direction == 'right':
    subprocess.run(['niri', 'msg', 'action', 'focus-column-right'])
    new_id, _ = get_niri_state()
    if prev_id == new_id:
        # Hit a right bound.
        # Are we on the left monitor? If so, jump the seam to the right monitor.
        if is_left_monitor:
            subprocess.run(['niri', 'msg', 'action', 'focus-monitor-right'])
            subprocess.run(['niri', 'msg', 'action', 'focus-column-first'])
        # If we are on the right monitor, do nothing! Hard edge ultrawide.
