#!/usr/bin/env bash
# Launch btop in a floating kitty window (sized/centered via Hyprland windowrule).
set -eu
setsid -f kitty --class sysmon-float -T "System Monitor" -e btop >/dev/null 2>&1
