#!/usr/bin/env bash

# Prompt "Exit Hyprland?" with Yes/No via wofi
choice=$(printf "Yes\nNo" | wofi --dmenu --prompt="Exit Hyprland?")

if [ "$choice" = "Yes" ]; then
    hyprctl dispatch exit
fi

