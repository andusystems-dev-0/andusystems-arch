#!/usr/bin/env bash
set -eu

powered=$(bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2; exit}' || echo "?")
connected=$(bluetoothctl devices Connected 2>/dev/null | awk '{$1=""; sub(/^ /,""); print}' || true)
[ -z "$connected" ] && connected="(none)"

paired=$(bluetoothctl devices Paired 2>/dev/null | wc -l)

tooltip=$(cat <<EOF
Bluetooth

Powered:    ${powered}
Paired:     ${paired} device(s)
Connected:
${connected}
EOF
)

jq -cn --arg t "ᛒ" --arg tt "$tooltip" '{text:$t, tooltip:$tt, class:"bluetooth"}'
