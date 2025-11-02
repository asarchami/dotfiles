# Hyprland Keybindings

| Keybinding | Command | Description |
|---|---|---|
| `$mainMod + RETURN` | `exec,$terminal` | Opens your preferred terminal emulator ($terminal) |
| `$mainMod + E` | `exec,$filemanager` | Opens your preferred filemanager ($filemanager) |
| `$mainMod + Q` | `killactive` | Closes (not kill) current window |
| `$mainMod SHIFT + M` | `exec,loginctl terminate-user ""` | Exits Hyprland by terminating the user sessions |
| `$mainMod + V` | `togglefloating` | Switches current window between floating and tiling mode |
| `$mainMod + SPACE` | `exec,$applauncher` | Runs your application launcher |
| `$mainMod + F` | `fullscreen` | Toggles current window fullscreen mode |
| `$mainMod + Y` | `pin` | Pin current window (shows on all workspaces) |
| `$mainMod + J` | `togglesplit` | dwindle |
| `Print` | `exec,$shot-region` | Creates a screenshot of an area |
| `CTRL + Print` | `exec,$shot-window` | Creates a screenshot of the active window |
| `ALT + Print` | `exec,$shot-screen` | Creates a screenshot of the active display |
| `$mainMod + K` | `togglegroup` | Toggles current window group mode (ungroup all related) |
| `$mainMod + Tab` | `changegroupactive,f` | Switches to the next window in the group |
| `$mainMod SHIFT + G` | `exec,hyprctl --batch "keyword general:gaps_out 5;keyword general:gaps_in 3"` | Set CachyOS default gaps |
| `$mainMod + G` | `exec,hyprctl --batch "keyword general:gaps_out 0;keyword general:gaps_in 0"` | Remove gaps between window |
| `XF86AudioRaiseVolume` | `exec,pactl set-sink-volume @DEFAULT_SINK@ +5% && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)\' | awk '{if($1>100) system("pactl set-sink-volume @DEFAULT_SINK@ 100%")}' && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)\' | awk '{print $1}' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob` | Raise Volume |
| `XF86AudioLowerVolume` | `exec,pactl set-sink-volume @DEFAULT_SINK@ -5% && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)\' | awk '{print $1}' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob` | Lower Volume |
| `XF86AudioMute` | `exec,amixer sset Master toggle | sed -En '/[on]/ s/.*[([0-9]+)%].*/\1/ p; /[off]/ s/.*/0/p' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob` | Mutes player audio |
| `XF86AudioPlay` | `exec,playerctl play-pause` | Toggles play/pause |
| `XF86AudioNext` | `exec,playerctl next` | Next track |
| `XF86AudioPrev` | `exec,playerctl previous` | Previous track |
| `XF86MonBrightnessUp` | `exec,brightnessctl s +5%` | Increases brightness 5% |
| `XF86MonBrightnessDown` | `exec,brightnessctl s 5%-` | Decreases brightness 5% |
| `$mainMod + L` | `exec,swaylock-fancy -e -K -p 10 -f Hack-Regular` | Lock the screen |
| `$mainMod + O` | `exec,killall -SIGUSR2 waybar` | Reload/restarts Waybar |
| `$mainMod + mouse:272` | `movewindow` | Move the window towards a direction |
| `$mainMod SHIFT + left` | `movewindow,l` | Move active window to the left |
| `$mainMod SHIFT + right` | `movewindow,r` | Move active window to the right |
| `$mainMod SHIFT + up` | `movewindow,u` | Move active window upwards |
| `$mainMod SHIFT + down` | `movewindow,d` | Move active window downwards |
| `$mainMod + left` | `movefocus,l` | Move focus to the left |
| `$mainMod + right` | `movefocus,r` | Move focus to the right |
| `$mainMod + up` | `movefocus,u` | Move focus upwards |
| `$mainMod + down` | `movefocus,d` | Move focus downwards |
| `$mainMod + R` | `submap,resize` | Activates window resizing mode |
| `right` | `resizeactive,15 0` | Resize to the right (resizing mode) |
| `left` | `resizeactive,-15 0` | Resize to the left (resizing mode) |
| `up` | `resizeactive,0 -15` | Resize upwards (resizing mode) |
| `down` | `resizeactive,0 15` | Resize downwards (resizing mode) |
| `l` | `resizeactive,15 0` | Resize to the right (resizing mode) |
| `h` | `resizeactive,-15 0` | Resize to the left (resizing mode) |
| `k` | `resizeactive,0 -15` | Resize upwards (resizing mode) |
| `j` | `resizeactive,0 15` | Resize downwards (resizing mode) |
| `escape` | `submap,reset` | Ends window resizing mode |
| `$mainMod CTRL SHIFT + right` | `resizeactive,15 0` | Resize to the right |
| `$mainMod CTRL SHIFT + left` | `resizeactive,-15 0` | Resize to the left |
| `$mainMod CTRL SHIFT + up` | `resizeactive,0 -15` | Resize upwards |
| `$mainMod CTRL SHIFT + down` | `resizeactive,0 15` | Resize downwards |
| `$mainMod CTRL SHIFT + l` | `resizeactive,15 0` | Resize to the right |
| `$mainMod CTRL SHIFT + h` | `resizeactive,-15 0` | Resize to the left |
| `$mainMod CTRL SHIFT + k` | `resizeactive,0 -15` | Resize upwards |
| `$mainMod CTRL SHIFT + j` | `resizeactive,0 15` | Resize downwards |
| `$mainMod + mouse:273` | `resizewindow` | Resize the window towards a direction |
| `$mainMod + mouse:272` | `movewindow` | Drag window |
| `$mainMod CTRL + 1` | `movetoworkspace,1` | Move window and switch to workspace 1 |
| `$mainMod CTRL + 2` | `movetoworkspace,2` | Move window and switch to workspace 2 |
| `$mainMod CTRL + 3` | `movetoworkspace,3` | Move window and switch to workspace 3 |
| `$mainMod CTRL + 4` | `movetoworkspace,4` | Move window and switch to workspace 4 |
| `$mainMod CTRL + 5` | `movetoworkspace,5` | Move window and switch to workspace 5 |
| `$mainMod CTRL + 6` | `movetoworkspace,6` | Move window and switch to workspace 6 |
| `$mainMod CTRL + 7` | `movetoworkspace,7` | Move window and switch to workspace 7 |
| `$mainMod CTRL + 8` | `movetoworkspace,8` | Move window and switch to workspace 8 |
| `$mainMod CTRL + 9` | `movetoworkspace,9` | Move window and switch to workspace 9 |
| `$mainMod CTRL + 0` | `movetoworkspace,10` | Move window and switch to workspace 10 |
| `$mainMod CTRL + left` | `movetoworkspace,-1` | Move window and switch to the next workspace |
| `$mainMod CTRL + right` | `movetoworkspace,+1` | Move window and switch to the previous workspace |
| `$mainMod SHIFT + 1` | `movetoworkspacesilent,1` | Move window silently to workspace 1 |
| `$mainMod SHIFT + 2` | `movetoworkspacesilent,2` | Move window silently to workspace 2 |
| `$mainMod SHIFT + 3` | `movetoworkspacesilent,3` | Move window silently to workspace 3 |
| `$mainMod SHIFT + 4` | `movetoworkspacesilent,4` | Move window silently to workspace 4 |
| `$mainMod SHIFT + 5` | `movetoworkspacesilent,5` | Move window silently to workspace 5 |
| `$mainMod SHIFT + 6` | `movetoworkspacesilent,6` | Move window silently to workspace 6 |
| `$mainMod SHIFT + 7` | `movetoworkspacesilent,7` | Move window silently to workspace 7 |
| `$mainMod SHIFT + 8` | `movetoworkspacesilent,8` | Move window silently to workspace 8 |
| `$mainMod SHIFT + 9` | `movetoworkspacesilent,9` | Move window silently to workspace 9 |
| `$mainMod SHIFT + 0` | `movetoworkspacesilent,10` | Move window silently to workspace 10 |
| `$mainMod + 1` | `workspace,1` | Switch to workspace 1 |
| `$mainMod + 2` | `workspace,2` | Switch to workspace 2 |
| `$mainMod + 3` | `workspace,3` | Switch to workspace 3 |
| `$mainMod + 4` | `workspace,4` | Switch to workspace 4 |
| `$mainMod + 5` | `workspace,5` | Switch to workspace 5 |
| `$mainMod + 6` | `workspace,6` | Switch to workspace 6 |
| `$mainMod + 7` | `workspace,7` | Switch to workspace 7 |
| `$mainMod + 8` | `workspace,8` | Switch to workspace 8 |
| `$mainMod + 9` | `workspace,9` | Switch to workspace 9 |
| `$mainMod + 0` | `workspace,10` | Switch to workspace 10 |
| `$mainMod + PERIOD` | `workspace,e+1` | Scroll through workspaces incrementally |
| `$mainMod + COMMA` | `workspace,e-1` | Scroll through workspaces decrementally |
| `$mainMod + mouse_down` | `workspace,e+1` | Scroll through workspaces incrementally |
| `$mainMod + mouse_up` | `workspace,e-1` | Scroll through workspaces decrementally |
| `$mainMod + slash` | `workspace,previous` | Switch to the previous workspace |
| `$mainMod + minus` | `movetoworkspace,special` | Move active window to Special workspace |
| `$mainMod + equal` | `togglespecialworkspace,special` | Toggles the Special workspace |
| `$mainMod + F1` | `togglespecialworkspace,scratchpad` | Call special workspace scratchpad |
| `$mainMod ALT SHIFT + F1` | `movetoworkspacesilent,special:scratchpad` | Move active window to special workspace scratchpad |