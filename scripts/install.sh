#!/bin/bash
# ==========================================================
# install.sh — полная установка BSPWM-machineslego
# ==========================================================

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP="/etc/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

echo "=== Установка BSPWM-machineslego ==="
echo "Репозиторий: $DOTFILES"
echo ""

# 0. Проверка прав sudo (запрашиваем пароль один раз в начале)
if ! sudo -v; then
    echo "Ошибка: требуются права sudo для установки пакетов и системных конфигов."
    exit 1
fi

# 1. Установка пакетов
echo "[1/4] Установка базовых пакетов..."
sudo apt update
sudo apt install -y \
  xorg xinit \
  bspwm sxhkd \
  polybar rofi dunst picom feh \
  lxappearance \
  papirus-icon-theme \
  fonts-jetbrains-mono fonts-font-awesome \
  fonts-noto-color-emoji \
  brightnessctl scrot \
  network-manager-gnome pavucontrol \
  blueman \
  thunar alacritty \
  i3lock-fancy libnotify-bin \
  fish \
  qt6ct

echo "  Пакеты установлены."
echo ""

# 2. Линковка пользовательских конфигов
echo "[2/4] Линковка конфигов в ~/ и ~/.config/"
bash "$DOTFILES/scripts/link.sh"
echo ""

# 3. Установка системных конфигов (требует sudo)
echo "[3/4] Установка системных конфигов в /etc/"
if [ -d "$DOTFILES/system" ]; then
    sudo mkdir -p "$BACKUP"
    
    # Копируем файлы с сохранением структуры папок
    find "$DOTFILES/system" -type f | while read -r src_file; do
        rel_path="${src_file#$DOTFILES/system/}"
        dst_file="/$rel_path"
        dst_dir="$(dirname "$dst_file")"

        echo "  -> $dst_file"
        
        if [ -f "$dst_file" ]; then
            sudo mkdir -p "$BACKUP/$dst_dir"
            sudo cp "$dst_file" "$BACKUP/$dst_file"
        fi

        sudo mkdir -p "$dst_dir"
        sudo cp "$src_file" "$dst_file"
    done
    echo "  Бэкап системных файлов: $BACKUP"
else
    echo "  Папка system/ пуста, пропускаем."
fi
echo ""

# 4. Проверка NetworkManager и wpa_supplicant
echo "[4/4] Проверка системных настроек"
if systemctl is-enabled wpa_supplicant &>/dev/null; then
    echo "  Внимание: системный wpa_supplicant включен."
    echo "  Для работы NetworkManager выполните:"
    echo "    sudo systemctl disable --now wpa_supplicant"
else
    echo "  wpa_supplicant отключен, NetworkManager готов к работе."
fi

echo ""
echo "=== Установка завершена! ==="
echo "Перезагрузите систему или перезайдите в сессию (startx)."