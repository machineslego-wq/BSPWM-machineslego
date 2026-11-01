#!/bin/bash
# ==========================================================
# preselect-cancel-all.sh — Снять preselect со всех окон стола
# ==========================================================

set -u

bspc query -N -d | xargs -r -I id bspc node id -p cancel

notify-send -a "BSPWM" -t 1000 \
            -h string:x-canonical-private-synchronous:preselect \
            "Preselect снят со стола"