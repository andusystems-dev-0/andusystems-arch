#!/usr/bin/env bash
# Compact one-line system stats for waybar (always-visible left module).
# Format: CPU% | MEM used/total | DISK% | TEMP | ↓down ↑up
set -eu

# CPU (short delta sample)
read -r idle1 total1 < <(awk '/^cpu /{i=$5; t=0; for(j=2;j<=NF;j++) t+=$j; print i, t; exit}' /proc/stat)
sleep 0.3
read -r idle2 total2 < <(awk '/^cpu /{i=$5; t=0; for(j=2;j<=NF;j++) t+=$j; print i, t; exit}' /proc/stat)
cpu=$(awk -v i1="$idle1" -v t1="$total1" -v i2="$idle2" -v t2="$total2" \
    'BEGIN{di=i2-i1; dt=t2-t1; printf "%.0f", (dt>0)?(1-di/dt)*100:0}')

# Memory
read -r used_m total_m < <(free -m | awk '/^Mem:/{print $3, $2}')
mem=$(awk -v u="$used_m" -v t="$total_m" 'BEGIN{printf "%.1f/%.0fG", u/1024, t/1024}')

# Disk (root filesystem)
disk=$(df -P / | awk 'NR==2{gsub("%","",$5); print $5}')

# Temp (first value seen from common sensor labels)
temp=$(sensors 2>/dev/null | awk '
    /Tctl|Package id 0|edge/ {
        for (i=2; i<=NF; i++) if ($i ~ /°C/) { gsub(/[+°C]/, "", $i); print $i; exit }
    }')
temp=${temp%.*}
temp=${temp:-?}

# Network rate using state file across invocations
state=/tmp/waybar-sysmon-net
iface=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<NF;i++) if($i=="dev"){print $(i+1); exit}}')
rx=0; tx=0
if [ -n "${iface:-}" ]; then
    line=$(awk -v key="${iface}:" '$1==key {print}' /proc/net/dev)
    rx=$(echo "$line" | awk '{print $2}')
    tx=$(echo "$line" | awk '{print $10}')
fi
rx=${rx:-0}; tx=${tx:-0}
now=$(date +%s)
if [ -f "$state" ] && read -r prev_t prev_rx prev_tx <"$state"; then :; else
    prev_t=$now; prev_rx=$rx; prev_tx=$tx
fi
echo "$now $rx $tx" >"$state"
dt=$((now - prev_t)); [ "$dt" -le 0 ] && dt=1
drx=$((rx - prev_rx)); dtx=$((tx - prev_tx))
[ "$drx" -lt 0 ] && drx=0
[ "$dtx" -lt 0 ] && dtx=0

fmt_rate() {
    local bps=$(( $1 / dt ))
    if [ "$bps" -lt 1024 ]; then
        printf "%dB" "$bps"
    elif [ "$bps" -lt 1048576 ]; then
        printf "%dK" "$(( bps / 1024 ))"
    else
        awk -v b="$bps" 'BEGIN{printf "%.1fM", b/1048576}'
    fi
}
down=$(fmt_rate "$drx")
up=$(fmt_rate "$dtx")

printf "CPU %s%% | MEM %s | DISK %s%% | %s°C | ↓%s ↑%s\n" \
    "$cpu" "$mem" "$disk" "$temp" "$down" "$up"
