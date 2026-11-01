#!/bin/bash
# ==========================================================
# session-restart.sh — Перезапуск SXHKD, BSPWM и апплетов
# ==========================================================

pkill -USR1 -x sxhkd

for app in polybar picom dunst blueman-applet xss-lock lxpolkit copyq; do
    pkill -x "$app" || true
done

bspc wm -r