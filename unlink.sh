#!/bin/sh
# =========================================================
# unlink.sh — удаляет симлинки конфигов из ~/.config
# Репозиторий остаётся нетронутым
# =========================================================

TARGET="$HOME/.config"
BACKUP_DIR="$HOME/.dotfiles-backup-*"
PACKAGES="alacritty bspwm dunst fastfetch picom polybar rofi sxhkd"

if [ ! -d "$TARGET" ]; then
    echo "Целевой каталог не найден: $TARGET"
    exit 1
fi

echo "Удаляю симлинки из $TARGET"
echo ""

removed=0
skipped=0

for pkg in $PACKAGES; do
    dst="$TARGET/$pkg"

    if [ -L "$dst" ]; then
        # Это симлинк — удаляем безопасно
        rm "$dst"
        echo "  unlink: $dst"
        removed=$((removed + 1))
    elif [ -e "$dst" ]; then
        # Реальная папка/файл — не трогаем
        echo "  skip:   $dst (это не симлинк, оставляю)"
        skipped=$((skipped + 1))
    else
        # Уже нет — молча пропускаем
        :
    fi
done

echo ""
echo "Удалено симлинков: $removed"
if [ "$skipped" -gt 0 ]; then
    echo "Пропущено (не симлинки): $skipped"
fi

# Подсказка про бэкапы
if ls $BACKUP_DIR >/dev/null 2>&1; then
    echo ""
    echo "Найдены бэкапы:"
    ls -d $BACKUP_DIR
    echo "Вернуть конфиги можно командой: mv <бэкап>/<пакет> $TARGET/"
fi

echo ""
echo "Готово."