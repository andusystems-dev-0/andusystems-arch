#!/bin/bash
# Toggle nmtui scratchpad — starts it if not already running
if ! pgrep -x nmtui > /dev/null; then
    hyprctl dispatch exec '[workspace special:nmtui silent] kitty --title nmtui --class nmtui -e nmtui'
    sleep 0.4
fi
hyprctl dispatch togglespecialworkspace nmtui
