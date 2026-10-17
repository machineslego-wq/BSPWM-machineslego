#!/bin/bash
# ==========================================================
# install.sh — Автоматическая установка BSPWM-machineslego
# ==========================================================

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP="/etc/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Определяем реального пользователя (если скрипт запущен через sudo)
if [ -n "$SUDO_USER" ]; then
    REAL_USER=$SUDO_USER
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    REAL_USER=$USER
    REAL_HOME=$HOME
fi

echo "=== Установка BSPWM-machineslego ==="
echo "Репозиторий: $DOTFILES"
echo "Пользователь: $REAL_USER"
echo ""

# Запрашиваем пароль sudo один раз в начале
sudo -v || { echo "Ошибка: требуются права sudo."; exit 1; }

# 1. Установка пакетов
echo "[1/5] Установка базовых пакетов..."
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
  fish fontconfig \
  wget unzip xclip lm-sensors
echo "  Базовые пакеты установлены."
sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/Изображения/Screenshots"
echo "  Создана папка для скриншотов."

echo ""

# 2. Установка шрифта JetBrainsMono Nerd Font
echo "[2/5] Установка шрифта JetBrainsMono Nerd Font..."
FONT_DIR="$REAL_HOME/.local/share/fonts"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/JetBrainsMono.zip"
TMP_ZIP="/tmp/JetBrainsMono.zip"

if sudo -u "$REAL_USER" fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    echo "  Шрифт JetBrainsMono Nerd Font уже установлен. Пропускаем."
else
    echo "  Скачиваем JetBrainsMono.zip..."
    sudo -u "$REAL_USER" mkdir -p "$FONT_DIR"
    sudo -u "$REAL_USER" wget -q --show-progress "$FONT_URL" -O "$TMP_ZIP"
    
    echo "  Распаковываем..."
    sudo -u "$REAL_USER" unzip -q "$TMP_ZIP" -d "$FONT_DIR"
    rm -f "$TMP_ZIP"
    
    echo "  Обновляем кэш шрифтов..."
    sudo -u "$REAL_USER" fc-cache -f "$FONT_DIR" >/dev/null
    echo "  Шрифт успешно установлен."
fi
echo ""

# 3. Настройка питания (автоопределение)
echo "[3/5] Настройка управления питанием..."
if command -v powerprofilesctl &>/dev/null; then
    echo "  -> Обнаружен power-profiles-daemon. Оставляем как есть."
elif ls /sys/class/power_supply/BAT* &>/dev/null; then
    echo "  -> Обнаружен ноутбук. Устанавливаем TLP..."
    sudo apt install -y tlp tlp-rdw
    sudo systemctl enable --now tlp
    echo "$REAL_USER ALL=(ALL) NOPASSWD: /usr/sbin/tlp, /usr/bin/tlp-stat" | sudo tee /etc/sudoers.d/tlp > /dev/null
    sudo chmod 440 /etc/sudoers.d/tlp
else
    echo "  -> Обнаружен ПК. Устанавливаем cpupower..."
    sudo apt install -y linux-cpupower
    echo "$REAL_USER ALL=(ALL) NOPASSWD: /usr/bin/cpupower" | sudo tee /etc/sudoers.d/cpupower > /dev/null
    sudo chmod 440 /etc/sudoers.d/cpupower
fi
echo ""

# 4. Линковка пользовательских конфигов
echo "[4/5] Линковка конфигов..."
sudo -u "$REAL_USER" bash "$DOTFILES/scripts/link.sh"
echo ""

# 5. Установка системных конфигов
echo "[5/5] Установка системных конфигов в /etc/..."
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