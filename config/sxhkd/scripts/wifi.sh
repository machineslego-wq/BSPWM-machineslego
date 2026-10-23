#!/bin/bash
# ==========================================================
# wifi.sh — Управление Wi-Fi через Rofi
# ==========================================================
# ИНСТРУКЦИЯ ДЛЯ ПОЛЬЗОВАТЕЛЯ:
# 1. Задайте имя и пароль для хотспота ниже.
# 2. Убедитесь, что имя вашего Wi-Fi адаптера (wlan0, wlo1) верное.
# 3. Убедитесь, что в ~/.config/rofi/config.rasi установлен 
#    шрифт "JetBrainsMono Nerd Font" (иначе иконки не будет видно).
# ==========================================================

# --- НАСТРОЙКИ ХОТСПОТА ---
HOTSPOT_SSID="BSPWM-Hotspot"
HOTSPOT_PASSWORD="i-use-debian-btw"

# --- ОПРЕДЕЛЕНИЕ ИНТЕРФЕЙСА ---
HOSTNAME=$(hostname)

if [ "$HOSTNAME" = "travelmate" ]; then
    WIFI_IFACE="wlp3s0"
elif [ "$HOSTNAME" = "lx15pro" ] || [ "$HOSTNAME" = "lx15pro-deb" ]; then
    WIFI_IFACE="wlo1"
elif [ "$HOSTNAME" = "lamer-deb" ]; then
    WIFI_IFACE="wlp7s0"
else
    WIFI_IFACE="wlan0"
fi

# --- ГЛАВНОЕ МЕНЮ ---
WIFI_STATE=$(nmcli radio wifi)

if [ "$WIFI_STATE" = "enabled" ]; then
    TOGGLE_TEXT="󰖪 Выключить Wi-Fi"
else
    TOGGLE_TEXT="󰖩 Включить Wi-Fi"
fi

CHOICE=$(printf "$TOGGLE_TEXT\n󰤨 Подключиться к сети\n󰀂 Включить хотспот\n󰅖 Выключить хотспот" | rofi -dmenu -p "󰖩 Wi-Fi" -theme-str 'window {width: 25%;}')

case "$CHOICE" in
    *"Включить Wi-Fi"*)
        nmcli radio wifi on
        notify-send -h string:x-canonical-private-synchronous:wifi \
                    -a "Wi-Fi" -i network-wireless \
                    "Адаптер включен"
        ;;
    *"Выключить Wi-Fi"*)
        nmcli radio wifi off
        notify-send -h string:x-canonical-private-synchronous:wifi \
                    -a "Wi-Fi" -i network-wireless-disconnected \
                    "Адаптер выключен"
        ;;
    *"Подключиться к сети"*)
        notify-send -h string:x-canonical-private-synchronous:wifi \
                    -a "Wi-Fi" -i network-wireless-acquiring \
                    "Подождите..." "Сканирование сетей..."
                    
        if [ "$WIFI_STATE" = "disabled" ]; then
            notify-send -h string:x-canonical-private-synchronous:wifi \
                        -a "Wi-Fi" -i dialog-warning \
                        "Wi-Fi выключен" "Сначала включите адаптер"
            exit 1
        fi
        
        # Собираем список с иконками: [замок] [иконка сигнала] [SSID]
        NETWORKS=$(nmcli -t -f SSID,SIGNAL,SECURITY device wifi list | awk -F: '
            !seen[$1]++ && $1 != "" {
                sig = $2 + 0;
                if (sig >= 75) w_icon = "󰤨";
                else if (sig >= 50) w_icon = "󰤥";
                else if (sig >= 25) w_icon = "󰤢";
                else if (sig > 0) w_icon = "󰤟";
                else w_icon = "󰤯";

                if ($3 == "" || $3 == "--") l_icon = "󰌿";
                else l_icon = "󰌾";

                print l_icon " " w_icon " " $1
            }')
        
        if [ -z "$NETWORKS" ]; then
            notify-send -h string:x-canonical-private-synchronous:wifi \
                        -a "Wi-Fi" -i dialog-error \
                        "Сети не найдены" "Проверьте адаптер"
            exit 1
        fi
        
        # Меню выбора
        NET_CHOICE=$(echo "$NETWORKS" | rofi -dmenu -p "Выбор сети" -theme-str 'window {width: 30%;}')
        
        if [ -n "$NET_CHOICE" ]; then
            # Отрезаем две иконки и два пробела, оставляя только SSID
            SSID=$(echo "$NET_CHOICE" | sed 's/^[^ ]* [^ ]* //')
            
            # Пытаемся подключиться тихо (если пароль уже сохранен)
            if nmcli device wifi connect "$SSID" > /dev/null 2>&1; then
                notify-send -h string:x-canonical-private-synchronous:wifi \
                            -a "Wi-Fi" -i network-wireless-connected \
                            "Подключено" "SSID: $SSID"
            else
                # Если не удалось — открываем терминал для ввода пароля
                alacritty --class wifi -e bash -c "echo 'Подключение к $SSID...'; nmcli device wifi connect '$SSID' --ask; echo -e '\nНажмите Enter для выхода...'; read" &
            fi
        fi
        ;;
    *"Включить хотспот"*)
        if nmcli device wifi hotspot ifname "$WIFI_IFACE" ssid "$HOTSPOT_SSID" password "$HOTSPOT_PASSWORD" > /dev/null 2>&1; then
            notify-send -u critical -t 0 \
                        -h string:x-canonical-private-synchronous:hotspot \
                        -a "Hotspot" -i network-wireless-hotspot \
                        "Хотспот включен" "SSID: $HOTSPOT_SSID\nПароль: <b>$HOTSPOT_PASSWORD</b>"
        else
            notify-send -u critical \
                        -h string:x-canonical-private-synchronous:hotspot \
                        -a "Hotspot" -i network-error \
                        "Ошибка хотспота" "Проверьте поддержку AP-режима"
        fi
        ;;
    *"Выключить хотспот"*)
        nmcli radio wifi off
        sleep 1
        nmcli radio wifi on
        sleep 1
        notify-send -h string:x-canonical-private-synchronous:hotspot \
                    -a "Hotspot" -i network-wireless-disconnected \
                    "Хотспот выключен" "Попытка восстановить подключение..."
        ;;
esac