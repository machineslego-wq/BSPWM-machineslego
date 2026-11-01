#!/bin/bash
# ==========================================================
# flag.sh — Toggle флага окна с OSD (ВКЛ/выкл)
# Использование: flag.sh <marked|locked|sticky|private>
# ==========================================================

set -u

case "${1:-}" in
    marked)  RU="Помечено" ;;
    locked)  RU="Защита"   ;;
    sticky)  RU="Везде"    ;;
    private) RU="Приватно" ;;
    *) echo "usage: $0 <marked|locked|sticky|private>" >&2; exit 1 ;;
esac

BEFORE=$(bspc query -N -n "focused.${1}" 2>/dev/null)
bspc node -g "$1"
AFTER=$(bspc query -N -n "focused.${1}" 2>/dev/null)

if   [ -z "$BEFORE" ] && [ -n "$AFTER" ]; then STATE="ВКЛ";  COLOR="#9ece6a"
elif [ -n "$BEFORE" ] && [ -z "$AFTER" ]; then STATE="выкл"; COLOR="#565f89"
else                                           STATE="?";    COLOR="#e0af68"
fi

notify-send -a "BSPWM" -t 1000 \
    -h string:x-canonical-private-synchronous:bspc-flag \
    -h string:hlcolor:"$COLOR" \
    "Флаг: $RU" "$STATE"