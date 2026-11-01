#!/bin/bash
# ==========================================================
# focus-history.sh — Навигация по истории фокуса
# Использование: focus-history.sh {older|newer}
# ==========================================================

set -u

DIR="${1:-}"
case "$DIR" in
    older|newer) ;;
    *) echo "usage: $0 {older|newer}" >&2; exit 1 ;;
esac

bspc wm -h off
bspc node "$DIR" -f
bspc wm -h on