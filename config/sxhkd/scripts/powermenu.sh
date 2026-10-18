#!/bin/bash
# Меню питания с подтверждением через Rofi

ACTION="$1"

case "$ACTION" in
    logout)
        CONFIRM=$(printf 'Да\nНет\n' | rofi -dmenu -no-custom -p "Выйти из аккаунта?")
        [ "$CONFIRM" = "Да" ] && loginctl terminate-user "$USER"
        ;;
    reboot)
        CONFIRM=$(printf 'Да\nНет\n' | rofi -dmenu -no-custom -p "Перезагрузить?")
        [ "$CONFIRM" = "Да" ] && systemctl reboot
        ;;
    poweroff)
        CONFIRM=$(printf 'Да\nНет\n' | rofi -dmenu -no-custom -p "Выключить?")
        [ "$CONFIRM" = "Да" ] && systemctl poweroff
        ;;
esac