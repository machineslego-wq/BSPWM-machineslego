#!/bin/bash
# =========================================================
# power-profile-ppd.sh — Управление профилями питания
# для power-profiles-daemon (PPD)
# =========================================================

# ---------------------------------------------------------
# --- Получение текущего статуса ---
# ---------------------------------------------------------
# powerprofilesctl get возвращает: performance, balanced, power-saver
# Функция переводит это в короткую строку с иконкой и аббревиатурой.
get_status() {
    PROFILE=$(powerprofilesctl get 2>/dev/null)
    case "$PROFILE" in
        performance) echo "󰓅 PERF" ;;
        balanced)    echo "󰒓 BAL"  ;;
        power-saver) echo "󰾆 ECO"  ;;
        *)           echo "󰒓 $PROFILE" ;;
    esac
}

# ---------------------------------------------------------
# --- Режим меню (вызов: --menu) ---
# ---------------------------------------------------------
# Если скрипт вызван с флагом --menu (например, по клику на модуль в Polybar),
# открываем Rofi с выбором профиля.
if [ "$1" = "--menu" ]; then
    CHOICE=$(printf '󰓅 Performance\n󰒓 Balanced\n󰾆 Power Saver\n' | rofi -dmenu -p "Профиль питания" -theme-str 'window {width: 22%;} listview {lines: 3;}')
    
    case "$CHOICE" in
        *"Performance"*) powerprofilesctl set performance ;;
        *"Balanced"*)    powerprofilesctl set balanced    ;;
        *"Power Saver"*) powerprofilesctl set power-saver ;;
    esac
    exit 0
fi

# ---------------------------------------------------------
# --- Обычный режим: только вывод статуса ---
# ---------------------------------------------------------
get_status