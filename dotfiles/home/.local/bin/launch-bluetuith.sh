#!/bin/bash
# Toggle bluetuith scratchpad — starts it if not already running
if ! pgrep -x bluetuith > /dev/null; then
    hyprctl dispatch exec '[workspace special:bluetuith silent] kitty --title bluetuith --class bluetuith -e bluetuith'
    sleep 0.4
fi
hyprctl dispatch togglespecialworkspace bluetuith
