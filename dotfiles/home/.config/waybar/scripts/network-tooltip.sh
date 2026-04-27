#!/usr/bin/env bash
# Waybar tooltip for the network button.
set -eu

status="offline"
active=$(nmcli -t -f NAME,TYPE,DEVICE connection show --active 2>/dev/null || true)
if [ -n "$active" ]; then
    status="online"
fi

lines="$active"
[ -z "$lines" ] && lines="(no active connections)"

# Primary IP (first non-loopback)
ip=$(ip -4 -o addr show scope global 2>/dev/null \
    | awk '{print $2" "$4}' | head -n1 || true)
[ -z "$ip" ] && ip="(no IPv4)"

# Wifi SSID if any
ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '$1=="yes"{print $2; exit}' || true)

tooltip=$(cat <<EOF
Network — $status

Active connections:
$lines

WiFi SSID: ${ssid:-(none)}
IP:        $ip
EOF
)

jq -cn --arg t "≋" --arg tt "$tooltip" '{text:$t, tooltip:$tt, class:"network"}'
