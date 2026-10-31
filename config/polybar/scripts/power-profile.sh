#!/bin/bash
# ==========================================================
# power-profile.sh — Управление профилями питания
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
        performance) echo "%{F#ff9e64}PERF%{F-}" ;;
        balanced)    echo "%{F#7aa2f7}BAL%{F-}"  ;;
        power-saver) echo "%{F#9ece6a}ECO%{F-}"  ;;
        *)           echo "$PROFILE" ;;
    esac
}

# --- Режим меню (вызов: --menu) ---
if [ "$1" = "--menu" ]; then
    CHOICE=$(printf 'Performance\nBalanced\nPower Saver (No anim & shadows)' | \
        rofi -dmenu -p "Профиль питания" -theme-str 'window {width: 22%;} listview {lines: 3;}')

    case "$CHOICE" in
        *"Performance"*)
            powerprofilesctl set performance 2>/dev/null
            if [ $? -eq 0 ]; then
                restart_picom "$HOME/.config/picom/picom.conf"
                notify-send -u low -a "Power" "Режим Performance" \
                    "Максимальная производительность, анимации включены."
            else
                notify-send -u critical -a "Power" "Ошибка" \
                    "Профиль performance недоступен на этом железе"
            fi
            ;;
        *"Balanced"*)
            powerprofilesctl set balanced 2>/dev/null
            if [ $? -eq 0 ]; then
                restart_picom "$HOME/.config/picom/picom.conf"
                notify-send -u low -a "Power" "Режим Balanced" \
                    "Сбалансированный режим, анимации включены."
            else
                notify-send -u critical -a "Power" "Ошибка" \
                    "Профиль balanced недоступен"
            fi
            ;;
        *"Power Saver"*)
            powerprofilesctl set power-saver 2>/dev/null
            if [ $? -eq 0 ]; then
                # В ЭКО-режиме всегда отключаем анимации
                restart_picom "$HOME/.config/picom/picom-eco.conf"
                notify-send -u low -a "Power" "Режим Eco" \
                    "Энергосбережение, анимации и тени отключены."
            else
                notify-send -u critical -a "Power" "Ошибка" \
                    "Профиль power-saver недоступен"
            fi
            ;;
    esac
    exit 0
fi

# --- Обычный режим: только вывод статуса ---
get_status