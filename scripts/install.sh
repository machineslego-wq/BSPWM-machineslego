#!/bin/bash
# =========================================================
# install.sh — полная установка dotfiles на новую машину
# =========================================================

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP="/etc/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

echo "=== Установка BSPWM-machineslego ==="
echo "Репозиторий: $DOTFILES"
echo ""

# 1. Линковка пользовательских конфигов
echo "[1/3] Линковка конфигов в ~/"
bash "$DOTFILES/scripts/link.sh"
echo ""

# 2. Установка системных конфигов (требует sudo)
echo "[2/3] Установка системных конфигов в /etc/"
if [ -d "$DOTFILES/system" ]; then
    # Проверяем, есть ли sudo
    if ! sudo -v; then
        echo "Ошибка: требуются права sudo для системных конфигов."
        exit 1
    fi

    sudo mkdir -p "$BACKUP"
    
    # Копируем файлы с сохранением структуры папок
    find "$DOTFILES/system" -type f | while read -r src_file; do
        # Получаем путь относительно папки system (например, X11/xorg.conf.d/30-touchpad.conf)
        rel_path="${src_file#$DOTFILES/system/}"
        dst_file="/$rel_path"
        dst_dir="$(dirname "$dst_file")"

        echo "  -> $dst_file"
        
        # Делаем бэкап, если файл уже есть
        if [ -f "$dst_file" ]; then
            sudo mkdir -p "$BACKUP/$dst_dir"
            sudo cp "$dst_file" "$BACKUP/$dst_file"
        fi

        # Создаем папку назначения и копируем
        sudo mkdir -p "$dst_dir"
        sudo cp "$src_file" "$dst_file"
    done
    echo "  Бэкап системных файлов: $BACKUP"
else
    echo "  Папка system/ пуста, пропускаем."
fi
echo ""

# 3. Проверка зависимостей (Wi-Fi и NetworkManager)
echo "[3/3] Проверка системных настроек"
if systemctl is-enabled wpa_supplicant &>/dev/null; then
    echo "  Внимание: wpa_supplicant включен."
    echo "  Для работы NetworkManager выполните:"
    echo "    sudo systemctl disable --now wpa_supplicant"
else
    echo "  wpa_supplicant отключен, NetworkManager готов к работе."
fi

echo ""
echo "=== Установка завершена! ==="
echo "Перезагрузите систему или перезайдите в сессию (startx)."