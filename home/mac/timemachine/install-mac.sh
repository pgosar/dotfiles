#!/usr/bin/env bash
# Install the Time Machine keep-two Time Machine pruner on the MacBook.
# Idempotent: safe to re-run. Needs passwordless sudo or an admin prompt.
set -euo pipefail

if [ "$(uname)" != "Darwin" ]; then
  echo "install-mac.sh is for the MacBook only" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo install -m 755 "$SCRIPT_DIR/tm-keep-two.sh" /usr/local/bin/tm-keep-two.sh
sudo install -m 644 -o root -g wheel "$SCRIPT_DIR/com.casper.tm-keep-two.plist" /Library/LaunchDaemons/com.casper.tm-keep-two.plist
sudo launchctl bootout system/com.casper.tm-keep-two 2>/dev/null || true
sudo launchctl bootstrap system /Library/LaunchDaemons/com.casper.tm-keep-two.plist
echo "tm-keep-two installed: keeps the newest backup plus the newest one at least a week old, checked daily at 04:30"
