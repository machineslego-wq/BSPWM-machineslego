#!/bin/bash
# ==========================================================
# wallpaper.sh — Выбор обоев через Rofi (мультимонитор)
# ==========================================================
# Ноутбук: 1 монитор, один выбор.
# ПК (lamer-deb): 2 монитора, отдельный выбор для каждого.
#
# State хранится по монитору:
#   ~/.config/bspwm-machineslego/wallpaper
# Формат:
#   DisplayPort-1=tokyo-night-girl-landscape.jpg
#   HDMI-A-3=tokyo-night-girl-portrait.jpg
#
# Fallback в --apply: если для монитора нет записи,
# применяются дефолтные обои по ориентации (rotated → portrait).
# ==========================================================

DOTFILES="${DOTFILES:-$HOME/BSPWM-machineslego}"
WALL_DIR="$DOTFILES/wallpapers"
STATE_DIR="$HOME/.config/bspwm-machineslego"
STATE_FILE="$STATE_DIR/wallpaper"

# --- ImageMagick: convert (thumbs) и identify (размеры) ---
# На Trixie imagemagick — IM6 (convert/identify), но IM7 (magick ...)
# тоже поддерживаем, если установлен.
IMG_CONVERT=""
IMG_IDENTIFY=""
if command -v magick >/dev/null 2>&1; then
    IMG_CONVERT="magick"
    IMG_IDENTIFY="magick identify"
elif command -v convert >/dev/null 2>&1; then
    IMG_CONVERT="convert"
    command -v identify >/dev/null 2>&1 && IMG_IDENTIFY="identify"
fi

# --- Размеры картинки (WxH), пусто если identify недоступен ---
img_dims() {
    local path="$1"
    [ -z "$IMG_IDENTIFY" ] && return
    $IMG_IDENTIFY -format "%wx%h" "$path" 2>/dev/null
}

# --- Список мониторов (bspwm знает точные имена) ---
get_monitors() {
    if command -v bspc >/dev/null 2>&1 && bspc query -M >/dev/null 2>&1; then
        bspc query -M --names
    else
        xrandr --listmonitors | awk 'NR>1 {print $NF}' | sed 's/.*\///'
    fi
}

# --- Применение файла на один монитор ---
apply_one() {
    local monitor="$1"
    local path="$2"
    [ -f "$path" ] && feh --output "$monitor" --bg-fill "$path" 2>/dev/null
}

# --- Чтение сохранённого выбора для монитора ---
get_saved() {
    local monitor="$1"
    [ -f "$STATE_FILE" ] && awk -F= -v m="$monitor" '$1==m {print $2}' "$STATE_FILE"
}

# --- Запись выбора (обновляет строку монитора, не трогая остальные) ---
save_wallpaper() {
    local monitor="$1"
    local name="$2"
    mkdir -p "$STATE_DIR"
    touch "$STATE_FILE"
    local tmp
    tmp=$(mktemp)
    awk -F= -v m="$monitor" '$1!=m' "$STATE_FILE" > "$tmp"
    printf '%s=%s\n' "$monitor" "$name" >> "$tmp"
    mv "$tmp" "$STATE_FILE"
}

# --- Ориентация монитора: normal|portrait ---
get_orientation() {
    local monitor="$1"
    if command -v xrandr >/dev/null 2>&1; then
        if xrandr --query 2>/dev/null | grep -qE "^$monitor.*(left|right)"; then
            echo "portrait"
            return
        fi
    fi
    echo "normal"
}

# --- Дефолтные обои по ориентации ---
default_for() {
    local monitor="$1"
    local orient
    orient=$(get_orientation "$monitor")
    if [ "$orient" = "portrait" ]; then
        echo "tokyo-night-girl-portrait.jpg"
    else
        echo "tokyo-night-girl-landscape.jpg"
    fi
}

# --- Rofi с превью и размерами ---
# $1 — имя монитора (для prompt)
# Возвращает ИНДЕКС выбранного элемента в WALLS (через -format 'i')
# или пусто/-1 при Esc.
show_rofi_picker() {
    local monitor="$1"
    local thumb_size=256
    local thumb_dir="$STATE_DIR/thumbs"
    mkdir -p "$thumb_dir"

    # 1. Генерируем thumbs заранее (вне пайпа)
    for wall in "${WALLS[@]}"; do
        local src="$WALL_DIR/$wall"
        if [ -n "$IMG_CONVERT" ]; then
            local thumb="$thumb_dir/${wall}.png"
            if [ ! -f "$thumb" ] || [ "$src" -nt "$thumb" ]; then
                "$IMG_CONVERT" "$src" \
                    -thumbnail "${thumb_size}x${thumb_size}^" \
                    -gravity center \
                    -extent "${thumb_size}x${thumb_size}" \
                    "$thumb" 2>/dev/null
            fi
        fi
    done

    # 2. Поток в rofi через printf (bash не хранит \0 в переменной)
    #    Формат label: "1920×1080  name.jpg"
    {
        for wall in "${WALLS[@]}"; do
            local src="$WALL_DIR/$wall"
            local icon="$src"
            local thumb="$thumb_dir/${wall}.png"
            [ -f "$thumb" ] && icon="$thumb"

            local dims
            dims=$(img_dims "$src")
            [ -z "$dims" ] && dims="?x?"
            dims="${dims/x/×}"

            printf '%s  %s\0icon\x1f%s\n' "$dims" "$wall" "$icon"
        done
    } | rofi -dmenu -i -show-icons -format 'i' -p "󰸉 $monitor" \
        -theme-str 'window {width: 50%;}
                    listview {columns: 2; lines: 2; fixed-height: false;}
                    element {orientation: vertical; padding: 10px; border-radius: 0px;}
                    element-icon {size: 9em; padding: 0 0 8px 0;}
                    element-text {horizontal-align: 0.5; vertical-align: 0.5;}'
}

# ==========================================================
# Режим --apply: применить сохранённое (вызывается из bspwmrc)
# ==========================================================
if [ "$1" = "--apply" ]; then
    mapfile -t MONITORS < <(get_monitors)
    for mon in "${MONITORS[@]}"; do
        saved=$(get_saved "$mon")
        if [ -n "$saved" ] && [ -f "$WALL_DIR/$saved" ]; then
            apply_one "$mon" "$WALL_DIR/$saved"
        else
            def=$(default_for "$mon")
            [ -f "$WALL_DIR/$def" ] && apply_one "$mon" "$WALL_DIR/$def"
        fi
    done
    exit 0
fi

# ==========================================================
# Интерактивный режим: выбор через Rofi для каждого монитора
# ==========================================================

mapfile -t WALLS < <(find "$WALL_DIR" -maxdepth 1 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
    -printf "%f\n" | sort)

if [ ${#WALLS[@]} -eq 0 ]; then
    notify-send -u critical -a "Wallpaper" "Ошибка" "В $WALL_DIR нет картинок"
    exit 1
fi

mapfile -t MONITORS < <(get_monitors)

if [ ${#MONITORS[@]} -eq 0 ]; then
    notify-send -u critical -a "Wallpaper" "Ошибка" "Мониторы не найдены"
    exit 1
fi

CHANGED=0

for mon in "${MONITORS[@]}"; do
    idx=$(show_rofi_picker "$mon")

    # Esc: rofi с -format 'i' возвращает -1 (или пусто в старых версиях)
    if [ -z "$idx" ] || [ "$idx" = "-1" ]; then
        if [ -z "$(get_saved "$mon")" ]; then
            def=$(default_for "$mon")
            [ -f "$WALL_DIR/$def" ] && apply_one "$mon" "$WALL_DIR/$def"
        fi
        continue
    fi

    CHOICE="${WALLS[$idx]}"
    [ -z "$CHOICE" ] && continue

    if apply_one "$mon" "$WALL_DIR/$CHOICE"; then
        save_wallpaper "$mon" "$CHOICE"
        CHANGED=$((CHANGED + 1))
    fi
done

if [ "$CHANGED" -gt 0 ]; then
    notify-send -u low -a "Wallpaper" "Обои применены" \
        "Обновлено мониторов: $CHANGED из ${#MONITORS[@]}"
fi