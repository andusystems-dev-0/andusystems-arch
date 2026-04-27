#!/usr/bin/env bash
set -eu

sink_state=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || echo "Volume: 0.00")
vol_raw=$(printf "%s" "$sink_state" | awk '{print $2}')
vol_pct=$(awk -v v="$vol_raw" 'BEGIN{printf "%d", v*100}')
muted="no"
printf "%s" "$sink_state" | grep -q "MUTED" && muted="yes"

default_sink=$(wpctl status 2>/dev/null | awk '/Sinks:/{f=1;next} /^$/{f=0} f && /\*/{$1="";$2="";sub(/^  */,""); sub(/\[.*$/,""); print; exit}')
default_src=$(wpctl status  2>/dev/null | awk '/Sources:/{f=1;next} /^$/{f=0} f && /\*/{$1="";$2="";sub(/^  */,""); sub(/\[.*$/,""); print; exit}')
[ -z "${default_sink:-}" ] && default_sink="(none)"
[ -z "${default_src:-}" ]  && default_src="(none)"

tooltip=$(cat <<EOF
Audio

Volume:   ${vol_pct}%  (muted: ${muted})
Output:   ${default_sink}
Input:    ${default_src}

Scroll on button to adjust volume.
EOF
)

jq -cn --arg t "♪" --arg tt "$tooltip" '{text:$t, tooltip:$tt, class:"audio"}'
