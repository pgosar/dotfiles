#!/bin/bash
# Fetch exact DP interface names from Niri since they change spontaneously
OUTPUTS=$(niri msg -j outputs | python3 -c '
import sys, json
try:
    data = json.load(sys.stdin)
except:
    data = {}
primary = "DP-5"
secondary = "DP-4"
for k, v in data.items():
    model = v.get("model", "")
    if "MPG321UX OLED" in model:
        primary = k
    elif "Odyssey G5" in model:
        secondary = k
print(f"{primary} {secondary}")
')

PRIMARY=$(echo $OUTPUTS | awk "{print \$1}")
SECONDARY=$(echo $OUTPUTS | awk "{print \$2}")

# Fallbacks
PRIMARY=${PRIMARY:-DP-5}
SECONDARY=${SECONDARY:-DP-4}

cat <<EOF > ~/.config/hypr/monitors.conf
\$monitor1 = $PRIMARY
\$monitor2 = $SECONDARY

# Primary 4K OLED
monitor=\$monitor1, 3840x2160@239.99, 0x0, 1.5

# Secondary 1440p
monitor=\$monitor2, 2560x1440@179.95, 2560x0, 1
EOF

