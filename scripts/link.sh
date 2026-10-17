#!/bin/sh
# =========================================================
# link.sh — симлинкует config/ и home/ в систему
# =========================================================

DOTFILES="${DOTFILES:-$HOME/bspwm-machineslego}"
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

# 3. Права на скрипты
echo "--- Выставление прав (+x) ---"
chmod +x "$HOME/.config/polybar/launch.sh" 2>/dev/null
chmod +x "$HOME/.config/polybar/scripts/"*.sh 2>/dev/null
chmod +x "$HOME/.config/bspwm/bspwmrc" 2>/dev/null

echo "Готово."