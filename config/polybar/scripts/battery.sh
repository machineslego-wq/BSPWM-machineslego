#!/bin/bash

# 1. ЕСЛИ СКРИПТ ЗАПУЩЕН С АРГУМЕНТОМ --menu (ДЛЯ ROFI)
if [ "$1" = "--menu" ]; then
    BAT=""
    for b in /sys/class/power_supply/BAT*; do
        [ -d "$b" ] && BAT="$b" && break
    done

    if [ -z "$BAT" ]; then
        echo "Батарея не найдена" | rofi -dmenu -p "Питание"
        exit 0
    fi

    status=$(cat "$BAT/status" 2>/dev/null)
    capacity=$(cat "$BAT/capacity" 2>/dev/null)
    energy_now=$(cat "$BAT/energy_now" 2>/dev/null)
    energy_full=$(cat "$BAT/energy_full" 2>/dev/null)
    energy_design=$(cat "$BAT/energy_full_design" 2>/dev/null)
    power_now=$(cat "$BAT/power_now" 2>/dev/null)
    charge_now=$(cat "$BAT/charge_now" 2>/dev/null)
    charge_full=$(cat "$BAT/charge_full" 2>/dev/null)
    current_now=$(cat "$BAT/current_now" 2>/dev/null)

    # Если capacity нет, считаем сами (для новых ноутов)
    if [ -z "$capacity" ]; then
        if [ -n "$energy_now" ] && [ -n "$energy_full" ] && [ "$energy_full" -gt 0 ]; then
            capacity=$(( energy_now * 100 / energy_full ))
        elif [ -n "$charge_now" ] && [ -n "$charge_full" ] && [ "$charge_full" -gt 0 ]; then
            capacity=$(( charge_now * 100 / charge_full ))
        fi
    fi

    [ -z "$capacity" ] && capacity="0"

    # Переводим статус
    case "$status" in
        Charging) STATUS_RU="Заряжается" ;;
        Discharging) STATUS_RU="Разряжается" ;;
        Full) STATUS_RU="Полностью заряжена" ;;
        *) STATUS_RU="$status" ;;
    esac

    # Считаем время
    time_str=""
    if [ "$status" = "Discharging" ]; then
        if [ -n "$energy_now" ] && [ -n "$power_now" ] && [ "$power_now" -gt 0 ]; then
            mins=$(( energy_now * 60 / power_now ))
            time_str="До разряда:   ${mins} мин (~$((mins/60))ч $((mins%60))м)"
        elif [ -n "$charge_now" ] && [ -n "$current_now" ] && [ "$current_now" -gt 0 ]; then
            mins=$(( charge_now * 60 / current_now ))
            time_str="До разряда:   ${mins} мин (~$((mins/60))ч $((mins%60))м)"
        fi
    elif [ "$status" = "Charging" ]; then
        if [ -n "$energy_now" ] && [ -n "$energy_full" ] && [ -n "$power_now" ] && [ "$power_now" -gt 0 ]; then
            rem=$(( energy_full - energy_now ))
            mins=$(( rem * 60 / power_now ))
            time_str="До заряда:    ${mins} мин (~$((mins/60))ч $((mins%60))м)"
        fi
    fi

    # Считаем здоровье (износ)
    health_str=""
    if [ -n "$energy_full" ] && [ -n "$energy_design" ] && [ "$energy_design" -gt 0 ]; then
        health=$(( energy_full * 100 / energy_design ))
        health_str="Здоровье:     ${health}%"
    elif [ -n "$charge_full" ] && [ -n "$charge_full_design" ] && [ "$charge_full_design" -gt 0 ]; then
        health=$(( charge_full * 100 / charge_full_design ))
        health_str="Здоровье:     ${health}%"
    fi

    # Формируем красивый вывод
    OUT="Заряд:        ${capacity}%\n"
    OUT+="Статус:       ${STATUS_RU}\n"
    [ -n "$time_str" ] && OUT+="${time_str}\n"
    [ -n "$health_str" ] && OUT+="${health_str}\n"

    # Выводим в Rofi
    echo -e "$OUT" | rofi -dmenu -p "󰁹 Батарея" -theme-str 'window {width: 25%;} listview {lines: 4;}'
    exit 0
fi

# 2. ЕСЛИ АРГУМЕНТОВ НЕТ (ДЛЯ POLYBAR)
last=""
while true; do
    BAT=""
    for b in /sys/class/power_supply/BAT*; do
        [ -d "$b" ] && BAT="$b" && break
    done

    if [ -z "$BAT" ]; then
        out="N/A"
    else
        capacity=$(cat "$BAT/capacity" 2>/dev/null)
        status=$(cat "$BAT/status" 2>/dev/null)

        # Фолбэк для новых ноутов
        if [ -z "$capacity" ]; then
            energy_now=$(cat "$BAT/energy_now" 2>/dev/null)
            energy_full=$(cat "$BAT/energy_full" 2>/dev/null)
            charge_now=$(cat "$BAT/charge_now" 2>/dev/null)
            charge_full=$(cat "$BAT/charge_full" 2>/dev/null)
            
            if [ -n "$energy_now" ] && [ -n "$energy_full" ] && [ "$energy_full" -gt 0 ]; then
                capacity=$(( energy_now * 100 / energy_full ))
            elif [ -n "$charge_now" ] && [ -n "$charge_full" ] && [ "$charge_full" -gt 0 ]; then
                capacity=$(( charge_now * 100 / charge_full ))
            fi
        fi

        if [ -z "$capacity" ]; then
            out="N/A"
        else
            if [ "$status" = "Charging" ]; then
                icon="󰂄"
            elif [ "$status" = "Full" ]; then
                icon="󰁹"
            else
                if   [ "$capacity" -ge 90 ]; then icon="󰂂"
                elif [ "$capacity" -ge 80 ]; then icon="󰂁"
                elif [ "$capacity" -ge 70 ]; then icon="󰂀"
                elif [ "$capacity" -ge 60 ]; then icon="󰁿"
                elif [ "$capacity" -ge 50 ]; then icon="󰁾"
                elif [ "$capacity" -ge 40 ]; then icon="󰁽"
                elif [ "$capacity" -ge 30 ]; then icon="󰁼"
                elif [ "$capacity" -ge 20 ]; then icon="󰁻"
                elif [ "$capacity" -ge 10 ]; then icon="󰁺"
                else                              icon="󰂃"
                fi
            fi
            out="$icon $capacity%"
        fi
    fi

    if [ "$out" != "$last" ]; then
        echo "$out"
        last="$out"
    fi

    sleep 3
done