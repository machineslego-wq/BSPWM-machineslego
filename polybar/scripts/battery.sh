#!/bin/bash
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

        if [ -z "$capacity" ]; then
            out="N/A"
        else
            # Иконки Nerd Font (Material Design Icons)
            # Горизонтальные батарейки в зависимости от уровня
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