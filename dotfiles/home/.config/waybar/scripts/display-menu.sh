#!/usr/bin/env bash
# TUI with three sliders: brightness / warmth / gamma.
# ← →  adjust current slider
# ↑ ↓  switch slider (Tab also works)
# r    reset current to default
# q    quit
set -euo pipefail

BUS_NAME="rs.wl-gammarelay"
BUS_PATH="/"
BUS_IFACE="rs.wl.gammarelay"

# ── getters / setters ───────────────────────────────────────────────
get_brightness() {
    brightnessctl -m 2>/dev/null | awk -F, '{gsub("%","",$4); print int($4)}' \
        || echo 50
}
set_brightness() { brightnessctl -q set "$1%" >/dev/null 2>&1 || true; }

get_warmth() {
    busctl --user get-property "$BUS_NAME" "$BUS_PATH" "$BUS_IFACE" Temperature 2>/dev/null \
        | awk '{print $2}' || echo 6500
}
set_warmth() {
    busctl --user set-property "$BUS_NAME" "$BUS_PATH" "$BUS_IFACE" Temperature q "$1" 2>/dev/null || true
}

get_gamma_pct() {
    v=$(busctl --user get-property "$BUS_NAME" "$BUS_PATH" "$BUS_IFACE" Brightness 2>/dev/null \
        | awk '{print $2}')
    awk -v v="${v:-1.0}" 'BEGIN{printf "%d", v*100}'
}
set_gamma_pct() {
    frac=$(awk -v v="$1" 'BEGIN{printf "%.2f", v/100}')
    busctl --user set-property "$BUS_NAME" "$BUS_PATH" "$BUS_IFACE" Brightness d "$frac" 2>/dev/null || true
}

# ── state ───────────────────────────────────────────────────────────
LABELS=("Brightness" "Warmth" "Gamma")
UNITS=("%" "K" "%")
MIN=(1 1000 10)
MAX=(100 10000 150)
STEP=(5 250 5)
DEFAULT=(100 6500 100)
VAL=("$(get_brightness)" "$(get_warmth)" "$(get_gamma_pct)")
SEL=0
BAR_WIDTH=32

# ── rendering ───────────────────────────────────────────────────────
draw_slider() {
    local idx="$1"
    local label="${LABELS[$idx]}"
    local val="${VAL[$idx]}"
    local min="${MIN[$idx]}"
    local max="${MAX[$idx]}"
    local unit="${UNITS[$idx]}"
    local range=$((max - min))
    local fill=$(( (val - min) * BAR_WIDTH / range ))
    (( fill < 0 )) && fill=0
    (( fill > BAR_WIDTH )) && fill=$BAR_WIDTH
    local empty=$((BAR_WIDTH - fill))

    local bar=""
    (( fill > 0 )) && bar=$(printf '█%.0s' $(seq 1 $fill))
    (( empty > 0 )) && bar+=$(printf '░%.0s' $(seq 1 $empty))

    local prefix="  "
    local reset_seq=$'\033[0m'
    local active_seq=""
    if [ "$SEL" = "$idx" ]; then
        prefix="▶ "
        active_seq=$'\033[1;97m'
    else
        active_seq=$'\033[90m'
    fi
    printf "  %b%s%-11s  [%s]  %4s%s%b\n" \
        "$active_seq" "$prefix" "$label" "$bar" "$val" "$unit" "$reset_seq"
}

render() {
    printf '\033[H\033[2J'   # cursor home, clear
    printf '\n  \033[1;97mDisplay\033[0m\n'
    printf '  \033[90m─────────────────────────────────────────────────────\033[0m\n'
    printf '\n\n'                        # padding above bars
    for i in 0 1 2; do
        draw_slider "$i"
        printf '\n'                      # padding between bars
    done
    printf '\n'                          # padding below bars
    printf '  \033[90mh j k l  (or arrows)    Tab select    r reset    q quit\033[0m\n'
}

apply() {
    case "$SEL" in
        0) set_brightness  "${VAL[$SEL]}" ;;
        1) set_warmth      "${VAL[$SEL]}" ;;
        2) set_gamma_pct   "${VAL[$SEL]}" ;;
    esac
}

inc() {
    VAL[$SEL]=$(( VAL[SEL] + STEP[SEL] ))
    (( VAL[SEL] > MAX[SEL] )) && VAL[$SEL]=${MAX[$SEL]}
    apply
}
dec() {
    VAL[$SEL]=$(( VAL[SEL] - STEP[SEL] ))
    (( VAL[SEL] < MIN[SEL] )) && VAL[$SEL]=${MIN[$SEL]}
    apply
}
reset_current() {
    VAL[$SEL]=${DEFAULT[$SEL]}
    apply
}

# ── terminal setup ──────────────────────────────────────────────────
cleanup() {
    stty "$OLD_STTY" 2>/dev/null || stty sane
    printf '\033[?25h'   # show cursor
    printf '\033[2J\033[H'
}
trap cleanup EXIT INT TERM

OLD_STTY=$(stty -g)
stty -echo -icanon
printf '\033[?25l'       # hide cursor

render
while IFS= read -rsn1 ch; do
    case "$ch" in
        $'\e')
            IFS= read -rsn2 -t 0.01 rest || rest=""
            case "$rest" in
                '[A') SEL=$(( (SEL + 2) % 3 )) ;;   # up
                '[B') SEL=$(( (SEL + 1) % 3 )) ;;   # down
                '[C') inc ;;                        # right
                '[D') dec ;;                        # left
                '')   break ;;                      # plain ESC
            esac
            ;;
        $'\t') SEL=$(( (SEL + 1) % 3 )) ;;
        h|H)   dec ;;
        l|L)   inc ;;
        k|K)   SEL=$(( (SEL + 2) % 3 )) ;;
        j|J)   SEL=$(( (SEL + 1) % 3 )) ;;
        q|Q)   break ;;
        r|R)   reset_current ;;
    esac
    render
done
