#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/Wallpapers"
CURRENT_FILE="$HOME/.cache/current-wallpaper"

# Collect all wallpaper images
mapfile -t wallpapers < <(find -L "$WALLPAPER_DIR" -maxdepth 1 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
    2>/dev/null | sort)

if [[ ${#wallpapers[@]} -eq 0 ]]; then
    echo "theme-switch: no wallpapers found in $WALLPAPER_DIR" >&2
    exit 0
fi

# Pick a random wallpaper, avoiding the previous one if possible
WALLPAPER="${wallpapers[$((RANDOM % ${#wallpapers[@]}))]}"
if [[ ${#wallpapers[@]} -gt 1 && -f "$CURRENT_FILE" ]]; then
    PREV=$(cat "$CURRENT_FILE" 2>/dev/null || true)
    attempts=0
    while [[ "$WALLPAPER" == "$PREV" && $attempts -lt 10 ]]; do
        WALLPAPER="${wallpapers[$((RANDOM % ${#wallpapers[@]}))]}"
        ((attempts++))
    done
fi
echo "$WALLPAPER" > "$CURRENT_FILE"

# Ensure awww daemon is running; start it if not
if ! awww query &>/dev/null 2>&1; then
    awww-daemon &
    disown
fi

# Wait for awww daemon to be ready (up to 10s)
for i in {1..20}; do
    awww query &>/dev/null && break
    sleep 0.5
done

# Set wallpaper with smooth fade transition
awww img "$WALLPAPER" \
    --transition-type fade \
    --transition-duration 2 \
    --transition-fps 60

# Generate color scheme from wallpaper (outputs to template-defined paths)
matugen -t scheme-expressive image "$WALLPAPER" --mode dark --prefer saturation

# Reload waybar styles
pkill -SIGUSR2 waybar 2>/dev/null || true

# Reload hyprland to pick up new colors.conf
hyprctl reload 2>/dev/null || true

# Hot-reload running Neovim instances
for socket in "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/nvim.*; do
    [[ -S "$socket" ]] || continue
    nvim --server "$socket" --remote-send \
        '<C-\><C-n>:lua package.loaded["colors.matugen"]=nil; require("mini.base16").setup({palette=require("colors.matugen")})<CR>' \
        2>/dev/null || true
done
