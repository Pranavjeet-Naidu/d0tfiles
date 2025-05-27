#!/bin/bash

# Get current workspace before launching rofi
CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')

# Store current window focus
CURRENT_WINDOW=$(hyprctl activewindow -j | jq -r '.address')

# Set action based on parameter
if [[ "$1" == "delete" ]]; then
  cliphist list | rofi -dmenu | cliphist delete
else
  cliphist list | rofi -dmenu | cliphist decode | wl-copy
fi

# Force back to original workspace
AFTER_WS=$(hyprctl activeworkspace -j | jq -r '.id')
if [[ "$CURRENT_WS" != "$AFTER_WS" ]]; then
  hyprctl dispatch workspace "$CURRENT_WS"
fi

# Restore window focus if possible
if [[ "$CURRENT_WINDOW" != "0x0" ]]; then
  hyprctl dispatch focuswindow address:"$CURRENT_WINDOW"
fi