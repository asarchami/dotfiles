#!/bin/bash

# Check if impala is already running
if pgrep -f "foot.*--app-id.*impala" > /dev/null; then
  # Focus the existing window if it's running
  hyprctl dispatch focuswindow "class:impala"
else
  # Open in foot with app-id
  foot --app-id "impala" -e impala &
  
  # Wait for window to spawn and apply rules
  sleep 0.1
  hyprctl dispatch togglefloating "class:impala"
  hyprctl dispatch resizewindowpixel "exact 50% 50%,class:impala"
  hyprctl dispatch centerwindow "class:impala"
fi
