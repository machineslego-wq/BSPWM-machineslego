#!/bin/bash
# ==========================================================
# power-profile-ppd.sh — Управление профилями питания
# ==========================================================

# --- Функция для перезапуска Picom ---
# $1 — путь к конфигу Picom
restart_picom() {
    local config="$1"
    pkill -x picom
    # Небольшая задержка, чтобы старый процесс завершился
    sleep 0.2
    picom --config "$config" &
}

# --- Получение текущего статуса ---
get_status() {
    PROFILE=$(powerprofilesctl get 2>/dev/null)
    case "$PROFILE" in
        performance) echo "󰓅 PERF" ;;
        balanced)    echo "󰒓 BAL"  ;;
        power-saver) echo "󰾆 ECO"  ;;
        *)           echo "󰒓 $PROFILE" ;;
    esac
}

# --- Режим меню (вызов: --menu) ---
if [ "$1" = "--menu" ]; then
    CHOICE=$(printf '󰓅 Performance\n󰒓 Balanced\n󰾆 Power Saver (No anin & shadows)' | \
        rofi -dmenu -p "Профиль питания" -theme-str 'window {width: 22%;} listview {lines: 3;}')
    
    case "$CHOICE" in
        *"Performance"*)
            powerprofilesctl set performance
            restart_picom "$HOME/.config/picom/picom.conf"
            notify-send -u low -a "Power" "Режим Performance" "Максимальная производительность, анимации включены."
            ;;
        *"Balanced"*)
            powerprofilesctl set balanced
            restart_picom "$HOME/.config/picom/picom.conf"
            notify-send -u low -a "Power" "Режим Balanced" "Сбалансированный режим, анимации включены."
            ;;
        *"Power Saver"*)
            powerprofilesctl set power-saver
            # В ЭКО-режиме всегда отключаем анимации
            restart_picom "$HOME/.config/picom/picom-eco.conf"
            notify-send -u low -a "Power" "Режим Eco" "Энергосбережение, анимации и тени отключены."
            ;;
    esac
    exit 0
fi

# --- Обычный режим: только вывод статуса ---
get_status