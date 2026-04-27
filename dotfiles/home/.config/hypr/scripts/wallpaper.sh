#!/usr/bin/env bash
# =============================================================================
# wallpaper.sh — pick a wallpaper from the dotfiles repo and (re)start
# hyprpaper with it. Sidesteps hyprctl<->hyprpaper IPC (which has a version
# mismatch on Arch's hyprland 0.54 / hyprpaper 0.8).
#
# Usage:
#   wallpaper.sh                      # random image in WALLPAPER_DIR (default)
#   wallpaper.sh --first              # first image alphabetically
#   wallpaper.sh /path/to/image.png   # pick a specific file
# =============================================================================

set -euo pipefail

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/andusystems/andusystems-arch/wallpapers}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/hypr"
CACHE_CONF="$CACHE_DIR/wallpaper.conf"
STATE_FILE="$CACHE_DIR/wallpaper.current"

shopt -s nullglob nocaseglob
mapfile -t wallpapers < <(
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
           -o -iname '*.webp' -o -iname '*.bmp' \) | sort
)
shopt -u nocaseglob

if (( ${#wallpapers[@]} == 0 )); then
    echo "wallpaper.sh: no images in $WALLPAPER_DIR" >&2
    exit 0
fi

case "${1:-}" in
    --first)
        wallpaper="${wallpapers[0]}"
        ;;
    --random|"")
        current=""
        [[ -f "$STATE_FILE" ]] && current="$(< "$STATE_FILE")"
        candidates=("${wallpapers[@]}")
        if (( ${#wallpapers[@]} > 1 )) && [[ -n "$current" ]]; then
            candidates=()
            for w in "${wallpapers[@]}"; do
                [[ "$w" != "$current" ]] && candidates+=("$w")
            done
            (( ${#candidates[@]} == 0 )) && candidates=("${wallpapers[@]}")
        fi
        wallpaper="${candidates[RANDOM % ${#candidates[@]}]}"
        ;;
    *)
        if [[ -f "$1" ]]; then
            wallpaper="$1"
        else
            echo "wallpaper.sh: not a file: $1" >&2
            exit 1
        fi
        ;;
esac

mkdir -p "$CACHE_DIR"
# hyprpaper 0.8+ uses block syntax (the old preload= + wallpaper=monitor,path pair
# is gone). One `wallpaper { }` block per active monitor.
{
    echo "splash = false"
    echo
    while read -r monitor; do
        [[ -z "$monitor" ]] && continue
        cat <<EOF
wallpaper {
    monitor = $monitor
    path = $wallpaper
    fit_mode = cover
}
EOF
    done < <(hyprctl monitors 2>/dev/null | grep -oP '^Monitor \K\S+' || echo "")
} > "$CACHE_CONF"

# Fallback: if no monitors were detected (hyprctl failed), write an empty-monitor
# entry so hyprpaper at least tries to cover the default output.
if ! grep -q '^wallpaper {' "$CACHE_CONF"; then
    cat >> "$CACHE_CONF" <<EOF
wallpaper {
    monitor =
    path = $wallpaper
    fit_mode = cover
}
EOF
fi

pkill -x hyprpaper 2>/dev/null || true
# Give Wayland a beat to release the previous surface
sleep 0.15
nohup hyprpaper --config "$CACHE_CONF" >/dev/null 2>&1 &
disown

echo "$wallpaper" > "$STATE_FILE"

echo "wallpaper.sh: set $(basename "$wallpaper")"
