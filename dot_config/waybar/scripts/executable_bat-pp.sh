#!/bin/bash

# This variable selects mode to run.
MODE=$1

# Refreshes the whole module.
if [[ $MODE == "refresh" ]]; then

  # Get battery information.
  BATTERY=$(upower -e | grep 'BAT')
  
  # Exit silently if no battery is found (desktop PCs)
  if [[ -z "$BATTERY" ]]; then
    exit 0
  fi
  
  PERCENT=$(upower -i "$BATTERY" | awk '/percentage/ {print $2}' | tr -d '%')
  STATE=$(upower -i "$BATTERY" | awk '/state/ {print $2}' | tr -d '%')
  RATE=$(upower -i "$BATTERY" | awk '/energy-rate/ {print $2}' | tr -d '%')
  EOL="Empty in: \n$(upower -i "$BATTERY" | awk '/time to empty/ {for (i=4; i<=NF; i++) printf $i (i<NF?" ":"\n")}')"

  if [[ $EOL == "Empty in: \n" ]]; then
    EOL="Full in: \n$(upower -i "$BATTERY" | awk '/time to full/ {for (i=4; i<=NF; i++) printf $i (i<NF?" ":"\n")}')"
  fi

  # Set class for styling.
  if [[ $STATE == "charging" ]]; then
    CLASS=$"charging"
  elif [[ $PERCENT -le 10 ]]; then
    CLASS=$"critical"
  elif [[ $PERCENT -le 15 ]]; then
    CLASS=$"warning"
  else
    CLASS=$"normal"
  fi

  # Set energy rate polarity.
  if [[ $STATE == "charging" ]]; then
    TOOLTIP="+$RATE"
  else
    TOOLTIP=$"-$RATE"
  fi

  # Battery icon based on state and percentage
  if [[ $STATE == "charging" ]]; then
    ICON="󰂄"  # Charging icon
  elif [[ $PERCENT -lt 10 ]]; then
    ICON="󰂎"  # Empty
  elif [[ $PERCENT -lt 20 ]]; then
    ICON="󰁺"  # 10%
  elif [[ $PERCENT -lt 30 ]]; then
    ICON="󰁻"  # 20%
  elif [[ $PERCENT -lt 40 ]]; then
    ICON="󰁼"  # 30%
  elif [[ $PERCENT -lt 50 ]]; then
    ICON="󰁽"  # 40%
  elif [[ $PERCENT -lt 60 ]]; then
    ICON="󰁾"  # 50%
  elif [[ $PERCENT -lt 70 ]]; then
    ICON="󰁿"  # 60%
  elif [[ $PERCENT -lt 80 ]]; then
    ICON="󰂀"  # 70%
  elif [[ $PERCENT -lt 90 ]]; then
    ICON="󰂁"  # 80%
  elif [[ $PERCENT -lt 100 ]]; then
    ICON="󰂂"  # 90%
  else
    ICON="󰁹"  # Full
  fi

  # Export as json.
  printf '{"text": "%s", "class": "%s", "alt": "%s"}\n' "$ICON $PERCENT" "$CLASS" "$TOOLTIP W \n$EOL"
fi

# Indicator bar
if [[ $MODE == "bar" ]]; then
  BATTERY=$(upower -e | grep 'BAT')
  
  # Exit silently if no battery is found (desktop PCs)
  if [[ -z "$BATTERY" ]]; then
    exit 0
  fi
  
  PERCENT=$(upower -i "$BATTERY" | awk '/percentage/ {print $2}' | tr -d '%')
  STATE=$(upower -i "$BATTERY" | awk '/state/ {print $2}' | tr -d '%')

  # Set class for styling.
  if [[ $STATE == "fully-charged" ]]; then
    CLASS=$"full"
  elif [[ $STATE == "charging" ]]; then
    CLASS=$"charging"
  elif [[ $PERCENT -le 10 ]]; then
    CLASS=$"critical"
  elif [[ $PERCENT -le 15 ]]; then
    CLASS=$"warning"
  else
    CLASS=$"discharging"
  fi

  # Export as json.
  printf '{"class": "%s"}\n' "$CLASS"
fi
