#!/bin/bash
# ============================================================
# Старый запуск без подсчета ширины экрана, далее новый с под-
# счетом ширины экрана и записи их в переменные для polybar
# ============================================================

# ------------------------------------------------------------
# pkill -x polybar
# while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done
# polybar main &
# ------------------------------------------------------------

# Запуск Polybar с расчётом отступов под разрешение

# Убиваем старый Polybar
pkill -x polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Определяем ширину первого монитора
MONITOR_WIDTH=$(xrandr --current | grep " connected" | head -1 | grep -oP '\d+(?=x\d+)')
[ -z "$MONITOR_WIDTH" ] && MONITOR_WIDTH=1366  # fallback

# Зазор вокруг панели (по краям и сверху)
GAP=4

# Считаем ширину панели и отступ слева
PANEL_WIDTH=$((MONITOR_WIDTH - GAP * 2))
PANEL_OFFSET_X=$GAP

# Экспортируем переменные для Polybar
export PANEL_WIDTH
export PANEL_OFFSET_X
export PANEL_OFFSET_Y=$GAP

echo "Панель: ${PANEL_WIDTH}px, отступы: ${GAP}px"

# Запускаем
polybar main &