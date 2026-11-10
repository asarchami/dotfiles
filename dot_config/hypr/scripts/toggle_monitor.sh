#!/bin/bash

MONITOR="DP-3"
STATE_FILE="/tmp/monitor_${MONITOR}_disabled"

if [ -f "$STATE_FILE" ]; then
    # Monitor is disabled, so enable it
    hyprctl eval "hl.monitor({ output = \"${MONITOR}\", mode = \"3840x2160@144.0\", position = \"3840x452\", scale = 1.0 })"
    rm "$STATE_FILE"
else
    # Monitor is enabled, so disable it
    hyprctl eval "hl.monitor({ output = \"${MONITOR}\", disabled = true })"
    touch "$STATE_FILE"
fi
