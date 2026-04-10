#!/bin/bash
# Toggle btop scratchpad — starts it if not already running
if ! pgrep -x btop > /dev/null; then
    hyprctl dispatch exec '[workspace special:btop silent] kitty --title btop --class btop -e btop'
    sleep 0.4
fi
hyprctl dispatch togglespecialworkspace btop
