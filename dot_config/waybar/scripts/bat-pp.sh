#!/bin/bash

# This variable selects mode to run.
MODE=$1

# Refreshes the whole module.
if [[ $MODE == "refresh" ]]; then

  # Get battery information.
  BATTERY=$(upower -e | grep 'BAT')
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

  # Simple battery icon based on percentage
  if [[ $PERCENT -lt 10 ]]; then
    ICON=""
  elif [[ $PERCENT -lt 25 ]]; then
    ICON=""
  elif [[ $PERCENT -lt 50 ]]; then
    ICON=""
  elif [[ $PERCENT -lt 75 ]]; then
    ICON=""
  else
    ICON=""
  fi

  # Export as json.
  printf '{"text": "%s", "class": "%s", "alt": "%s"}\n' "$ICON $PERCENT" "$CLASS" "$TOOLTIP W \n$EOL"
fi

# Indicator bar
if [[ $MODE == "bar" ]]; then
  BATTERY=$(upower -e | grep 'BAT')
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
