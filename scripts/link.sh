#!/bin/bash
# =========================================================
# link.sh — умная линковка config/ и home/ в систему
# =========================================================

# Динамически определяем корень репозитория, если переменная не задана извне
DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

if [ ! -d "$DOTFILES" ]; then
    echo "Ошибка: репозиторий не найден: $DOTFILES"
    exit 1
fi

mkdir -p "$BACKUP"
echo "Бэкап старых конфигов: $BACKUP"

link_item() {
    local src="$1"
    local dst="$2"

    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -e "$dst" ]; then
        mkdir -p "$(dirname "$BACKUP/$dst")"
        mv "$dst" "$BACKUP/$dst"
        echo "  backup: $dst"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "  link:   $dst -> $src"
}

# 1. Линкуем config/ -> ~/.config/
echo "--- Установка конфигов в ~/.config ---"
if [ -d "$DOTFILES/config" ]; then
    for pkg in "$DOTFILES/config"/*; do
        [ -d "$pkg" ] || continue
        pkg_name=$(basename "$pkg")
        link_item "$pkg" "$HOME/.config/$pkg_name"
    done
fi

# 2. Линкуем home/ -> ~/ (добавляя точку к именам файлов)
echo "--- Установка файлов в ~/ ---"
if [ -d "$DOTFILES/home" ]; then
    for file in "$DOTFILES/home"/*; do
        [ -e "$file" ] || continue
        file_name=$(basename "$file")
        link_item "$file" "$HOME/.$file_name"
    done
fi

# 3. Автовыбор скрипта питания
echo "--- Настройка профиля питания ---"
SCRIPTS_DIR="$HOME/.config/polybar/scripts"
if [ -d "$SCRIPTS_DIR" ]; then
    rm -f "$SCRIPTS_DIR/power-profile.sh"

    if command -v powerprofilesctl &>/dev/null; then
        ln -sf "$SCRIPTS_DIR/power-profile-ppd.sh" "$SCRIPTS_DIR/power-profile.sh"
        echo "  link: power-profile.sh -> power-profile-ppd.sh"
    elif ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
        ln -sf "$SCRIPTS_DIR/power-profile-tlp.sh" "$SCRIPTS_DIR/power-profile.sh"
        echo "  link: power-profile.sh -> power-profile-tlp.sh"
    else
        echo "  info: ПК обнаружен. Скрипт питания не создается."
    fi
fi

# 4. Права на скрипты
echo "--- Выставление прав (+x) ---"
chmod +x "$HOME/.config/polybar/scripts/"*.sh 2>/dev/null
chmod +x "$HOME/.config/sxhkd/scripts/"*.sh 2>/dev/null
chmod +x "$HOME/.config/polybar/launch.sh" 2>/dev/null
chmod +x "$HOME/.config/bspwm/bspwmrc" 2>/dev/null

echo "Готово."