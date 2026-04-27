#!/usr/bin/env bash
# Bluetooth control menu via rofi + bluetoothctl.
set -euo pipefail

source "$(dirname "$0")/_rofi.sh"

powered() { bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2; exit}'; }

main() {
    pw=$(powered)
    opts=$(cat <<EOF
[power]     Turn Bluetooth ${pw/yes/off}${pw/no/on}
[scan]      Scan for new devices…
[paired]    Paired devices…
[connected] Disconnect a device…
[manager]   Open Blueman manager
EOF
)
    printf "%s\n" "$opts" | rofi -dmenu "${ROFI_VIM_FLAGS[@]}" -i -p "Bluetooth"
}

scan_menu() {
    # Start scan in background, wait a moment, then show results.
    bluetoothctl scan on >/dev/null 2>&1 &
    scan_pid=$!
    notify-send "Bluetooth" "Scanning for 6s…" 2>/dev/null || true
    sleep 6
    kill "$scan_pid" 2>/dev/null || true
    bluetoothctl scan off >/dev/null 2>&1 || true

    list=$(bluetoothctl devices 2>/dev/null | awk '{mac=$2; $1=""; $2=""; sub(/^  */,""); printf "%s  %s\n", mac, $0}')
    [ -z "$list" ] && { notify-send "Bluetooth" "No devices found." 2>/dev/null || true; exit 0; }

    pick=$(printf "%s\n" "$list" | rofi -dmenu "${ROFI_VIM_FLAGS[@]}" -i -p "Pair / connect")
    [ -z "$pick" ] && exit 0
    mac=$(printf "%s" "$pick" | awk '{print $1}')
    bluetoothctl pair "$mac" >/dev/null 2>&1 || true
    bluetoothctl trust "$mac" >/dev/null 2>&1 || true
    bluetoothctl connect "$mac" 2>&1 | head -c 200 | xargs -0 -I{} notify-send "Bluetooth" "{}" 2>/dev/null || true
}

paired_menu() {
    list=$(bluetoothctl devices Paired 2>/dev/null)
    [ -z "$list" ] && { notify-send "Bluetooth" "No paired devices." 2>/dev/null || true; exit 0; }
    pick=$(printf "%s" "$list" | rofi -dmenu "${ROFI_VIM_FLAGS[@]}" -i -p "Connect paired device")
    [ -z "$pick" ] && exit 0
    mac=$(printf "%s" "$pick" | awk '{print $2}')
    bluetoothctl connect "$mac" 2>&1 | head -c 200 | xargs -0 -I{} notify-send "Bluetooth" "{}" 2>/dev/null || true
}

disconnect_menu() {
    list=$(bluetoothctl devices Connected 2>/dev/null)
    [ -z "$list" ] && { notify-send "Bluetooth" "Nothing connected." 2>/dev/null || true; exit 0; }
    pick=$(printf "%s" "$list" | rofi -dmenu "${ROFI_VIM_FLAGS[@]}" -i -p "Disconnect")
    [ -z "$pick" ] && exit 0
    mac=$(printf "%s" "$pick" | awk '{print $2}')
    bluetoothctl disconnect "$mac"
}

sel=$(main)
case "${sel%%]*}" in
    "[power")     if [ "$(powered)" = "yes" ]; then bluetoothctl power off; else bluetoothctl power on; fi ;;
    "[scan")      scan_menu ;;
    "[paired")    paired_menu ;;
    "[connected") disconnect_menu ;;
    "[manager")   setsid -f blueman-manager >/dev/null 2>&1 ;;
esac
