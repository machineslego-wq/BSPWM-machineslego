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

# 1. Установка БАЗОВЫХ пакетов (всегда, без условий)
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
echo "  Базовые пакеты установлены."
echo ""

# 2. Настройка питания (TLP / cpupower / PPD)
echo "[2/4] Настройка управления питанием..."

if command -v powerprofilesctl &>/dev/null; then
    echo "  -> Обнаружен power-profiles-daemon. Пропускаем установку TLP/cpupower."
    echo "  -> В Polybar будет использоваться профиль PPD (power-profile-ppd.sh)."
else
    echo "Выберите тип устройства для настройки питания:"
    echo "  1) Ноутбук (установит TLP)"
    echo "  2) ПК (установит cpupower)"
    read -p "Введите 1 или 2: " DEVICE_TYPE
    echo ""

    if [ "$DEVICE_TYPE" = "1" ]; then
        echo "  -> Устанавливаем TLP..."
        sudo apt install -y tlp tlp-rdw
        sudo systemctl enable --now tlp
        echo "$REAL_USER ALL=(ALL) NOPASSWD: /usr/sbin/tlp, /usr/bin/tlp-stat" | sudo tee /etc/sudoers.d/tlp > /dev/null
        sudo chmod 440 /etc/sudoers.d/tlp
    elif [ "$DEVICE_TYPE" = "2" ]; then
        echo "  -> Устанавливаем cpupower..."
        sudo apt install -y linux-cpupower
        echo "$REAL_USER ALL=(ALL) NOPASSWD: /usr/bin/cpupower" | sudo tee /etc/sudoers.d/cpupower > /dev/null
        sudo chmod 440 /etc/sudoers.d/cpupower
    else
        echo "  ! Неверный выбор. Пропускаем настройку питания."
    fi
fi
echo ""

# 3. Линковка пользовательских конфигов
echo "[3/4] Линковка конфигов..."
sudo -u "$REAL_USER" bash "$DOTFILES/scripts/link.sh"
echo ""

# 4. Установка системных конфигов
echo "[4/4] Установка системных конфигов в /etc/..."
if [ -d "$DOTFILES/system" ]; then
    sudo mkdir -p "$BACKUP"
    
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
    echo "  Бэкап старых системных файлов: $BACKUP"
fi

echo ""
echo "=== Установка завершена! ==="
echo "Перезагрузите систему или запустите startx."