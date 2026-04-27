#!/usr/bin/env bash
# Waybar tooltip for the system-monitor button.
# Dumps a btop-style snapshot of CPU, memory, disks, net, temps.
set -eu

# CPU usage (one-shot sample, ~1s delay)
cpu_idle_1=$(awk '/^cpu /{print $5}' /proc/stat)
cpu_total_1=$(awk '/^cpu /{s=0; for(i=2;i<=NF;i++) s+=$i; print s}' /proc/stat)
sleep 0.3
cpu_idle_2=$(awk '/^cpu /{print $5}' /proc/stat)
cpu_total_2=$(awk '/^cpu /{s=0; for(i=2;i<=NF;i++) s+=$i; print s}' /proc/stat)
cpu_pct=$(awk -v i1="$cpu_idle_1" -v t1="$cpu_total_1" -v i2="$cpu_idle_2" -v t2="$cpu_total_2" \
    'BEGIN{di=i2-i1; dt=t2-t1; if(dt<=0){print 0}else{printf "%.1f", (1 - di/dt)*100}}')

cpu_freq=$(awk '/cpu MHz/{s+=$4; n++} END{if(n)printf "%.0f MHz", s/n}' /proc/cpuinfo 2>/dev/null)
cpu_cores=$(nproc)

# Memory
read -r mem_total mem_used mem_free <<<"$(free -m | awk '/^Mem:/{print $2" "$3" "$4}')"
swap_line=$(free -m | awk '/^Swap:/{printf "%s / %s MiB", $3, $2}')
mem_pct=$(awk -v u="$mem_used" -v t="$mem_total" 'BEGIN{if(t)printf "%.1f", u*100/t; else print 0}')

# Load + uptime
load=$(awk '{printf "%s %s %s", $1, $2, $3}' /proc/loadavg)
uptime=$(uptime -p 2>/dev/null || echo "?")

# Disk
disk_line=$(df -h / | awk 'NR==2{printf "%s / %s (%s)", $3, $2, $5}')

# Temperature (lm_sensors, tolerant if missing)
temps=$(sensors 2>/dev/null | awk -F: '
    /Package id 0|Tctl|CPU Temp|edge/ {gsub(/^ */,"",$2); split($2,a," "); gsub(/[+°C]/,"",a[1]); printf "  %-14s %s°C\n", $1, a[1]}' \
    || echo "  (lm_sensors not configured)")

# Per-core (just show top 4 if many)
cores=$(grep -E '^cpu[0-9]+ ' /proc/stat | head -8 | awk '{print $1}' | tr '\n' ' ')

# Top 5 processes by CPU
procs=$(ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6 | awk 'NR==1{printf "  %-6s %-18s %6s %6s\n", "PID", "CMD", "CPU%", "MEM%"} NR>1{printf "  %-6s %-18.18s %6.1f %6.1f\n", $1, $2, $3, $4}')

# Network total since boot, per active interface
net=$(awk '
    NR>2 {
        iface=$1; gsub(":", "", iface);
        if (iface ~ /^(e[nt]|wl|ww|tun|wg)/) {
            rx=$2; tx=$10;
            printf "  %-10s RX %6.1f MiB  TX %6.1f MiB\n", iface, rx/1048576, tx/1048576
        }
    }' /proc/net/dev)
[ -z "$net" ] && net="  (no active interfaces)"

tooltip=$(cat <<EOF
<tt>System Monitor
───────────────────────────────
CPU       ${cpu_pct}%  ·  ${cpu_cores} cores  ·  ${cpu_freq:-?}
Memory    ${mem_used} / ${mem_total} MiB (${mem_pct}%)
Swap      ${swap_line}
Load      ${load}
Uptime    ${uptime}

Disk /    ${disk_line}

Temps
${temps}

Network
${net}

Top processes
${procs}

Click for btop live view</tt>
EOF
)

jq -cn --arg t "⚡" --arg tt "$tooltip" '{text:$t, tooltip:$tt, class:"sysmon"}'
