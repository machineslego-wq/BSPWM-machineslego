#!/bin/bash
# ==========================================================
# battery.sh — Модуль батареи для Polybar
# ==========================================================
# Работает в режиме `tail = true`: постоянно крутится в фоне,
# выводит только при изменении состояния.
#
# Использование:
#   battery.sh             — цикл для Polybar (обычный режим)
#   battery.sh --details   — показать подробности в Rofi (click-left)
# ==========================================================
#
# ==========================================================
# Настройки отображения
# ==========================================================
# ICON_STYLE — набор иконок батареи:
#   "horizontal" — Font Awesome (    ) — горизонтальные
#   "vertical"   — Material Design (󰂂 󰂁 󰂀 󰁿 󰁾 󰁽 󰁼 󰁻 󰁺 󰂃) — вертикальные
ICON_STYLE="horizontal"

# Функция: вернуть иконку батареи по уровню заряда
get_icon() {
    local cap="$1"

    # Если capacity не число (например, "?") — вернуть «пустую»
    if ! [[ "$cap" =~ ^[0-9]+$ ]]; then
        if [ "$ICON_STYLE" = "vertical" ]; then
            echo "󰂃"
        else
            echo ""
        fi
        return
    fi

    if [ "$ICON_STYLE" = "vertical" ]; then
        # Material Design: 10 уровней (шаг 10%)
        if   [ "$cap" -ge 90 ]; then echo "󰂂"
        elif [ "$cap" -ge 80 ]; then echo "󰂁"
        elif [ "$cap" -ge 70 ]; then echo "󰂀"
        elif [ "$cap" -ge 60 ]; then echo "󰁿"
        elif [ "$cap" -ge 50 ]; then echo "󰁾"
        elif [ "$cap" -ge 40 ]; then echo "󰁽"
        elif [ "$cap" -ge 30 ]; then echo "󰁼"
        elif [ "$cap" -ge 20 ]; then echo "󰁻"
        elif [ "$cap" -ge 10 ]; then echo "󰁺"
        else                         echo "󰂃"
        fi
    else
        # Font Awesome: 5 уровней (шаг 20%)
        if   [ "$cap" -ge 90 ]; then echo ""
        elif [ "$cap" -ge 70 ]; then echo ""
        elif [ "$cap" -ge 50 ]; then echo ""
        elif [ "$cap" -ge 30 ]; then echo ""
        else                         echo ""
        fi
    fi
}


BAT=""
for b in /sys/class/power_supply/BAT*; do
    [ -d "$b" ] && BAT="$b" && break
done

# ==========================================================
# Режим подробностей (Rofi)
# ==========================================================
show_details() {
    if [ -z "$BAT" ]; then
        echo "Питание: стационарный ПК (батареи нет)" | \
            rofi -dmenu -i -p "󰚥 Питание" -theme-str 'window {width: 30%;}'
        return 0
    fi

    local bat_name=$(basename "$BAT")
    local cap=$(cat "$BAT/capacity" 2>/dev/null || echo "?")
    local status=$(cat "$BAT/status" 2>/dev/null || echo "Unknown")

    local status_ru
    case "$status" in
        Charging)      status_ru="Заряжается" ;;
        Discharging)   status_ru="Разряжается" ;;
        Full)          status_ru="Полностью заряжена" ;;
        Not\ charging) status_ru="Не заряжается" ;;
        *)             status_ru="$status" ;;
    esac

    local lines=""
    lines+="$(get_icon "$cap") Батарея ${bat_name}"$'\n'
    lines+="Уровень: ${cap}%"$'\n'
    lines+="Статус: ${status_ru}"$'\n'

    local power_now=$(cat "$BAT/power_now" 2>/dev/null || echo 0)
    local energy_now=$(cat "$BAT/energy_now" 2>/dev/null || echo 0)
    local energy_full=$(cat "$BAT/energy_full" 2>/dev/null || echo 0)

    if [ "$power_now" -gt 0 ] 2>/dev/null; then
        local power_w=$(awk "BEGIN {printf \"%.1f\", $power_now / 1000000}")
        lines+="Потребление: ${power_w} Вт"$'\n'

        if [ "$status" = "Discharging" ] && [ "$energy_now" -gt 0 ] 2>/dev/null; then
            local hours=$(awk "BEGIN {printf \"%.1f\", $energy_now / $power_now}")
            lines+="Осталось: ~${hours} ч"$'\n'
        elif [ "$status" = "Charging" ] && [ "$energy_full" -gt 0 ] 2>/dev/null; then
            local left=$(awk "BEGIN {printf \"%.1f\", ($energy_full - $energy_now) / $power_now}")
            lines+="До полной: ~${left} ч"$'\n'
        fi
    fi

    # --- Здоровье батареи ---
    # Приоритет 1: готовый файл health (если ядро отдаёт)
    local health=$(cat "$BAT/health" 2>/dev/null)
    local health_ru=""

    if [ -n "$health" ]; then
        case "$health" in
            Good) health_ru="Хорошее" ;;
            Fair) health_ru="Удовлетворительное" ;;
            Poor) health_ru="Плохое" ;;
            *)    health_ru="$health" ;;
        esac
    else
        # Приоритет 2: вычислить из energy_full / energy_full_design
        local design_energy=$(cat "$BAT/energy_full_design" 2>/dev/null || echo 0)
        if [ "$design_energy" -gt 0 ] 2>/dev/null && [ "$energy_full" -gt 0 ] 2>/dev/null; then
            local health_pct=$(awk "BEGIN {printf \"%d\", $energy_full * 100 / $design_energy}")
            health_ru="${health_pct}%"
        else
            # Приоритет 3: вычислить из charge_full / charge_full_design
            local charge_full=$(cat "$BAT/charge_full" 2>/dev/null || echo 0)
            local design_charge=$(cat "$BAT/charge_full_design" 2>/dev/null || echo 0)
            if [ "$design_charge" -gt 0 ] 2>/dev/null && [ "$charge_full" -gt 0 ] 2>/dev/null; then
                local health_pct=$(awk "BEGIN {printf \"%d\", $charge_full * 100 / $design_charge}")
                health_ru="${health_pct}%"
            fi
        fi
    fi

    if [ -n "$health_ru" ]; then
        lines+="Здоровье: ${health_ru}"
    fi

    # Prompt в Rofi тоже использует get_icon — консистентно с панелью
    echo "$lines" | \
        rofi -dmenu -i -p "$(get_icon "$cap") Батарея" \
              -theme-str 'window {width: 30%;} listview {lines: 6;}'
}

if [ "$1" = "--details" ]; then
    show_details
    exit 0
fi

# ==========================================================
# Основной цикл для Polybar
# ==========================================================
last=""
warn60_sent=false
warn30_sent=false
warn_full_sent=false

while true; do
    if [ -z "$BAT" ]; then
        out="%{F#7dcfff} PC%{F-}"
    else
        capacity=$(cat "$BAT/capacity" 2>/dev/null)
        status=$(cat "$BAT/status" 2>/dev/null)

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
            out="%{F#7dcfff} PC%{F-}"
        else
            # Иконка по уровню + стилю (horizontal/vertical).
            # Состояние (зарядка/разрядка) передаётся цветом.
            # зелёный = зарядка, foreground = норма, жёлтый/красный = разряд.
            icon=$(get_icon "$capacity")

            if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
                color="#9ece6a"   # зелёный — зарядка/полный
            elif [ "$capacity" -le 30 ]; then
                color="#f7768e"   # красный — критично
            elif [ "$capacity" -le 60 ]; then
                color="#e0af68"   # жёлтый — предупреждение
            else
                color="#c0caf5"   # foreground — норма
            fi

            out="%{F$color}$icon $capacity%%{F-}"

             # --- Предупреждения (только один раз на переход) ---
            if [ "$status" = "Discharging" ]; then
                # Сбрасываем флаг полной зарядки, чтобы при следующем подключении к сети он сработал снова
                warn_full_sent=false

                if [ "$capacity" -le 30 ] && [ "$warn30_sent" = false ]; then
                    notify-send -u critical -t 0 \
                        -a "Battery" -i battery-caution \
                        "Батарея разряжена до ${capacity}%" \
                        "Пожалуйста, подключите зарядное устройство как можно скорее — заряда осталось совсем немного."
                    warn30_sent=true
                elif [ "$capacity" -le 60 ] && [ "$capacity" -gt 30 ] && [ "$warn60_sent" = false ]; then
                    notify-send -u normal -t 10000 \
                        -a "Battery" -i battery-low \
                        "Батарея разряжена до ${capacity}%" \
                        "Рекомендуется завершить текущие задачи или подключить зарядное устройство — до разряда осталось не так много."
                    warn60_sent=true
                fi
            fi

            if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
                [ "$capacity" -gt 60 ] && warn60_sent=false
                [ "$capacity" -gt 30 ] && warn30_sent=false

                # --- НОВОЕ: Предупреждение о полной зарядке ---
                if [ "$status" = "Full" ] || [ "$capacity" -ge 100 ]; then
                    if [ "$warn_full_sent" = false ]; then
                        notify-send -u normal -t 10000 \
                            -a "Battery" -i battery-full-charged \
                            "Батарея полностью заряжена" \
                            "Вы можете отключить зарядное устройство, чтобы сохранить ресурс аккумулятора."
                        warn_full_sent=true
                    fi
                fi
            fi

            if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
                [ "$capacity" -gt 60 ] && warn60_sent=false
                [ "$capacity" -gt 30 ] && warn30_sent=false
            fi
        fi
    fi

    if [ "$out" != "$last" ]; then
        echo "$out"
        last="$out"
    fi

    sleep 3
done