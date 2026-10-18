#!/bin/bash

last=""
while true; do
    BAT=""
    for b in /sys/class/power_supply/BAT*; do
        [ -d "$b" ] && BAT="$b" && break
    done

    if [ -z "$BAT" ]; then
        # Если батареи нет — выводим иконку розетки (голубой цвет info)
        out="%{F#7dcfff}󰚥 PC%{F-}"
    else
        capacity=$(cat "$BAT/capacity" 2>/dev/null)
        status=$(cat "$BAT/status" 2>/dev/null)

        # Фолбэк для новых ноутов (если нет файла capacity)
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
            # Если батарея есть, но данные не читаются — тоже показываем розетку
            out="%{F#7dcfff}󰚥 PC%{F-}"
        else
            # 1. Выбираем иконку
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

            # 2. Выбираем цвет (Tokyo Night)
            if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
                color="#9ece6a"   # Зеленый (success) при зарядке
            elif [ "$capacity" -le 40 ]; then
                color="#f7768e"   # Красный (alert) при критическом заряде
            elif [ "$capacity" -le 60 ]; then
                color="#e0af68"   # Желтый (warning) при низком заряде
            else
                color="#7aa2f7"   # Синий (primary) в обычном режиме
            fi

            # 3. Оборачиваем в теги Polybar
            out="%{F$color}$icon $capacity%%{F-}"
        fi
    fi

    if [ "$out" != "$last" ]; then
        echo "$out"
        last="$out"
    fi

    sleep 3
done