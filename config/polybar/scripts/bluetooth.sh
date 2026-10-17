#!/bin/bash

# Проверяем, есть ли вообще адаптер
if ! bluetoothctl show &>/dev/null; then
    echo "󰂲"
    exit 0
fi

# Получаем статус адаптера
POWERED=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')

if [ "$POWERED" = "yes" ]; then
    # Адаптер включён — проверяем подключённые устройства
    if bluetoothctl devices Connected 2>/dev/null | grep -q "Device"; then
        echo "󰂱"   # есть подключённое устройство
    else
        echo "󰂯"   # адаптер включён, но ничего не подключено
    fi
else
    echo "󰂲"       # адаптер выключен
fi