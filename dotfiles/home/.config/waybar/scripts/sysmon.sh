#!/usr/bin/env bash
# Toggle the pre-warmed btop on its special workspace. Spawn one if missing
# (e.g. user quit btop with `q` and the kitty window closed).
set -eu

if ! hyprctl clients -j 2>/dev/null | grep -q '"class": "sysmon-float"'; then
    setsid -f kitty --class sysmon-float -T "System Monitor" -e btop >/dev/null 2>&1
    for _ in $(seq 1 15); do
        sleep 0.1
        hyprctl clients -j 2>/dev/null | grep -q '"class": "sysmon-float"' && break
    done
fi

hyprctl dispatch togglespecialworkspace sysmon >/dev/null
