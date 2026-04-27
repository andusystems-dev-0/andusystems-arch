#!/usr/bin/env bash
# Audio menu: preset volumes, mute, device pickers, pavucontrol.
set -euo pipefail

source "$(dirname "$0")/_rofi.sh"

main() {
    cat <<EOF | rofi -dmenu "${ROFI_VIM_FLAGS[@]}" -i -p "Audio"
[vol]     Volume…
[mute]    Toggle mute
[out]     Output device…
[in]      Input device…
[gui]     Open pavucontrol
EOF
}

vol_menu() {
    v=$(printf "%s\n" "+5%" "-5%" "100%" "75%" "50%" "25%" "10%" "0%" \
        | rofi -dmenu "${ROFI_VIM_FLAGS[@]}" -i -p "Volume")
    [ -z "$v" ] && exit 0
    case "$v" in
        "+5%")  wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ ;;
        "-5%")  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
        *)      frac=$(awk -v v="${v%%%*}" 'BEGIN{printf "%.2f", v/100}')
                wpctl set-volume @DEFAULT_AUDIO_SINK@ "$frac" ;;
    esac
}

device_menu() {
    kind="$1"  # "Sinks" or "Sources"
    list=$(wpctl status 2>/dev/null | awk -v k="$kind:" '
        $0 ~ k {f=1; next}
        /^$/   {f=0}
        f && /^ *│/ {next}
        f && /^ *├─/ {next}
        f && /^ *└─/ {next}
        f && /^ *[*│ ]/ {
            line=$0; gsub(/^[ │├└─]*/, "", line); gsub(/\[.*$/, "", line);
            if (line ~ /^[*]? *[0-9]+\./) print line
        }')
    [ -z "$list" ] && { notify-send "Audio" "No $kind" 2>/dev/null || true; exit 0; }
    pick=$(printf "%s\n" "$list" | rofi -dmenu "${ROFI_VIM_FLAGS[@]}" -i -p "$kind")
    [ -z "$pick" ] && exit 0
    id=$(printf "%s" "$pick" | awk '{for(i=1;i<=NF;i++) if ($i ~ /^[0-9]+\.$/) {gsub(/\.$/,"",$i); print $i; exit}}')
    [ -z "$id" ] && exit 0
    wpctl set-default "$id"
}

sel=$(main)
case "${sel%%]*}" in
    "[vol")  vol_menu ;;
    "[mute") wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    "[out")  device_menu "Sinks" ;;
    "[in")   device_menu "Sources" ;;
    "[gui")  setsid -f pavucontrol >/dev/null 2>&1 ;;
esac
