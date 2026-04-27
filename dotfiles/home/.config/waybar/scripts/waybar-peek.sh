#!/usr/bin/env bash
# Peek-show waybar: reveal on SUPER press, auto-hide after PEEK_DURATION seconds.
# Every new press resets the timer. Hyprland does not emit bare-modifier release
# events reliably, so we don't key off release — we just run a fresh hide timer.
#   peek  reveal waybar (if hidden) and (re)schedule hide in PEEK_DURATION
#   init  mark waybar as hidden and cancel any pending hide (startup hook)
set -euo pipefail

STATE="/tmp/waybar-peek-$(id -u).state"
PID_FILE="/tmp/waybar-peek-$(id -u).hide.pid"
LOG="/tmp/waybar-peek-$(id -u).log"
PEEK_DURATION=5
log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" >> "$LOG"; }
log "invoked arg=${1:-}"

current() { cat "$STATE" 2>/dev/null || echo hidden; }
set_state() { printf '%s\n' "$1" > "$STATE"; }
toggle() { pkill -SIGUSR1 waybar 2>/dev/null || true; }

cancel_pending_hide() {
    if [ -f "$PID_FILE" ]; then
        kill "$(cat "$PID_FILE")" 2>/dev/null || true
        rm -f "$PID_FILE"
    fi
}

schedule_hide() {
    (
        sleep "$PEEK_DURATION"
        if [ "$(current)" = shown ]; then
            toggle
            set_state hidden
        fi
        rm -f "$PID_FILE"
    ) &
    echo $! > "$PID_FILE"
    disown
}

case "${1:-}" in
    peek)
        cancel_pending_hide
        if [ "$(current)" = hidden ]; then
            toggle
            set_state shown
        fi
        schedule_hide
        ;;
    init)
        cancel_pending_hide
        # Wait up to 3s for waybar to be ready, then hide it and mark state hidden.
        for _ in $(seq 1 30); do
            pgrep -x waybar >/dev/null && break
            sleep 0.1
        done
        sleep 0.3
        toggle
        set_state hidden
        ;;
    *)
        echo "usage: $0 {peek|init}" >&2
        exit 2
        ;;
esac
