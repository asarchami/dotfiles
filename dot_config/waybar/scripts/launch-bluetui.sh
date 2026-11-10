#!/bin/bash

# Check if bluetui is already running
if pgrep -f "foot.*--app-id.*bluetui" > /dev/null; then
  # Focus the existing window if it's running
  hyprctl dispatch 'hl.dsp.focus({ window = "class:bluetui" })'
else
  # Open in foot with app-id
  foot --app-id "bluetui" -e bluetui &
  
  # Wait for window to spawn and apply rules
  sleep 0.1
  hyprctl dispatch 'hl.dsp.window.float({ window = "class:bluetui", action = "set" })'
  hyprctl eval 'local win = hl.get_window("class:bluetui"); if win then local m = win.monitor; local w, h = m.width, m.height; if m.transform % 2 == 1 then w, h = h, w end; hl.dispatch(hl.dsp.window.resize({ window = "class:bluetui", x = math.floor(w * 0.5), y = math.floor(h * 0.5) })) end'
  hyprctl dispatch 'hl.dsp.window.center({ window = "class:bluetui" })'
fi
