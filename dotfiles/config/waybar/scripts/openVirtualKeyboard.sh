#!/bin/bash

if pgrep -x "wvkbd-mobintl" 2>&1 >/dev/null; then
    kill -s SIGUSR1 $(pidof wvkbd-mobintl) 2>&1 >/dev/null
else
    # Process is not running, so execute it
    exec /home/chilly/.local/wvkbd/wvkbd-mobintl &
fi
