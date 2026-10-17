#!/bin/sh
# =========================================================
# link.sh — умная линковка config/ и home/ в систему
# =========================================================

DOTFILES="${DOTFILES:-$HOME/BSPWM-machineslego}"
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

    # Если симлинк уже есть — удаляем
    if [ -L "$dst" ]; then
        rm "$dst"
    # Если есть реальная папка/файл — бэкапим
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
        # Наш xinitrc превратится в .xinitrc
        link_item "$file" "$HOME/.$file_name"
    done
fi

# 3. Автовыбор скрипта питания (TLP для ноутбуков, cpupower для ПК)
echo "--- Настройка профиля питания ---"
SCRIPTS_DIR="$HOME/.config/polybar/scripts"
if [ -d "$SCRIPTS_DIR" ]; then
    if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
        # Нашли батарею — значит это ноутбук
        ln -sf "$SCRIPTS_DIR/power-profile-laptop.sh" "$SCRIPTS_DIR/power-profile.sh"
        echo "  link: power-profile.sh -> power-profile-laptop.sh (Обнаружен ноутбук)"
    else
        # Батареи нет — значит это ПК
        ln -sf "$SCRIPTS_DIR/power-profile-pc.sh" "$SCRIPTS_DIR/power-profile.sh"
        echo "  link: power-profile.sh -> power-profile-pc.sh (Обнаружен ПК)"
    fi
fi

# 4. Права на скрипты (чтобы Polybar мог их запускать)
echo "--- Выставление прав (+x) ---"
chmod +x "$SCRIPTS_DIR/"*.sh 2>/dev/null
chmod +x "$HOME/.config/polybar/launch.sh" 2>/dev/null
chmod +x "$HOME/.config/bspwm/bspwmrc" 2>/dev/null

echo "Симлинки успешно созданы."