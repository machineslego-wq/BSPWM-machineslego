#!/bin/bash
# Управление профилями TLP 1.8.0

get_status() {
    local raw
    # Используем правильный путь к tlp-stat (/usr/bin/)
    raw=$(sudo -n /usr/bin/tlp-stat -m 2>/dev/null || /usr/bin/tlp-stat -m 2>/dev/null)

    if [[ "$raw" == *"AC"* ]]; then
        if [[ "$raw" == *"manual"* ]]; then
            echo "󰓅 AC(M)"
        else
            echo "󰓅 AC(A)"
        fi
    elif [[ "$raw" == *"battery"* ]]; then
        if [[ "$raw" == *"manual"* ]]; then
            echo "󰾆 BAT(M)"
        else
            echo "󰾆 BAT(A)"
        fi
    else
        # Резервный вариант: если статус не получен, смотрим на кабель питания
        if cat /sys/class/power_supply/*/online 2>/dev/null | grep -q "1"; then
            echo "󰓅 AC"
        else
            echo "󰾆 BAT"
        fi
    fi
}

if [ "$1" = "--menu" ]; then
    CHOICE=$(printf '󰒓 Auto (Автоматически)\n󰓅 AC (Только от сети)\n󰾆 BAT (Только от батареи)\n' | rofi -dmenu -p "Профиль TLP" -theme-str 'window {width: 28%;} listview {lines: 3;}')
    
    case "$CHOICE" in
        *"Auto"*) sudo -n /usr/sbin/tlp start ;;
        *"AC"*)   sudo -n /usr/sbin/tlp ac  ;;
        *"BAT"*)  sudo -n /usr/sbin/tlp bat ;;
    esac
    exit 0
fi

get_status