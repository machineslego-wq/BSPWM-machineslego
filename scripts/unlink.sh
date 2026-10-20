#!/bin/bash
# =========================================================
# unlink.sh — Безопасное удаление симлинков, созданных link.sh
# =========================================================

# Динамически определяем корень репозитория (так же, как в link.sh)
DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

if [ ! -d "$DOTFILES" ]; then
    echo "Error: repository not found (Ошибка: репозиторий не найден): $DOTFILES"
    exit 1
fi

echo "Removing symlinks pointing to (Удаляю симлинки, ведущие в) $DOTFILES"
echo ""

# 0. Удаляем сгенерированный файл профиля питания (если он есть)
# Делаем это до удаления симлинка на polybar, чтобы не оставлять мусор в репозитории
if [ -L "$DOTFILES/config/polybar/scripts/power-profile.sh" ] || [ -f "$DOTFILES/config/polybar/scripts/power-profile.sh" ]; then
    rm -f "$DOTFILES/config/polybar/scripts/power-profile.sh"
    echo "  removed (удален): generated power-profile.sh (сгенерированный power-profile.sh)"
fi

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
                echo "  unlink (удалена ссылка): $link_path"
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
echo "Symlinks removed (Удалено симлинков): $removed"
if [ "$skipped" -gt 0 ]; then
    echo "Skipped (Пропущено) (real files or links not in repo / реальные файлы или ссылки не в репо): $skipped"
fi

echo ""
echo "Done. (Готово.) If you want to restore your configs, they are in (Если хочешь вернуть свои конфиги, они лежат в) ~/.dotfiles-backup-*"