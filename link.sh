#!/bin/sh
# =========================================================
# link.sh — симлинкует конфиги из репозитория в ~/.config
# Работает в bash, zsh, fish, dash — везде, где есть sh
# =========================================================

# --- Настройки ---
DOTFILES="${DOTFILES:-$HOME/BSPWM-machineslego}"
TARGET="$HOME/.config"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Пакеты для линковки
PACKAGES="alacritty bspwm dunst fastfetch picom polybar rofi sxhkd"

# --- Проверки ---
if [ ! -d "$DOTFILES" ]; then
    echo "Ошибка: репозиторий не найден: $DOTFILES"
    echo "Укажи путь: DOTFILES=/путь/к/репо $0"
    exit 1
fi

if [ ! -d "$TARGET" ]; then
    echo "Создаю $TARGET"
    mkdir -p "$TARGET"
fi

mkdir -p "$BACKUP"
echo "Репозиторий: $DOTFILES"
echo "Цель:        $TARGET"
echo "Бэкап:       $BACKUP"
echo ""

# --- Основной цикл ---
for pkg in $PACKAGES; do
    src="$DOTFILES/$pkg"
    dst="$TARGET/$pkg"

    # Пропускаем отсутствующие пакеты
    if [ ! -d "$src" ]; then
        echo "  skip:  $pkg (нет в репозитории)"
        continue
    fi

    # Если пакет в Stow-формате (pkg/.config/pkg) — переключаемся на внутренний путь
    if [ -d "$src/.config/$pkg" ]; then
        src="$src/.config/$pkg"
    fi

    # Если dst существует
    if [ -L "$dst" ]; then
        # Уже симлинк — просто удаляем старый
        rm "$dst"
    elif [ -e "$dst" ]; then
        # Реальная папка/файл — переносим в бэкап
        mv "$dst" "$BACKUP/"
        echo "  backup: $dst"
    fi

    # Создаём симлинк
    ln -s "$src" "$dst"
    echo "  link:   $dst -> $src"
done

# --- Права на исполняемые скрипты ---
echo ""
echo "Выставляю права на исполняемые файлы..."
for f in \
    "$TARGET/polybar/launch.sh" \
    "$TARGET/bspwm/bspwmrc" \
    "$TARGET/polybar/scripts/"*.sh
do
    if [ -f "$f" ]; then
        chmod +x "$f"
        echo "  +x $f"
    fi
done

echo ""
echo "Готово."
echo "Бэкап старых конфигов: $BACKUP"