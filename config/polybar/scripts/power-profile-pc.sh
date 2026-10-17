#!/bin/bash
# Управление режимом процессора через cpupower

get_status() {
    GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
    case "$GOV" in
        performance) echo "󰓅 PERF" ;;
        powersave)   echo "󰾆 SAVE" ;;
        schedutil)   echo "󰒓 BAL"  ;;
        *)           echo "󰒓 $GOV"  ;;
    esac
}

if [ "$1" = "--menu" ]; then
    CHOICE=$(printf '󰓅 Performance\n󰒓 Balanced (schedutil)\n󰾆 Powersave\n' | rofi -dmenu -p "Режим CPU" -theme-str 'window {width: 22%;} listview {lines: 3;}')
    case "$CHOICE" in
        *"Performance"*) sudo cpupower frequency-set -g performance ;;
        *"Balanced"*)    sudo cpupower frequency-set -g schedutil ;;
        *"Powersave"*)   sudo cpupower frequency-set -g powersave ;;
    esac
    exit 0
fi

get_status