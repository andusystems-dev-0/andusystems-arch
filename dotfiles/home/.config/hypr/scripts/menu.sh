#!/usr/bin/env bash
# =============================================================================
# menu.sh — modal app launcher around `rofi -show drun`.
#
# Mode flow:
#   Nav mode (default on launch):
#     j / k / Up / Down → move selection
#     l / Enter         → launch highlighted app
#     h / Escape        → quit
#     any other letter  → switch to search mode (letter triggers the swap;
#                         the search starts blank, type your query)
#
#   Search mode:
#     standard rofi (type to filter, Enter to launch, Escape to cancel).
#
# Why two phases: rofi has no native "modal" mode. We hide the entry widget
# in nav mode so j/k aren't typed into a search box, and bind every other
# letter to a custom keybind that exits with code 10 — the script then
# re-launches rofi normally to give you the full search experience.
# =============================================================================

set -euo pipefail

# Letters that switch us into search mode. j/k/h/l are reserved for navigation.
SWITCH_KEYS="a,b,c,d,e,f,g,i,m,n,o,p,q,r,s,t,u,v,w,x,y,z"

# Strip the entry widget from the layout and show a static prompt banner.
NAV_THEME='
inputbar { children: [ prompt ]; }
prompt   { str: "[NAV]  j/k=move  i=search  Enter=launch  Esc=quit  "; }
'

rofi -show drun \
    -theme-str       "$NAV_THEME" \
    -kb-row-down     "j,Down" \
    -kb-row-up       "k,Up" \
    -kb-accept-entry "Return,l" \
    -kb-cancel       "Escape,h" \
    -kb-custom-1     "$SWITCH_KEYS"

case "$?" in
    10) exec rofi -show drun ;;   # letter pressed → search mode
    *)  : ;;                      # 0 = launched, 1 = cancelled, propagate
esac
