#!/bin/bash
# =========================================================
# Яркость: иконка + полоса прогресса
# =========================================================
# STYLE — стиль отображения:
#   "icon"  — только иконка и процент (пример: 󰃞 45%)
#   "bar"   — только полоса и процент   (пример: ▓▓▒▒▒ 45%)
#   "both"  — иконка + полоса + процент (пример: 󰃞 ▓▓▒▒▒ 45%)
#   "icon-bar" — иконка + полоса, без процента
#   "bar-icon" — полоса + иконка + процент
# =========================================================

STYLE="both"

# --- Ширина полосы (в сегментах) ---
BAR_WIDTH=5

# --- Цвета полосы (Tokyo Night) ---
COLOR_BAR="%{F#7aa2f7}"     # заполненная часть — синий primary
COLOR_BG="%{F#565f89}"      # пустая часть — приглушённый
COLOR_RESET="%{F-}"

# --- Символы полосы ---
CHAR_FILL="▓"
CHAR_EMPTY="▒"

# =========================================================
# Логика
# =========================================================

last=""
while true; do
    current=$(brightnessctl g 2>/dev/null)
    max=$(brightnessctl m 2>/dev/null)

    if [ -z "$current" ] || [ -z "$max" ] || [ "$max" -eq 0 ]; then
        out="N/A"
    else
        percent=$(( current * 100 / max ))

        # --- Иконка по уровню яркости ---
        if   [ "$percent" -le 49 ]; then icon="󰃞"
        elif [ "$percent" -le 90 ]; then icon="󰃟"
        else                             icon="󰃠"
        fi

        # --- Полоса прогресса ---
        filled=$(( percent * BAR_WIDTH / 100 ))
        empty=$(( BAR_WIDTH - filled ))

        bar="${COLOR_BAR}"
        for ((i=0; i<filled; i++)); do bar="${bar}${CHAR_FILL}"; done
        bar="${bar}${COLOR_BG}"
        for ((i=0; i<empty; i++));  do bar="${bar}${CHAR_EMPTY}"; done
        bar="${bar}${COLOR_RESET}"

        # --- Сборка строки в зависимости от STYLE ---
        case "$STYLE" in
            "icon")     out="${icon} ${percent}%" ;;
            "bar")      out="${bar} ${percent}%" ;;
            "both")     out="${icon} ${bar} ${percent}%" ;;
            "icon-bar") out="${icon} ${bar}" ;;
            "bar-icon") out="${bar} ${icon} ${percent}%" ;;
            *)          out="${icon} ${percent}%" ;;  # fallback
        esac
    fi

    if [ "$out" != "$last" ]; then
        echo "$out"
        last="$out"
    fi

    sleep 0.1
done