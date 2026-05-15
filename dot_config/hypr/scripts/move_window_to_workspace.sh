#!/bin/bash
# Move active window to next/previous workspace on current monitor
# Usage: move_window_to_workspace.sh next|prev

direction="${1:-next}"

# Get current window address and workspace
current_ws=$(hyprctl activewindow -j | jq -r '.workspace.id')
current_monitor=$(hyprctl activewindow -j | jq -r '.monitor')

# Get all workspaces sorted by ID
workspaces=$(hyprctl workspaces -j | jq -r ".[].id" | sort -n)

# Convert to array
ws_array=($workspaces)

# Find current workspace index
current_idx=-1
for i in "${!ws_array[@]}"; do
  if [[ "${ws_array[$i]}" == "$current_ws" ]]; then
    current_idx=$i
    break
  fi
done

if [[ $current_idx -eq -1 ]]; then
  exit 1
fi

# Calculate next/previous workspace
if [[ "$direction" == "next" ]]; then
  next_idx=$((current_idx + 1))
else
  next_idx=$((current_idx - 1))
fi

# Get next workspace
if [[ $next_idx -ge 0 ]] && [[ $next_idx -lt ${#ws_array[@]} ]]; then
  next_ws=${ws_array[$next_idx]}
  hyprctl dispatch movetoworkspace "$next_ws"
fi
