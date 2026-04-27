#!/usr/bin/env bash
# Vertical rofi popup anchored to the top-right, under the gear button.
# Overlays all windows via rofi's own layer surface.
set -euo pipefail

source "$(dirname "$0")/_rofi.sh"

theme='window { width: 220px; location: northeast; anchor: northeast; x-offset: -8px; y-offset: 42px; } listview { lines: 5; }'

choice=$(cat <<EOF | rofi -dmenu -i -p "Settings" -theme-str "$theme" "${ROFI_VIM_FLAGS[@]}"
☀  Display
≋  Network
ᛒ  Bluetooth
♪  Audio
⏻  Power
EOF
) || exit 0

[ -z "$choice" ] && exit 0

case "${choice:0:1}" in
    "☀") kitty --class display-float -T 'Display' -e ~/.config/waybar/scripts/display-menu.sh ;;
    "≋") ~/.config/waybar/scripts/network-menu.sh ;;
    "ᛒ") ~/.config/waybar/scripts/bluetooth-menu.sh ;;
    "♪") ~/.config/waybar/scripts/audio-menu.sh ;;
    "⏻") ~/.config/waybar/scripts/power-menu.sh ;;
esac
