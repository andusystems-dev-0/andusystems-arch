#!/usr/bin/env bash
# Rofi menu for NetworkManager: wifi list/connect, toggle, VPN, open editor.
set -euo pipefail

source "$(dirname "$0")/_rofi.sh"

wifi_state() { nmcli -t -f WIFI g 2>/dev/null | head -n1 || echo "unknown"; }
wifi_enabled() { [ "$(wifi_state)" = "enabled" ]; }

main() {
    wifi="$(wifi_state)"
    ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null \
        | awk -F: '$1=="yes"{print $2; exit}' || true)
    conn_label="(disconnected)"
    [ -n "$ssid" ] && conn_label="$ssid"

    opts=$(cat <<EOF
[connected]  $conn_label
[wifi]       Scan & connect…
[toggle]     Turn WiFi ${wifi/enabled/off}${wifi/disabled/on}
[disconnect] Disconnect current WiFi
[vpn]        VPN…
[editor]     Advanced (nm-connection-editor)
[status]     Show full status
EOF
)
    printf "%s\n" "$opts" | rofi -dmenu "${ROFI_VIM_FLAGS[@]}" -i -p "Network"
}

wifi_scan_menu() {
    nmcli dev wifi rescan 2>/dev/null || true
    list=$(nmcli -t -f IN-USE,SSID,SECURITY,SIGNAL dev wifi list 2>/dev/null \
        | awk -F: 'length($2)>0 {printf "%s  %-32s %-12s %s%%\n", ($1=="*"?"●":" "), $2, $3, $4}')
    [ -z "$list" ] && { notify-send "Network" "No WiFi networks found." 2>/dev/null || true; exit 0; }

    choice=$(printf "%s\n" "$list" | rofi -dmenu "${ROFI_VIM_FLAGS[@]}" -i -p "WiFi")
    [ -z "$choice" ] && exit 0
    ssid=$(printf "%s" "$choice" | awk '{print $2}')
    [ -z "$ssid" ] && exit 0

    if nmcli -t -f NAME connection show | grep -qxF "$ssid"; then
        nmcli connection up id "$ssid"
    else
        pw=$(rofi -dmenu -password -p "Password for $ssid")
        if [ -n "$pw" ]; then
            nmcli dev wifi connect "$ssid" password "$pw" 2>&1 \
                | xargs -0 -I{} notify-send "Network" "{}" 2>/dev/null || true
        else
            nmcli dev wifi connect "$ssid" 2>&1 \
                | xargs -0 -I{} notify-send "Network" "{}" 2>/dev/null || true
        fi
    fi
}

vpn_menu() {
    list=$(nmcli -t -f NAME,TYPE connection show 2>/dev/null \
        | awk -F: '$2 ~ /vpn|wireguard/ {print $1}')
    [ -z "$list" ] && { notify-send "VPN" "No VPN profiles configured." 2>/dev/null || true; exit 0; }
    pick=$(printf "%s\n" $list | rofi -dmenu "${ROFI_VIM_FLAGS[@]}" -i -p "VPN")
    [ -z "$pick" ] && exit 0
    if nmcli -t -f NAME,STATE connection show --active | grep -q "^$pick:"; then
        nmcli connection down id "$pick"
    else
        nmcli connection up id "$pick"
    fi
}

status_dump() {
    {
        echo "=== Devices ==="
        nmcli dev status
        echo
        echo "=== Active connections ==="
        nmcli -t connection show --active
        echo
        echo "=== IP addresses ==="
        ip -br addr show
    } 2>/dev/null | rofi -dmenu "${ROFI_VIM_FLAGS[@]}" -i -p "Network status" -mesg "scroll / esc to close" -lines 20
}

sel=$(main)
case "${sel%%]*}" in
    "[wifi")       wifi_scan_menu ;;
    "[toggle")     if wifi_enabled; then nmcli radio wifi off; else nmcli radio wifi on; fi ;;
    "[disconnect") ssid=$(nmcli -t -f active,ssid dev wifi | awk -F: '$1=="yes"{print $2; exit}'); [ -n "$ssid" ] && nmcli connection down id "$ssid" ;;
    "[vpn")        vpn_menu ;;
    "[editor")     setsid -f nm-connection-editor >/dev/null 2>&1 ;;
    "[status")     status_dump ;;
esac
