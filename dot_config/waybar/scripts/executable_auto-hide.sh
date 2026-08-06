#!/bin/bash

# Auto-hide waybar, per monitor.
#
# One waybar instance is launched per monitor (each with "output" injected
# into its config). When the mouse reaches the very top edge (REVEAL_HEIGHT)
# of a monitor, that monitor's bar is shown over the windows; it stays shown
# while the mouse is on the bar (DISMISS_HEIGHT) and hides once it leaves.
#
# Bars run in the overlay layer with no exclusive zone, so showing them never
# resizes or reflows the windows below.
#
# Show/hide is done with idempotent SIGUSR1 (HIDE) / SIGUSR2 (SHOW) actions
# configured in waybar's config, so state never drifts out of sync.

REVEAL_HEIGHT=5
DISMISS_HEIGHT=28
CONFIG="$HOME/.config/waybar/config.jsonc"
STYLE="$HOME/.config/waybar/style.css"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}/waybar-autohide"
mkdir -p "$RUNTIME_DIR"

PIDS=""    # space-separated "monitor:pid" entries
ACTIVE="__UNSET__"

show() { kill -USR2 "$1" 2>/dev/null; }
hide() { kill -USR1 "$1" 2>/dev/null; }

monitor_list() {
  hyprctl monitors -j | jq -r '.[].name' | sort
}

# Write a per-monitor config with "output" injected into every bar.
render_config() {
  local monitor="$1"
  python3 - "$CONFIG" "$RUNTIME_DIR/$monitor.jsonc" "$monitor" <<'PYEOF'
import json, re, sys
source, target, monitor = sys.argv[1], sys.argv[2], sys.argv[3]
text = re.sub(r'//[^\n]*', '', open(source).read())
text = re.sub(r',(\s*[}\]])', r'\1', text)
config = json.loads(text)
for bar in config:
    bar['output'] = monitor
json.dump(config, open(target, 'w'), indent=2)
PYEOF
}

launch_bars() {
  for entry in $PIDS; do
    kill "${entry#*:}" 2>/dev/null
    wait "${entry#*:}" 2>/dev/null
  done
  PIDS=""
  while read -r m; do
    [ -z "$m" ] && continue
    render_config "$m"
    waybar -c "$RUNTIME_DIR/$m.jsonc" -s "$STYLE" &
    PIDS="$PIDS $m:$!"
  done < <(monitor_list)
  sleep 0.5
  ACTIVE="__UNSET__"
}

cleanup() {
  for entry in $PIDS; do
    kill "${entry#*:}" 2>/dev/null
  done
}
trap cleanup EXIT

launch_bars
LAST_MONITORS=$(monitor_list)

while true; do
  CURRENT_MONITORS=$(monitor_list)

  if [ "$CURRENT_MONITORS" != "$LAST_MONITORS" ]; then
    LAST_MONITORS="$CURRENT_MONITORS"
    launch_bars
  else
    # Relaunch if any instance died.
    for entry in $PIDS; do
      if ! kill -0 "${entry#*:}" 2>/dev/null; then
        launch_bars
        break
      fi
    done
  fi

  POS=$(hyprctl cursorpos -j)
  X=$(echo "$POS" | jq -r '.x')
  Y=$(echo "$POS" | jq -r '.y')

  # Monitor under the cursor and its top edge.
  read -r MON TOP < <(hyprctl monitors -j | jq -r --argjson x "$X" --argjson y "$Y" '
    [.[] | select(.x <= $x and .x + .width > $x and .y <= $y and .y + .height > $y)]
      | "\(.[0].name // "") \(.[0].y // -1)"')

  TARGET=""
  if [ -n "$MON" ] && [ "$TOP" -ge 0 ]; then
    DY=$((Y - TOP))
    if [ "$DY" -le "$REVEAL_HEIGHT" ] || { [ "$ACTIVE" = "$MON" ] && [ "$DY" -le "$DISMISS_HEIGHT" ]; }; then
      TARGET="$MON"
    fi
  fi

  if [ "$TARGET" != "$ACTIVE" ]; then
    for entry in $PIDS; do
      m=${entry%%:*}
      p=${entry#*:}
      if [ "$m" = "$TARGET" ]; then
        show "$p"
      else
        hide "$p"
      fi
    done
    ACTIVE="$TARGET"
  fi

  sleep 0.1
done
