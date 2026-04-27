#!/usr/bin/env bash
# Power menu: lock, logout, suspend, reboot, shutdown.
set -euo pipefail

source "$(dirname "$0")/_rofi.sh"

sel=$(cat <<EOF | rofi -dmenu "${ROFI_VIM_FLAGS[@]}" -i -p "Power"
[lock]     Lock screen
[suspend]  Suspend
[logout]   Log out of Hyprland
[reboot]   Reboot
[shutdown] Shut down
EOF
)

case "${sel%%]*}" in
    "[lock")
        if command -v hyprlock >/dev/null; then
            setsid -f hyprlock >/dev/null 2>&1
        elif command -v loginctl >/dev/null; then
            loginctl lock-session
        fi
        ;;
    "[suspend")  systemctl suspend ;;
    "[logout")
        if command -v hyprshutdown >/dev/null; then
            hyprshutdown
        else
            hyprctl dispatch exit
        fi
        ;;
    "[reboot")   systemctl reboot ;;
    "[shutdown") systemctl poweroff ;;
esac
