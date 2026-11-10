#!/usr/bin/env bash
# Usage: workspace_action.sh <workspace|movetoworkspace> <offset>

action="$1"
offset="$2"

base=$(((($(hyprctl activeworkspace -j | jq -r .id) - 1) / 10) * 10))
target=$((base + offset))

case "$action" in
    workspace)
        hyprctl dispatch "hl.dsp.focus({ workspace = $target })"
        ;;
    movetoworkspace)
        hyprctl dispatch "hl.dsp.window.move({ workspace = $target })"
        ;;
    *)
        notify-send "Workspace Action Error" "Unknown action: $action"
        exit 1
        ;;
esac
