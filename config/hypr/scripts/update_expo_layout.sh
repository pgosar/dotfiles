#!/bin/bash

# Extract monitor variables from monitors.conf since they change dynamically
MON1=$(grep '^\$monitor1' ~/.config/hypr/monitors.conf | cut -d'=' -f2 | xargs)
MON2=$(grep '^\$monitor2' ~/.config/hypr/monitors.conf | cut -d'=' -f2 | xargs)

# Wait a moment for hyprpm to finish reloading plugins if this is a cold boot
sleep 1

# Inject the correctly parsed string directly into the plugin engine via hyprctl IPC
hyprctl keyword plugin:hyprexpo:workspace_method "$MON1 first 1, $MON2 first 11"
