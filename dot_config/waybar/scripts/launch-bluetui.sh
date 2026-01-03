#!/bin/bash

# Check if bluetui is already running
if pgrep -f "foot.*--app-id.*bluetui" > /dev/null; then
  # Focus the existing window if it's running
  hyprctl dispatch focuswindow "class:bluetui"
else
  # Open in foot with app-id
  foot --app-id "bluetui" -e bluetui &
  
  # Wait for window to spawn and apply rules
  sleep 0.1
  hyprctl dispatch togglefloating "class:bluetui"
  hyprctl dispatch resizewindowpixel "exact 50% 50%,class:bluetui"
  hyprctl dispatch centerwindow "class:bluetui"
fi
