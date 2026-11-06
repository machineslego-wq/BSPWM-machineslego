#!/bin/bash
# =========================================================
# link.sh — умная линковка config/ и home/ в систему
# =========================================================

# Динамически определяем корень репозитория, если переменная не задана извне
DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

if [ ! -d "$DOTFILES" ]; then
    echo "Error: repository not found (Ошибка: репозиторий не найден): $DOTFILES"
    exit 1
fi

mkdir -p "$BACKUP"
echo "Backup of old configs (Бэкап старых конфигов): $BACKUP"

link_item() {
    local src="$1"
    local dst="$2"

    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -e "$dst" ]; then
        mkdir -p "$(dirname "$BACKUP/$dst")"
        mv "$dst" "$BACKUP/$dst"
        echo "  backup (бэкап): $dst"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "  link (ссылка):   $dst -> $src"
}

# 1. Линкуем config/ -> ~/.config/
echo "--- Installing configs to ~/.config (Установка конфигов в ~/.config) ---"
if [ -d "$DOTFILES/config" ]; then
    for pkg in "$DOTFILES/config"/*; do
        [ -d "$pkg" ] || continue
        pkg_name=$(basename "$pkg")
        # Исключаем qt6ct из линковки — он управляется системой
        # Исключаем mc из линковки — он управляется черезskin
        if [ "$pkg_name" = "qt6ct" ] || [ "$pkg_name" = "mc" ]; then
            echo "  skip $pkg_name (system-managed)"
            continue
        fi
        link_item "$pkg" "$HOME/.config/$pkg_name"
    done
fi

# 2. Линкуем home/ -> ~/ (добавляя точку к именам файлов)
echo "--- Installing files to ~/ (Установка файлов в ~/) ---"
if [ -d "$DOTFILES/home" ]; then
    for file in "$DOTFILES/home"/*; do
        [ -e "$file" ] || continue
        file_name=$(basename "$file")
        link_item "$file" "$HOME/.$file_name"
    done
fi

# 3. Линкуем local/share/mc/skins/ -> ~/.local/share/mc/skins/
echo "--- Installing mc skins to ~/.local/share/mc/skins/ (Установка скинов MC) ---"
if [ -d "$DOTFILES/local/share/mc/skins" ]; then
    for skin in "$DOTFILES/local/share/mc/skins"/*.ini; do
        [ -e "$skin" ] || continue
        skin_name=$(basename "$skin")
        link_item "$skin" "$HOME/.local/share/mc/skins/$skin_name"
    done
fi

# 4. Права на скрипты
echo "--- Setting permissions (+x) (Выставление прав (+x)) ---"
chmod +x "$HOME/.config/polybar/scripts/"*.sh 2>/dev/null
chmod +x "$HOME/.config/sxhkd/scripts/"*.sh 2>/dev/null
chmod +x "$HOME/.config/polybar/launch.sh" 2>/dev/null
chmod +x "$HOME/.config/bspwm/bspwmrc" 2>/dev/null

echo "Done. (Готово.)"