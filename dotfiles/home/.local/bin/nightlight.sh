#!/usr/bin/env bash
# Nightlight: warm at night, intense after 21:00
# Update -l (latitude) and -L (longitude) to your location

pkill wlsunset 2>/dev/null || true
sleep 0.2

hour=$(date +%-H)
if (( hour >= 21 || hour < 7 )); then
    wlsunset -t 2700 -T 6500 -l 40.0 -L -75.0 &
else
    wlsunset -t 3800 -T 6500 -l 40.0 -L -75.0 &
fi
