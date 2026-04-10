#!/usr/bin/env bash
# Screenshot utility — grim + slurp + wl-clipboard
# Usage: screenshot.sh [region|fullscreen|window]  (no arg = rofi picker)

SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"
FILE="$SAVE_DIR/$(date +"%Y-%m-%d_%H-%M-%S").png"

MODE="${1:-pick}"

if [[ "$MODE" == "pick" ]]; then
    CHOICE=$(printf "Region\nFullscreen\nWindow" | rofi -dmenu -p "󰄀  Screenshot" -i)
    case "$CHOICE" in
        Region)     MODE="region" ;;
        Fullscreen) MODE="fullscreen" ;;
        Window)     MODE="window" ;;
        *)          exit 0 ;;
    esac
fi

case "$MODE" in
    region)
        grim -g "$(slurp)" "$FILE" || exit 0
        ;;
    fullscreen)
        grim "$FILE"
        ;;
    window)
        GEOMETRY=$(hyprctl clients -j | python3 -c "
import json, sys
for c in json.load(sys.stdin):
    if c.get('mapped') and not c.get('minimized'):
        x, y = c['at']
        w, h = c['size']
        print(f'{x},{y} {w}x{h}')
" | slurp -r) || exit 0
        grim -g "$GEOMETRY" "$FILE" || exit 0
        ;;
esac

wl-copy < "$FILE" 2>/dev/null || true
notify-send "Screenshot saved" "$(basename "$FILE")" -i "$FILE" 2>/dev/null || true
