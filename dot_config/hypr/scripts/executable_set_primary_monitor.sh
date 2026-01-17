#!/bin/bash
# ----------------------------------------------------- 
# Set DP-3 as Primary Display for XWayland Applications
# ----------------------------------------------------- 
# This script sets the X11 primary monitor flag so that
# games and other XWayland apps use DP-3 as the main display

xrandr --output DP-1 --mode 2560x1440 --rate 59.95 --rotate right \
       --output DP-2 --mode 2560x1440 --rate 59.95 --rotate left \
       --output DP-3 --mode 3840x2160 --rate 144 --primary

notify-send "Monitor Configuration" "DP-3 set as primary display for XWayland apps" -t 2000
