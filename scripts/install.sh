#!/bin/bash
# ==========================================================
# install.sh — Автоматическая установка BSPWM-machineslego
# ==========================================================

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP="/etc/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

if [ -n "$SUDO_USER" ]; then
    REAL_USER=$SUDO_USER
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    REAL_USER=$USER
    REAL_HOME=$HOME
fi

echo "=== BSPWM-machineslego Installation (Установка BSPWM-machineslego) ==="
echo "Repository (Репозиторий): $DOTFILES"
echo "User (Пользователь): $REAL_USER"
echo ""

sudo -v || { echo "Error: sudo privileges required (Ошибка: требуются права sudo)."; exit 1; }

echo "[1/5] Installing base packages... (Установка базовых пакетов...)"
sudo apt update

sudo apt install -y \
  xorg xinit xserver-xorg-input-libinput \
  bspwm sxhkd \
  polybar rofi dunst picom feh \
  lxappearance \
  papirus-icon-theme bibata-cursor-theme \
  fonts-jetbrains-mono fonts-font-awesome \
  fonts-noto-color-emoji \
  brightnessctl scrot \
  network-manager pavucontrol blueman \
  thunar alacritty \
  i3lock-fancy libnotify-bin \
  fish fontconfig \
  wget curl unzip xclip lm-sensors \
  imagemagick xdg-utils xdotool fastfetch

echo "  Base packages installed. (Базовые пакеты установлены.)"

# ИСПРАВЛЕНО: Безопасное определение папки для картинок
PICTURES_DIR=$(sudo -u "$REAL_USER" xdg-user-dir PICTURES 2>/dev/null)
if [ -z "$PICTURES_DIR" ] || [ "$PICTURES_DIR" = "$REAL_HOME" ]; then
    PICTURES_DIR="$REAL_HOME/Pictures"
fi
sudo -u "$REAL_USER" mkdir -p "$PICTURES_DIR/Screenshots"
echo "  Screenshots folder created (Создана папка для скриншотов): $PICTURES_DIR/Screenshots"

if command -v wpctl &>/dev/null; then
    echo "  -> PipeWire detected. Installing add-ons. (Обнаружен PipeWire. Устанавливаем дополнения.)"
    sudo apt install -y pipewire pipewire-audio wireplumber libspa-0.2-bluetooth
elif command -v pactl &>/dev/null; then
    echo "  -> PulseAudio detected. Installing utilities. (Обнаружен PulseAudio. Устанавливаем утилиты.)"
    sudo apt install -y pulseaudio-utils
else
    echo "  -> Audio server not detected. Skipping. (Звуковой сервер не обнаружен. Пропускаем.)"
fi
echo ""

echo "[2/5] Installing JetBrainsMono Nerd Font... (Установка шрифта JetBrainsMono Nerd Font...)"
FONT_DIR="$REAL_HOME/.local/share/fonts"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/JetBrainsMono.zip"
# ИСПРАВЛЕНО: Безопасный временный файл
TMP_ZIP=$(mktemp /tmp/JetBrainsMono-XXXXXX.zip)

if sudo -u "$REAL_USER" fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    echo "  JetBrainsMono Nerd Font already installed. Skipping. (Шрифт уже установлен. Пропускаем.)"
    rm -f "$TMP_ZIP" # Удаляем пустой tmp файл, если он создался
else
    echo "  Downloading JetBrainsMono.zip... (Скачиваем JetBrainsMono.zip...)"
    sudo -u "$REAL_USER" mkdir -p "$FONT_DIR"
    sudo -u "$REAL_USER" wget -q --show-progress "$FONT_URL" -O "$TMP_ZIP"
    
    echo "  Extracting... (Распаковываем...)"
    sudo -u "$REAL_USER" unzip -q "$TMP_ZIP" -d "$FONT_DIR"
    rm -f "$TMP_ZIP"
    
    echo "  Updating font cache... (Обновляем кэш шрифтов...)"
    sudo -u "$REAL_USER" fc-cache -f "$FONT_DIR" >/dev/null
    echo "  Font installed successfully. (Шрифт успешно установлен.)"
fi
echo ""

echo "[3/5] Configuring power management... (Настройка управления питанием...)"
if command -v powerprofilesctl &>/dev/null; then
    echo "  -> power-profiles-daemon detected. Leaving as is. (Обнаружен power-profiles-daemon. Оставляем как есть.)"
elif ls /sys/class/power_supply/BAT* &>/dev/null; then
    echo "  -> Laptop detected. Installing TLP... (Обнаружен ноутбук. Устанавливаем TLP...)"
    sudo apt install -y tlp tlp-rdw
    sudo systemctl enable --now tlp
    
    # Проверяем реальный путь к tlp
    TLP_PATH=$(command -v tlp || echo "/usr/sbin/tlp")
    echo "$REAL_USER ALL=(ALL) NOPASSWD: $TLP_PATH, /usr/bin/tlp-stat" | sudo tee /etc/sudoers.d/tlp > /dev/null
    sudo chmod 440 /etc/sudoers.d/tlp
else
    echo "  -> Desktop PC detected. Power management via Polybar is not configured. (Обнаружен ПК. Управление питанием через Polybar не настраивается.)"
fi
echo ""

echo "[4/5] Linking configs... (Линковка конфигов...)"
export DOTFILES
# ИСПРАВЛЕНО: Явная передача HOME и DOTFILES
sudo -u "$REAL_USER" env HOME="$REAL_HOME" DOTFILES="$DOTFILES" bash "$DOTFILES/scripts/link.sh"
echo ""

echo "[5/5] Installing system configs to /etc/... (Установка системных конфигов в /etc/...)"
if [ -d "$DOTFILES/system" ]; then
    sudo mkdir -p "$BACKUP"
    
    find "$DOTFILES/system" -type f | while read -r src_file; do
        rel_path="${src_file#$DOTFILES/system/}"
        
        if [[ "$rel_path" != etc/* ]]; then
            rel_path="etc/$rel_path"
        fi
        
        dst_file="/$rel_path"
        dst_dir="$(dirname "$dst_file")"
        
        echo "  -> $dst_file"
        
        if [ -f "$dst_file" ]; then
            sudo mkdir -p "$BACKUP$dst_dir"
            sudo cp "$dst_file" "$BACKUP$dst_file"
            echo "     (original backed up / оригинал сохранен в бэкап)"
        fi

        sudo mkdir -p "$dst_dir"
        sudo cp "$src_file" "$dst_file"
    done
    echo "  Backup of old system files is located here (Бэкап старых системных файлов): $BACKUP"
fi

echo ""
echo "=== Installation complete! (Установка завершена!) ==="
echo "Please reboot or run startx. (Перезагрузите систему или запустите startx.)"