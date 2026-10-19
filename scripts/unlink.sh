#!/bin/sh
# =========================================================
# unlink.sh — Безопасное удаление симлинков, созданных link.sh
# =========================================================

DOTFILES="${DOTFILES:-$HOME/BSPWM-machineslego}"

if [ ! -d "$DOTFILES" ]; then
    echo "Ошибка: репозиторий не найден: $DOTFILES"
    exit 1
fi

echo "Удаляю симлинки, ведущие в $DOTFILES"
echo ""

removed=0
skipped=0

check_and_remove() {
    local link_path="$1"
    
    if [ -L "$link_path" ]; then
        local target
        target=$(readlink "$link_path")
        
        # Удаляем только если ссылка ведет в наш репозиторий
        case "$target" in
            "$DOTFILES"*)
                rm "$link_path"
                echo "  unlink: $link_path"
                removed=$((removed + 1))
                ;;
            *)
                skipped=$((skipped + 1))
                ;;
        esac
    elif [ -e "$link_path" ]; then
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

# 2. Чистим файлы в ~/ (автоматически берем список из папки home репозитория)
if [ -d "$DOTFILES/home" ]; then
    for file in "$DOTFILES/home"/*; do
        [ -e "$file" ] || continue
        file_name=$(basename "$file")
        check_and_remove "$HOME/.$file_name"
    done
fi

echo ""
echo "Удалено симлинков: $removed"
if [ "$skipped" -gt 0 ]; then
    echo "Пропущено (реальные файлы или ссылки не в репо): $skipped"
fi

echo ""
echo "Готово. Если хочешь вернуть свои конфиги, они лежат в ~/.dotfiles-backup-*"