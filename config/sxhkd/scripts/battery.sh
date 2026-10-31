#!/bin/bash
# ==========================================================
# battery.sh — Подробности о батарее в Rofi
# ==========================================================
# Вызывается по хоткею Super+Alt+B.
# Показывает Rofi-меню с деталями (заряд, статус, здоровье).
# ==========================================================

# --- 1. Автоопределение батареи ---
BAT=""
for b in /sys/class/power_supply/BAT*; do
    [ -d "$b" ] && BAT="$b" && break
done

# --- 2. Формирование меню и вывод ---
if [ -z "$BAT" ]; then
    echo "Питание: стационарный ПК (батареи нет)" | \
        rofi -dmenu -i -p "Питание" -theme-str 'window {width: 30%;}'
    exit 0
fi

bat_name=$(basename "$BAT")
cap=$(cat "$BAT/capacity" 2>/dev/null)
status=$(cat "$BAT/status" 2>/dev/null || echo "Unknown")

# --- Fallback для батарей без файла capacity ---
if [ -z "$cap" ]; then
    energy_now=$(cat "$BAT/energy_now" 2>/dev/null)
    energy_full=$(cat "$BAT/energy_full" 2>/dev/null)
    charge_now=$(cat "$BAT/charge_now" 2>/dev/null)
    charge_full=$(cat "$BAT/charge_full" 2>/dev/null)

    if [ -n "$energy_now" ] && [ -n "$energy_full" ] && [ "$energy_full" -gt 0 ]; then
        cap=$(( energy_now * 100 / energy_full ))
    elif [ -n "$charge_now" ] && [ -n "$charge_full" ] && [ "$charge_full" -gt 0 ]; then
        cap=$(( charge_now * 100 / charge_full ))
    else
        cap="?"
    fi
fi

case "$status" in
    Charging)      status_ru="Заряжается" ;;
    Discharging)   status_ru="Разряжается" ;;
    Full)          status_ru="Полностью заряжена" ;;
    Not\ charging) status_ru="Не заряжается" ;;
    *)             status_ru="$status" ;;
esac

# Без иконок: только текст
lines="Батарея ${bat_name}"$'\n'
lines+="Уровень: ${cap}%"$'\n'
lines+="Статус: ${status_ru}"$'\n'

power_now=$(cat "$BAT/power_now" 2>/dev/null || echo 0)
energy_now=$(cat "$BAT/energy_now" 2>/dev/null || echo 0)
energy_full=$(cat "$BAT/energy_full" 2>/dev/null || echo 0)

if [ "$power_now" -gt 0 ] 2>/dev/null; then
    power_w=$(awk "BEGIN {printf \"%.1f\", $power_now / 1000000}")
    lines+="Потребление: ${power_w} Вт"$'\n'

    if [ "$status" = "Discharging" ] && [ "$energy_now" -gt 0 ] 2>/dev/null; then
        hours=$(awk "BEGIN {printf \"%.1f\", $energy_now / $power_now}")
        lines+="Осталось: ~${hours} ч"$'\n'
    elif [ "$status" = "Charging" ] && [ "$energy_full" -gt 0 ] 2>/dev/null; then
        left=$(awk "BEGIN {printf \"%.1f\", ($energy_full - $energy_now) / $power_now}")
        lines+="До полной: ~${left} ч"$'\n'
    fi
fi

# --- Здоровье батареи ---
health=$(cat "$BAT/health" 2>/dev/null)
health_ru=""

if [ -n "$health" ]; then
    case "$health" in
        Good) health_ru="Хорошее" ;;
        Fair) health_ru="Удовлетворительное" ;;
        Poor) health_ru="Плохое" ;;
        *)    health_ru="$health" ;;
    esac
else
    design_energy=$(cat "$BAT/energy_full_design" 2>/dev/null || echo 0)
    if [ "$design_energy" -gt 0 ] 2>/dev/null && [ "$energy_full" -gt 0 ] 2>/dev/null; then
        health_pct=$(awk "BEGIN {printf \"%d\", $energy_full * 100 / $design_energy}")
        health_ru="${health_pct}%"
    else
        charge_full=$(cat "$BAT/charge_full" 2>/dev/null || echo 0)
        design_charge=$(cat "$BAT/charge_full_design" 2>/dev/null || echo 0)
        if [ "$design_charge" -gt 0 ] 2>/dev/null && [ "$charge_full" -gt 0 ] 2>/dev/null; then
            health_pct=$(awk "BEGIN {printf \"%d\", $charge_full * 100 / $design_charge}")
            health_ru="${health_pct}%"
        fi
    fi
fi

if [ -n "$health_ru" ]; then
    lines+="Здоровье: ${health_ru}"
fi

# --- Вывод в Rofi ---
echo "$lines" | \
    rofi -dmenu -i -p "Батарея" \
          -theme-str 'window {width: 30%;} listview {lines: 6;}'