#!/bin/bash

# === АВТООПРЕДЕЛЕНИЕ WI-FI ИНТЕРФЕЙСА ===
WIFI_IFACE=$(LC_ALL=C nmcli device | awk '$2=="wifi" {print $1; exit}')

# Настройки точки доступа
HOTSPOT_NAME="MyHotspot"
HOTSPOT_PASS="12345678"

# 1. МЕНЮ ROFI
if [ "$1" = "--menu" ]; then
    if [ -z "$WIFI_IFACE" ]; then
        notify-send "Wi-Fi" "Wi-Fi адаптер не найден!"
        exit 1
    fi

    MENU="󰖩  Включить Wi-Fi\n󰖪  Выключить Wi-Fi\n󰑐  Сканировать сети\n󰀂  Добавить скрытую сеть\n󰤨  Включить точку доступа\n󰅖  Выключить точку доступа"
    
    CHOICE=$(echo -e "$MENU" | rofi -dmenu -i -p "Управление Wi-Fi" -theme-str 'window {width: 35%;} listview {lines: 6;}')

    case "$CHOICE" in
        *"Включить Wi-Fi"*)
            nmcli radio wifi on
            sleep 2
            ;;
        *"Выключить Wi-Fi"*)
            nmcli radio wifi off
            ;;
        *"Включить точку доступа"*)
            nmcli device disconnect "$WIFI_IFACE" 2>/dev/null
            nmcli device wifi hotspot ifname "$WIFI_IFACE" con-name "$HOTSPOT_NAME" ssid "$HOTSPOT_NAME" password "$HOTSPOT_PASS"
            if [ $? -eq 0 ]; then
                notify-send "Wi-Fi" "Точка доступа включена"
            else
                notify-send -u critical "Wi-Fi" "Ошибка при включении точки доступа"
            fi
            ;;
        *"Выключить точку доступа"*)
            nmcli connection down "$HOTSPOT_NAME" 2>/dev/null
            nmcli device disconnect "$WIFI_IFACE" 2>/dev/null
            notify-send "Wi-Fi" "Точка доступа выключена"
            ;;
        *"Добавить скрытую сеть"*)
            SSID=$(rofi -dmenu -p "Имя скрытой сети (SSID)" -theme-str 'window {width: 30%;}')
            if [ -n "$SSID" ]; then
                nmcli device disconnect "$WIFI_IFACE" 2>/dev/null
                while true; do
                    PASS=$(rofi -dmenu -p "Пароль для $SSID" -theme-str 'window {width: 30%;}')
                    [ -z "$PASS" ] && break
                    
                    # Удаляем старый профиль перед новой попыткой
                    nmcli connection delete "$SSID" 2>/dev/null
                    
                    nmcli device wifi connect "$SSID" password "$PASS" hidden yes ifname "$WIFI_IFACE" 2>/dev/null
                    sleep 2
                    
                    CURRENT_SSID=$(LC_ALL=C nmcli -t -f GENERAL.CONNECTION device show "$WIFI_IFACE" | cut -d: -f2)
                    if [ "$CURRENT_SSID" = "$SSID" ]; then
                        notify-send "Wi-Fi" "Подключено к $SSID"
                        break
                    else
                        notify-send -u critical "Wi-Fi" "Неверный пароль или ошибка"
                    fi
                done
            fi
            ;;
        *"Сканировать сети"*)
            notify-send "Wi-Fi" "Сканирование..."
            nmcli device wifi rescan ifname "$WIFI_IFACE" 2>/dev/null
            sleep 3
            
            # Убираем дубликаты и добавляем иконки
            NETWORKS=$(LC_ALL=C nmcli -t -f SSID,SIGNAL,SECURITY device wifi list ifname "$WIFI_IFACE" | awk -F: '
                !seen[$1]++ && $1 != "" {
                    if ($2 >= 80) icon="󰤨";
                    else if ($2 >= 60) icon="󰤥";
                    else if ($2 >= 40) icon="󰤢";
                    else if ($2 >= 20) icon="󰤟";
                    else icon="󰤯";
                    print icon " " $1 " | " $2 "% | " $3
                }'
            )
            
            if [ -z "$NETWORKS" ]; then
                notify-send -u critical "Wi-Fi" "Сети не найдены."
                exit 0
            fi

            NET_CHOICE=$(echo "$NETWORKS" | rofi -dmenu -i -p "Выберите сеть" -theme-str 'window {width: 50%;} listview {lines: 12;}')
            
            if [ -n "$NET_CHOICE" ]; then
                # Берем чистое имя сети
                SSID=$(echo "$NET_CHOICE" | cut -d'|' -f1 | cut -d' ' -f2- | xargs)
                
                # Отключаемся от текущей сети, чтобы не было конфликтов
                nmcli device disconnect "$WIFI_IFACE" 2>/dev/null
                
                CONNECTED=0
                
                # Сначала пробуем без пароля (вдруг сеть открытая или пароль сохранен)
                nmcli device wifi connect "$SSID" ifname "$WIFI_IFACE" 2>/dev/null
                sleep 2
                if [ "$(LC_ALL=C nmcli -t -f GENERAL.CONNECTION device show "$WIFI_IFACE" | cut -d: -f2)" = "$SSID" ]; then
                    notify-send "Wi-Fi" "Подключено к $SSID"
                    CONNECTED=1
                fi
                
                # Если не подключились, идем в цикл ввода пароля
                while [ $CONNECTED -eq 0 ]; do
                    # Убираем -password, чтобы видеть символы
                    PASS=$(rofi -dmenu -p "Пароль для $SSID" -password -theme-str 'window {width: 30%;}')
                    [ -z "$PASS" ] && break

                    # Удаляем старый (возможно битый) профиль, чтобы избежать ошибки "already exists"
                    nmcli connection delete "$SSID" 2>/dev/null
                    
                    # Пытаемся подключиться с новым паролем
                    nmcli device wifi connect "$SSID" password "$PASS" ifname "$WIFI_IFACE" 2>/dev/null
                    sleep 2
                    
                    # Проверяем РЕАЛЬНОЕ подключение
                    if [ "$(LC_ALL=C nmcli -t -f GENERAL.CONNECTION device show "$WIFI_IFACE" | cut -d: -f2)" = "$SSID" ]; then
                        notify-send "Wi-Fi" "Подключено к $SSID"
                        CONNECTED=1
                    else
                        notify-send -u critical "Wi-Fi" "Неверный пароль или ошибка подключения"
                    fi
                done
            fi
            ;;
    esac
    exit 0
fi

# 2. ВЫВОД ДЛЯ POLYBAR
if [ -z "$WIFI_IFACE" ]; then
    echo "󰤮 NOC"
    exit 0
fi

if [ "$(LC_ALL=C nmcli radio wifi)" = "disabled" ]; then
    echo "󰤮 OFF" 
    exit 0
fi

# Проверка хотспота
HOTSPOT_CONN=$(LC_ALL=C nmcli -t -f GENERAL.CONNECTION device show "$WIFI_IFACE" | cut -d: -f2)
if [ "$HOTSPOT_CONN" = "$HOTSPOT_NAME" ]; then
    echo "󰀂 $HOTSPOT_NAME"
    exit 0
fi

WIFI_DATA=$(LC_ALL=C nmcli -t -f IN-USE,SSID,SIGNAL device wifi list ifname "$WIFI_IFACE" | grep '^\*' | head -n 1)

if [ -n "$WIFI_DATA" ]; then
    SSID=$(echo "$WIFI_DATA" | cut -d: -f2)
    SIGNAL=$(echo "$WIFI_DATA" | cut -d: -f3)
    
    if ! [[ "$SIGNAL" =~ ^[0-9]+$ ]]; then SIGNAL=0; fi

    if   [ "$SIGNAL" -ge 80 ]; then ICON="󰤨"
    elif [ "$SIGNAL" -ge 60 ]; then ICON="󰤥"
    elif [ "$SIGNAL" -ge 40 ]; then ICON="󰤢"
    elif [ "$SIGNAL" -ge 20 ]; then ICON="󰤟"
    else                            ICON="󰤯"
    fi
    
    echo "$ICON $SSID"
else
    echo "󰤯 NOC"
fi