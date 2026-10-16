#!/bin/bash
last=""
while true; do
    current=$(brightnessctl g 2>/dev/null)
    max=$(brightnessctl m 2>/dev/null)

    if [ -z "$current" ] || [ -z "$max" ] || [ "$max" -eq 0 ]; then
        out="N/A"
    else
        percent=$(( current * 100 / max ))

        if   [ "$percent" -le 49 ]; then level=1
        elif [ "$percent" -le 80 ]; then level=2
        else                              level=3
        fi

        case $level in
            1) icon="󰃞" ;;
            2) icon="󰃟" ;;
            3) icon="󰃠" ;;
        esac

        out="$icon $percent%"
    fi

    if [ "$out" != "$last" ]; then
        echo "$out"
        last="$out"
    fi

    sleep 0.2
done