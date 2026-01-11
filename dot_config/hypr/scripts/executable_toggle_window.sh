#!/bin/bash

# Unified window toggle script for Hyprland
# Usage: toggle_window.sh <window-type>
# Supported types: yazi, pavucontrol, impala, bluetui

# Get window type from argument
WINDOW_TYPE="$1"

# Validate argument
if [ -z "$WINDOW_TYPE" ]; then
    notify-send "Toggle Window Error" "No window type specified"
    exit 1
fi

# Define window configurations
case "$WINDOW_TYPE" in
    yazi)
        CLASS="TUI-FileManager"
        LAUNCH_CMD="foot --app-id TUI-FileManager yazi"
        SOUND=""
        ;;
    pavucontrol)
        CLASS="org.pulseaudio.pavucontrol"
        LAUNCH_CMD="pavucontrol"
        SOUND=""
        ;;
    impala)
        CLASS="impala"
        LAUNCH_CMD="foot --app-id impala -e impala"
        SOUND="aplay ~/.config/sounds/interact.wav"
        ;;
    bluetui)
        CLASS="bluetui"
        LAUNCH_CMD="foot --app-id bluetui -e bluetui"
        SOUND="aplay ~/.config/sounds/interact.wav"
        ;;
    *)
        notify-send "Toggle Window Error" "Unknown window type: $WINDOW_TYPE"
        exit 1
        ;;
esac

# Check if window exists (check both class and initialClass)
WINDOW_ADDR=$(hyprctl clients -j | jq -r ".[] | select(.class == \"$CLASS\" or .initialClass == \"$CLASS\") | .address")

if [ -n "$WINDOW_ADDR" ]; then
    # Window exists - kill it directly without switching workspace
    hyprctl dispatch closewindow "address:$WINDOW_ADDR"
else
    # Window doesn't exist - launch it
    $LAUNCH_CMD &
    [ -n "$SOUND" ] && $SOUND &
fi
