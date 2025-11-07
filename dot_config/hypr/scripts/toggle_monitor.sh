#!/bin/bash

MONITOR="DP-3"
STATE_FILE="/tmp/monitor_${MONITOR}_disabled"

if [ -f "$STATE_FILE" ]; then
    # Monitor is disabled, so enable it
    hyprctl keyword monitor "${MONITOR},3840x2160@144.0,3840x452,1.0"
    rm "$STATE_FILE"
else
    # Monitor is enabled, so disable it
    hyprctl keyword monitor "${MONITOR},disable"
    touch "$STATE_FILE"
fi
