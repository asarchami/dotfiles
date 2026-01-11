#!/bin/bash
# ----------------------------------------------------- 
# Lid Monitor Script
# Monitors laptop lid state and enables/disables eDP-1
# ----------------------------------------------------- 

# Path to lid state file (first match)
LID_STATE=$(find /proc/acpi/button/lid -name state | head -n 1)

if [[ -z "$LID_STATE" ]]; then
    echo "Error: No lid state file found. This might not be a laptop."
    exit 1
fi

# Get initial lid state
get_lid_state() {
    grep -q "open" "$LID_STATE" && echo "open" || echo "closed"
}

# Check if external monitors are connected
has_external_monitors() {
    hyprctl monitors -j | jq -r '.[].name' | grep -qv "^eDP-1$"
}

# Enable laptop display
enable_edp1() {
    echo "Lid opened - enabling eDP-1"
    hyprctl keyword monitor "eDP-1,1920x1200@120.02,0x0,1.0"
    notify-send -u low "Display" "Laptop screen enabled"
}

# Disable laptop display (only if external monitors present)
disable_edp1() {
    if has_external_monitors; then
        echo "Lid closed with external monitors - disabling eDP-1"
        hyprctl keyword monitor "eDP-1,disable"
        notify-send -u low "Display" "Laptop screen disabled"
    else
        echo "Lid closed but no external monitors - keeping eDP-1 enabled"
    fi
}

# Store previous state
PREVIOUS_STATE=$(get_lid_state)

echo "Starting lid monitor... Current state: $PREVIOUS_STATE"

# Monitor lid state changes using inotifywait
inotifywait -m -e modify "$LID_STATE" | while read -r; do
    CURRENT_STATE=$(get_lid_state)
    
    # Only act on state changes
    if [[ "$CURRENT_STATE" != "$PREVIOUS_STATE" ]]; then
        echo "Lid state changed: $PREVIOUS_STATE -> $CURRENT_STATE"
        
        if [[ "$CURRENT_STATE" == "open" ]]; then
            enable_edp1
        else
            disable_edp1
        fi
        
        PREVIOUS_STATE="$CURRENT_STATE"
    fi
done
