#!/bin/bash
# ============================================================
#     Скрипт для запуска Polybar с параметрами для баттареи
# ============================================================

# Автоопределение батареи и адаптера для Polybar
for bat in /sys/class/power_supply/BAT*; do
    if [ -d "$bat" ]; then
        export POLYBAR_BAT=$(basename "$bat")
        break
    fi
done

for ac in /sys/class/power_supply/*; do
    if [ -f "$ac/online" ]; then
        export POLYBAR_AC=$(basename "$ac")
        break
    fi
done

# Убиваем существующие процессы и запускаем новый экземпляр Polybar
pkill -x polybar
while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done
polybar main &
