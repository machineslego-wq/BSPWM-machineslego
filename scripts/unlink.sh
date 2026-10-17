#!/bin/sh
# =========================================================
# unlink.sh — удаляет симлинки, созданные link.sh
# Реальные папки и файлы не трогает.
# =========================================================

DOTFILES="${DOTFILES:-$HOME/bspwm-machineslego}"

if [ ! -d "$DOTFILES" ]; then
    echo "Ошибка: репозиторий не найден: $DOTFILES"
    echo "Укажи путь: DOTFILES=/путь/к/репо $0"
    exit 1
fi

echo "Удаляю симлинки, ведущие в $DOTFILES"
echo ""

removed=0
skipped=0

# Функция проверки и удаления
check_and_remove() {
    local link_path="$1"
    
    if [ -L "$link_path" ]; then
        # Проверяем, куда ведет симлинк
        local target=$(readlink "$link_path")
        
        # Если симлинк ведет в наш репозиторий — удаляем
        case "$target" in
            "$DOTFILES"*)
                rm "$link_path"
                echo "  unlink: $link_path"
                removed=$((removed + 1))
                ;;
            *)
                # Симлинк ведет куда-то еще, не трогаем
                skipped=$((skipped + 1))
                ;;
        esac
    elif [ -e "$link_path" ]; then
        # Это реальная папка или файл — не трогаем
        skipped=$((skipped + 1))
    fi
}

# 1. Чистим ~/.config/
if [ -d "$HOME/.config" ]; then
    for item in "$HOME/.config"/*; do
        [ -e "$item" ] || [ -L "$item" ] || continue
        check_and_remove "$item"
    done
fi

# 2. Чистим ~/ (только скрытые файлы, которые мы линковали)
# Мы знаем, что link.sh создает .xinitrc и .Xresources
# Проверим их точечно, чтобы не сканировать всю домашнюю папку
for file in ".xinitrc" ".Xresources"; do
    check_and_remove "$HOME/$file"
done

echo ""
echo "Удалено симлинков: $removed"
if [ "$skipped" -gt 0 ]; then
    echo "Пропущено (не симлинки или ведут не в репо): $skipped"
fi

echo ""
echo "Готово."