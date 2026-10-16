#!/bin/bash
# Скрипт яркости с использованием иконок nf-md-brightness_* из Nerd Font
# Всего 7 уровней яркости

last=""
while true; do
    current=$(brightnessctl g 2>/dev/null)
    max=$(brightnessctl m 2>/dev/null)

    if [ -z "$current" ] || [ -z "$max" ] || [ "$max" -eq 0 ]; then
        out="N/A"
    else
        # Вычисляем процент яркости (0-100)
        percent=$(( current * 100 / max ))

        # Определяем уровень от 1 до 3 на основе процента
        # 1: 1-49%  | 2: 50-80% | 3: 80-100% 
        if   [ "$percent" -le 49 ]; then level=1
        elif [ "$percent" -le 80 ]; then level=2
        else                              level=3
        fi

        # Выбираем иконку из набора nf-md-brightness_*
        case $level in
            1) icon="󰃞" ;;  # nf-md-brightness_5
            2) icon="󰃟" ;;  # nf-md-brightness_6
            3) icon="󰃠" ;;  # nf-md-brightness_7
        esac

        out="$icon $percent%"
    fi

    # Обновляем панель только при изменении значения
    if [ "$out" != "$last" ]; then
        echo "$out"
        last="$out"
    fi

    sleep 0.2
done