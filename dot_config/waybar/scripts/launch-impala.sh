#!/bin/bash

# Check if impala is already running
if pgrep -f "foot.*--app-id.*impala" > /dev/null; then
  # Focus the existing window if it's running
  hyprctl dispatch 'hl.dsp.focus({ window = "class:impala" })'
else
  # Open in foot with app-id
  foot --app-id "impala" -e impala &
  
  # Wait for window to spawn and apply rules
  sleep 0.1
  hyprctl dispatch 'hl.dsp.window.float({ window = "class:impala", action = "set" })'
  hyprctl eval 'local win = hl.get_window("class:impala"); if win then local m = win.monitor; local w, h = m.width, m.height; if m.transform % 2 == 1 then w, h = h, w end; hl.dispatch(hl.dsp.window.resize({ window = "class:impala", x = math.floor(w * 0.5), y = math.floor(h * 0.5) })) end'
  hyprctl dispatch 'hl.dsp.window.center({ window = "class:impala" })'
fi
