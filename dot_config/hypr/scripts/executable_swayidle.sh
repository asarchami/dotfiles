#!/bin/bash
swayidle \
  timeout 600 hyprlock \
  timeout 1200 'systemctl suspend' \
  before-sleep 'pgrep -x hyprlock > /dev/null || hyprlock'
