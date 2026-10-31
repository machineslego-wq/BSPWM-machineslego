#!/usr/bin/env bash
# ==========================================================
# notify-history.sh — история уведомлений Dunst в Rofi
# ==========================================================
# Использование:
#   notify-history.sh                 # читает из dunstctl history
#   notify-history.sh history.json    # читает из файла
#
# При выборе уведомления — копирует его тело в буфер обмена
# и показывает короткое подтверждение через Dunst.
# ==========================================================

set -euo pipefail

# ---------- 1. Получаем JSON ----------
if [[ $# -gt 0 && -f "$1" ]]; then
    json="$(cat "$1")"
else
    command -v dunstctl >/dev/null || {
        notify-send -u critical -a "Notifications" "Ошибка" "dunstctl не найден"
        exit 1
    }
    json="$(dunstctl history)"
fi

# Убираем возможный заголовок "dunstctl history"
json="$(printf '%s' "$json" | sed '1{/^[[:space:]]*dunstctl history[[:space:]]*$/d;}')"

command -v jq >/dev/null || {
    notify-send -u critical -a "Notifications" "Ошибка" "jq не найден. Установите: sudo apt install jq"
    exit 1
}

# ---------- 2. Парсим в TSV ----------
lines="$(
    printf '%s' "$json" | jq -r '
      def clean:
        tostring
        | gsub("<[^>]*>"; "")
        | gsub("\r"; " ")
        | gsub("\n"; " ")
        | gsub("\t"; " ")
        | gsub("  +"; " ")
        | sub("^ +"; "")
        | sub(" +$"; "");

      .data[0][]
      | [
          (.id.data // "" | tostring),
          ((.summary.data // "") | clean),
          ((.body.data // "")  | clean),
          ((.appname.data // "") | clean)
        ]
      | @tsv
    '
)"

if [[ -z "$lines" ]]; then
    notify-send -u low -a "Notifications" "История" "Уведомлений пока нет"
    exit 0
fi

# ---------- 3. Показываем в Rofi ----------
display="$(
    printf '%s\n' "$lines" | awk -F'\t' '{ printf "%s  %s — %s\n", $1, $2, $3 }'
)"

chosen="$(
    printf '%s\n' "$display" | rofi -dmenu -i -p "󰂚 Уведомления" -format i || true
)"

# Esc или отмена (Rofi может вернуть -1 вместо пустой строки)
[[ -z "${chosen:-}" || "${chosen}" == "-1" ]] && exit 0

# ---------- 4. Копируем тело в буфер ----------
selected="$(printf '%s\n' "$lines" | sed -n "$((chosen + 1))p")"
body="$(printf '%s' "$selected" | cut -f3)"
appname="$(printf '%s' "$selected" | cut -f4)"

if [[ -n "$body" ]]; then
    printf '%s' "$body" | xclip -selection clipboard
    notify-send -u low -t 2000 -a "Notifications" "$appname" "Текст скопирован в буфер"
else
    notify-send -u low -t 2000 -a "Notifications" "$appname" "Тело уведомления пустое"
fi