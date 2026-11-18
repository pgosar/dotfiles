#!/usr/bin/env bash
# Wake the PC and put it into Steam Big Picture mode on the 4K panel only.
# Usage: wake-bigpicture.sh
# Sends Wake-on-LAN directly (no display-off helper — Big Picture wants the
# 4K panel on), waits for SSH, then runs bigpicture-mode.sh on the PC under
# an idle inhibitor so it cannot auto-suspend mid-setup.
set -euo pipefail

PC_MAC="${PC_MAC:-9c:6b:00:a8:f9:d8}"
PC_HOST="${PC_HOST:-pc}"
SSH_USER="${SSH_USER:-chilly}"
SSH_OPTS=(-o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new)

# Send the magic packet (MacBook is on the home LAN, so broadcast works).
python3 -c "import socket; mac=bytes.fromhex('$PC_MAC'.replace(':','')); pkt=b'\xff'*6+mac*16; s=socket.socket(socket.AF_INET, socket.SOCK_DGRAM); s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1); [s.sendto(pkt, (b, p)) for b in ('192.168.1.255','255.255.255.255') for p in (7,9)]; print('wake-bigpicture: magic packet sent to $PC_MAC')"
echo "wake-bigpicture: waiting for PC SSH..."

# Wait for SSH (up to ~5 minutes).
for _ in $(seq 1 60); do
  for target in "$PC_HOST" "$SSH_USER@100.91.239.107" "$SSH_USER@192.168.1.50"; do
    if ssh "${SSH_OPTS[@]}" "$target" true 2>/dev/null; then
      echo "wake-bigpicture: PC reachable via $target"
      ssh "${SSH_OPTS[@]}" "$target" "systemd-inhibit --what=idle --who=wake-bigpicture --why='Big Picture setup' /home/chilly/.local/bin/bigpicture-mode.sh"
      echo "wake-bigpicture: done"
      exit 0
    fi
  done
  sleep 5
done
echo "wake-bigpicture: PC did not become reachable over SSH" >&2
exit 1
