#!/usr/bin/env bash
# =============================================================================
# waybar-toggle.sh — toggle waybar visibility on a double-tap of Super_L.
# Stateless: waybar is shown when the process exists, hidden when it doesn't.
# No state file, no SIGUSR1 toggle drift.
#
#   init    hide waybar (kill the startup-launched instance)
#   super   called on every Super_L tap; toggles only on fast double-tap
# =============================================================================

set -euo pipefail

LAST="/tmp/waybar-toggle-$(id -u).last"
DOUBLE_TAP_MS=350

now_ms() { date +%s%3N; }

is_shown() { pgrep -x waybar >/dev/null 2>&1; }

show_bar() {
    is_shown && return 0
    nohup waybar >/dev/null 2>&1 &
    disown
}

hide_bar() {
    pkill -x waybar 2>/dev/null || true
}

toggle_bar() {
    if is_shown; then
        hide_bar
    else
        show_bar
    fi
}

case "${1:-}" in
    init)
        # Let the startup-launched waybar settle, then hide it
        for _ in $(seq 1 30); do
            is_shown && break
            sleep 0.1
        done
        sleep 0.3
        hide_bar
        printf '0\n' > "$LAST"
        ;;
    super)
        now=$(now_ms)
        last=$(cat "$LAST" 2>/dev/null || echo 0)
        printf '%s\n' "$now" > "$LAST"
        delta=$(( now - last ))
        if (( last > 0 && delta < DOUBLE_TAP_MS )); then
            toggle_bar
            # reset so a triple-tap isn't counted as two double-taps
            printf '0\n' > "$LAST"
        fi
        ;;
    *)
        echo "usage: $0 {init|super}" >&2
        exit 2
        ;;
esac
