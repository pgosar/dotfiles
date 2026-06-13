#!/usr/bin/env bash

mkcd() {
  mkdir "$1" && cd "$1" || return
}

waydroid-start() {
  echo "Starting Waydroid container..."
  sudo systemctl start waydroid-container
  echo "Starting Waydroid session..."
  waydroid session start > /dev/null 2>&1 &
  sleep 1
  echo "Opening Waydroid UI..."
  waydroid show-full-ui &
}

waydroid-stop() {
  echo "Stopping Waydroid session..."
  waydroid session stop
  echo "Stopping Waydroid container..."
  sudo systemctl stop waydroid-container
  echo "Waydroid stopped."
}
