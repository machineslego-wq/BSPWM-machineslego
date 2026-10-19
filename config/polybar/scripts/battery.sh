#!/bin/bash
# ==========================================================
# battery.sh — Модуль батареи для Polybar
# ==========================================================
# Скрипт работает в режиме `tail = true`.
# Он постоянно крутится в фоне, проверяет состояние батареи
# и выводит строку ТОЛЬКО если состояние изменилось.
# Это снижает нагрузку на Polybar и процессор.
# ==========================================================

# Переменная для хранения последнего выведенного состояния.
# Нужна, чтобы не спамить Polybar одинаковыми строками каждые 3 секунды.
last=""

while true; do
    # ------------------------------------------------------
    # 1. Поиск батареи
    # ------------------------------------------------------
    BAT=""
    # Ищем первую попавшуюся батарею (BAT0, BAT1 и т.д.)
    for b in /sys/class/power_supply/BAT*; do
        [ -d "$b" ] && BAT="$b" && break
    done

    if [ -z "$BAT" ]; then
        # Батареи нет (стационарный ПК) — выводим иконку розетки
        # Цвет info (голубой) из палитры Tokyo Night
        out="%{F#7dcfff}󰚥 PC%{F-}"
    else
        # --------------------------------------------------
        # 2. Чтение данных
        # --------------------------------------------------
        capacity=$(cat "$BAT/capacity" 2>/dev/null)
        status=$(cat "$BAT/status" 2>/dev/null)

        # Фолбэк для новых ноутбуков (если нет файла capacity)
        if [ -z "$capacity" ]; then
            energy_now=$(cat "$BAT/energy_now" 2>/dev/null)
            energy_full=$(cat "$BAT/energy_full" 2>/dev/null)
            charge_now=$(cat "$BAT/charge_now" 2>/dev/null)
            charge_full=$(cat "$BAT/charge_full" 2>/dev/null)
            
            if [ -n "$energy_now" ] && [ -n "$energy_full" ] && [ "$energy_full" -gt 0 ]; then
                capacity=$(( energy_now * 100 / energy_full ))
            elif [ -n "$charge_now" ] && [ -n "$charge_full" ] && [ "$charge_full" -gt 0 ]; then
                capacity=$(( charge_now * 100 / charge_full ))
            fi
        fi

        if [ -z "$capacity" ]; then
            # Батарея есть, но данные не читаются — показываем розетку
            out="%{F#7dcfff}󰚥 PC%{F-}"
        else
            # --------------------------------------------------
            # 3. Выбор иконки (Nerd Font / Material Design)
            # --------------------------------------------------
            if [ "$status" = "Charging" ]; then
                icon="󰂄"
            elif [ "$status" = "Full" ]; then
                icon="󰁹"
            else
                # Градация иконок при разряде (от 100% до 0%)
                if   [ "$capacity" -ge 90 ]; then icon="󰂂"
                elif [ "$capacity" -ge 80 ]; then icon="󰂁"
                elif [ "$capacity" -ge 70 ]; then icon="󰂀"
                elif [ "$capacity" -ge 60 ]; then icon="󰁿"
                elif [ "$capacity" -ge 50 ]; then icon="󰁾"
                elif [ "$capacity" -ge 40 ]; then icon="󰁽"
                elif [ "$capacity" -ge 30 ]; then icon="󰁼"
                elif [ "$capacity" -ge 20 ]; then icon="󰁻"
                elif [ "$capacity" -ge 10 ]; then icon="󰁺"
                else                              icon="󰂃"
                fi
            fi

            # --------------------------------------------------
            # 4. Выбор цвета (Tokyo Night)
            # --------------------------------------------------
            if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
                color="#9ece6a"   # Зеленый (success) при зарядке
            elif [ "$capacity" -le 40 ]; then
                color="#f7768e"   # Красный (alert) при критическом заряде
            elif [ "$capacity" -le 60 ]; then
                color="#e0af68"   # Желтый (warning) при низком заряде
            else
                color="#7aa2f7"   # Синий (primary) в обычном режиме
            fi

            # --------------------------------------------------
            # 5. Формирование вывода для Polybar
            # --------------------------------------------------
            # Оборачиваем иконку и процент в теги цвета Polybar
            out="%{F$color}$icon $capacity%%{F-}"
        fi
    fi

    # ------------------------------------------------------
    # 6. Отправка данных в Polybar
    # ------------------------------------------------------
    # Выводим только если состояние изменилось
    if [ "$out" != "$last" ]; then
        echo "$out"
        last="$out"
    fi

    # Пауза перед следующей проверкой (3 секунды)
    sleep 3
done