#!/bin/bash
# ==========================================================
# install.sh — Автоматическая установка BSPWM-machineslego
# ==========================================================

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP="/etc/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Определяем реального пользователя (если скрипт запущен через sudo)
if [ -n "$SUDO_USER" ]; then
    REAL_USER=$SUDO_USER
else
    REAL_USER=$USER
fi

echo "=== Установка BSPWM-machineslego ==="
echo "Репозиторий: $DOTFILES"
echo "Пользователь: $REAL_USER"
echo ""

# Запрашиваем пароль sudo один раз в начале
sudo -v || { echo "Ошибка: требуются права sudo."; exit 1; }

# 1. Выбор типа устройства
echo "Выберите тип устройства:"
echo "  1) Ноутбук (установит TLP)"
echo "  2) ПК (установит cpupower)"
read -p "Введите 1 или 2: " DEVICE_TYPE

if [ "$DEVICE_TYPE" != "1" ] && [ "$DEVICE_TYPE" != "2" ]; then
    echo "Неверный выбор. Выход."
    exit 1
fi
echo ""

# 2. Установка пакетов
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
  fish

# 3. Установка пакетов питания и настройка sudoers
echo "[2/4] Настройка управления питанием..."
if [ "$DEVICE_TYPE" = "1" ]; then
    echo "  -> Выбран ноутбук. Устанавливаем TLP..."
    sudo apt install -y tlp tlp-rdw
    sudo systemctl enable --now tlp
    
    # Настраиваем sudoers для TLP (без пароля)
    echo "$REAL_USER ALL=(ALL) NOPASSWD: /usr/sbin/tlp, /usr/bin/tlp-stat" | sudo tee /etc/sudoers.d/tlp > /dev/null
    sudo chmod 440 /etc/sudoers.d/tlp
    echo "  -> Добавлено правило в /etc/sudoers.d/tlp"
else
    echo "  -> Выбран ПК. Устанавливаем cpupower..."
    sudo apt install -y linux-cpupower
    
    # Настраиваем sudoers для cpupower (без пароля)
    echo "$REAL_USER ALL=(ALL) NOPASSWD: /usr/bin/cpupower" | sudo tee /etc/sudoers.d/cpupower > /dev/null
    sudo chmod 440 /etc/sudoers.d/cpupower
    echo "  -> Добавлено правило в /etc/sudoers.d/cpupower"
fi
echo ""

# 4. Линковка пользовательских конфигов
echo "[3/4] Линковка конфигов..."
# Запускаем линковщик от имени реального пользователя, чтобы права на файлы не стали root'овскими
sudo -u "$REAL_USER" bash "$DOTFILES/scripts/link.sh"
echo ""

# 5. Установка системных конфигов
echo "[4/4] Установка системных конфигов в /etc/..."
if [ -d "$DOTFILES/system" ]; then
    sudo mkdir -p "$BACKUP"
    
    find "$DOTFILES/system" -type f | while read -r src_file; do
        rel_path="${src_file#$DOTFILES/system/}"
        dst_file="/$rel_path"
        dst_dir="$(dirname "$dst_file")"

        echo "  -> $dst_file"
        
        # Делаем бэкап старого файла
        if [ -f "$dst_file" ]; then
            sudo mkdir -p "$BACKUP/$dst_dir"
            sudo cp "$dst_file" "$BACKUP/$dst_file"
        fi

        # Копируем новый
        sudo mkdir -p "$dst_dir"
        sudo cp "$src_file" "$dst_file"
    done
    echo "  Бэкап старых системных файлов: $BACKUP"
fi

echo ""
echo "=== Установка завершена! ==="
echo "Для запуска графической сессии введите: startx"
echo "Не забудьте отключить wpa_supplicant, если Wi-Fi не работает:"
echo "  sudo systemctl disable --now wpa_supplicant"