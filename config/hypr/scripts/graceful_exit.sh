#!/bin/bash
# Close applications gracefully before exiting
# Send SIGTERM to typical applications that need to save state
killall -15 firefox &> /dev/null

# Tell Hyprland to close all windows
hyprctl dispatch closewindow all

# Wait a moment for apps to save their state
sleep 1.5

# Exit Hyprland
hyprctl dispatch exit
