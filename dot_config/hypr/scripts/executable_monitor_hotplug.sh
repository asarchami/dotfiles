#!/bin/bash
# ----------------------------------------------------- 
# Monitor Hotplug Handler
# Automatically configures monitors when plugged/unplugged
# ----------------------------------------------------- 

# Get lid state
get_lid_state() {
    local lid_file=$(find /proc/acpi/button/lid -name state 2>/dev/null | head -n 1)
    if [[ -n "$lid_file" ]]; then
        grep -q "open" "$lid_file" && echo "open" || echo "closed"
    else
        echo "unknown"
    fi
}

# Check which monitors are connected
check_monitors() {
    hyprctl monitors -j | jq -r '.[].name' | sort
}

# Apply docked configuration (3 external monitors)
apply_docked_config() {
    echo "Applying docked configuration..."
    hyprctl eval 'hl.monitor({ output = "DP-2", mode = "2560x1440@59.95", position = "0x0", scale = 1.0, transform = 1 })'
    hyprctl eval 'hl.monitor({ output = "DP-5", mode = "3840x2160@60", position = "1440x0", scale = 1.0, transform = 0 })'
    hyprctl eval 'hl.monitor({ output = "DP-3", mode = "2560x1440@59.95", position = "5280x0", scale = 1.0, transform = 3 })'
    
    # Disable laptop screen if lid is closed
    if [[ "$(get_lid_state)" == "closed" ]]; then
        hyprctl eval 'hl.monitor({ output = "eDP-1", disabled = true })'
    fi
    
    notify-send -u low "Display" "Docked configuration applied"
}

# Apply laptop-only configuration
apply_laptop_config() {
    echo "Applying laptop-only configuration..."
    hyprctl eval 'hl.monitor({ output = "eDP-1", mode = "1920x1200@120.02", position = "0x0", scale = 1.0 })'
    notify-send -u low "Display" "Laptop mode"
}

# Detect current setup and apply appropriate config
detect_and_apply() {
    local monitors=$(check_monitors)
    local monitor_count=$(echo "$monitors" | wc -l)
    
    echo "Detected monitors ($monitor_count):"
    echo "$monitors"
    
    # Check if we have all 3 external monitors
    if echo "$monitors" | grep -q "DP-2" && \
       echo "$monitors" | grep -q "DP-3" && \
       echo "$monitors" | grep -q "DP-5"; then
        apply_docked_config
    # Check if only laptop screen
    elif [[ "$monitor_count" -eq 1 ]] && echo "$monitors" | grep -q "eDP-1"; then
        apply_laptop_config
    else
        echo "Unknown configuration, skipping auto-config"
        notify-send -u normal "Display" "Unknown monitor configuration"
    fi
}

# Main execution
detect_and_apply
