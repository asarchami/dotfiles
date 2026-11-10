-- Keybinds.
-- See https://wiki.hypr.land/configuring/core/binds/

local vars = require("variables")
local mod  = vars.mainMod

local toggle_window = "~/.config/hypr/scripts/toggle_window.sh"

-- Windows and workspaces.

hl.bind(mod .. " + T", hl.dsp.exec_cmd("alacritty"))
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + Q", hl.dsp.exec_cmd("wlogout"))
hl.bind(mod .. " + E", hl.dsp.exec_cmd(toggle_window .. " yazi"))
hl.bind(mod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + SPACE", hl.dsp.exec_cmd("wofi --show drun"))
hl.bind(mod .. " + r", hl.dsp.reload_config())
hl.bind(mod .. " + P", hl.dsp.window.pseudo({ action = "toggle" }))
hl.bind(mod .. " + SHIFT + O", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(mod .. " + SHIFT + A", hl.dsp.exec_cmd(toggle_window .. " pavucontrol"))
hl.bind(mod .. " + SHIFT + M", hl.dsp.exec_cmd("~/.config/hypr/scripts/monitor_hotplug.sh"))

-- Copy and paste with Mac style shortcuts.

hl.bind(mod .. " + C", hl.dsp.send_shortcut({ mods = "CTRL", key = "C" }), { repeating = true })
hl.bind(mod .. " + V", hl.dsp.send_shortcut({ mods = "CTRL", key = "V" }), { repeating = true })

hl.bind(mod .. " + CTRL + F", hl.dsp.window.fullscreen())

-- Workspace focus on the current monitor.

hl.bind(mod .. " + l", hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mod .. " + h", hl.dsp.focus({ workspace = "r-1" }))

-- Move the active window to a workspace.

hl.bind(mod .. " + CTRL + l", hl.dsp.window.move({ workspace = "r" }))
hl.bind(mod .. " + CTRL + h", hl.dsp.window.move({ workspace = "l" }))

-- Move focus with vim keys.

hl.bind(mod .. " + SHIFT + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + SHIFT + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + SHIFT + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + SHIFT + j", hl.dsp.focus({ direction = "down" }))

-- Move the active window with vim keys.

hl.bind(mod .. " + CTRL + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + CTRL + SHIFT + h", hl.dsp.window.move({ direction = "left" }))

-- Move and resize windows with the mouse.

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mod .. " + CTRL + 3", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/toggle_monitor.sh"))
hl.bind(mod .. " + CTRL + P", hl.dsp.exec_cmd("~/.config/hypr/scripts/set_primary_monitor.sh"))
hl.bind(mod .. " + CTRL + W", hl.dsp.exec_cmd("pkill waybar"))
