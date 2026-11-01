#!/bin/bash
# ==========================================================
# to-preselect.sh — Отправить помеченное окно в preselect + OSD
# ==========================================================

set -u

if ! MARKED=$(bspc query -N -n newest.marked.local 2>/dev/null) || [ -z "$MARKED" ]; then
    notify-send -a "BSPWM" -t 2000 \
        -h string:hlcolor:"#f7768e" \
        "Preselect" "Нет помеченных окон (Super+Ctrl+M)"
    exit 0
fi

WIN=$(bspc query -T -n "$MARKED" | jq -r '.client.className // "?"')
bspc node newest.marked.local -n newest.!automatic.local

notify-send -a "BSPWM" -t 1000 \
    -h string:x-canonical-private-synchronous:bspc-preselect \
    -h string:hlcolor:"#9ece6a" \
    "→ Preselect" "$WIN"