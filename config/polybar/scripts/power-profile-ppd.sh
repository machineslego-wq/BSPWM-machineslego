#!/bin/bash
# Управление профилями power-profiles-daemon

get_status() {
    # powerprofilesctl get возвращает: performance, balanced, power-saver
    PROFILE=$(powerprofilesctl get 2>/dev/null)
    case "$PROFILE" in
        performance) echo "󰓅 PERF" ;;
        balanced)    echo "󰒓 BAL"  ;;
        power-saver) echo "󰾆 SAVE" ;;
        *)           echo "󰒓 $PROFILE" ;;
    esac
}

if [ "$1" = "--menu" ]; then
    CHOICE=$(printf '󰓅 Performance\n󰒓 Balanced\n󰾆 Power Saver\n' | rofi -dmenu -p "Профиль питания" -theme-str 'window {width: 22%;} listview {lines: 3;}')
    
    case "$CHOICE" in
        *"Performance"*) powerprofilesctl set performance ;;
        *"Balanced"*)    powerprofilesctl set balanced    ;;
        *"Power Saver"*) powerprofilesctl set power-saver ;;
    esac
    exit 0
fi

get_status