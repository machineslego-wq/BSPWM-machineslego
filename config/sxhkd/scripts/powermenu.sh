#!/bin/bash
# Меню питания с подтверждением через Rofi

ACTION="$1"

# Задаем ширину окна (например, 20% от экрана)
ROFI_WIDTH="-theme-str 'window {width: 10%;}'"

case "$ACTION" in
    logout)
        CONFIRM=$(printf '󰗡 Да\n󰅖 Нет\n' | rofi -dmenu -no-custom -p "󰍃 Выйти?" -theme-str 'window {width: 20%;}')
        [[ "$CONFIRM" == *"Да"* ]] && loginctl terminate-user "$USER"
        ;;
    reboot)
        CONFIRM=$(printf '󰗡 Да\n󰅖 Нет\n' | rofi -dmenu -no-custom -p "󰜉 Перезагрузка?" -theme-str 'window {width: 22%;}')
        [[ "$CONFIRM" == *"Да"* ]] && systemctl reboot
        ;;
    poweroff)
        CONFIRM=$(printf '󰗡 Да\n󰅖 Нет\n' | rofi -dmenu -no-custom -p "󰐥 Выключить?" -theme-str 'window {width: 22%;}')
        [[ "$CONFIRM" == *"Да"* ]] && systemctl poweroff
        ;;
esac