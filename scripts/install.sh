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

# Минимальный набор для работы оболочки. 
# gvfs и xdg-user-dirs обязательны для быстрой работы Thunar.
# PipeWire и pipewire-pulse добавлены сразу для гарантии работы Polybar и volume.sh.
sudo apt install -y \
  xorg xinit xserver-xorg-input-libinput \
  bspwm sxhkd \
  polybar rofi dunst picom feh \
  lxappearance \
  papirus-icon-theme bibata-cursor-theme \
  fonts-jetbrains-mono fonts-font-awesome \
  fonts-noto-color-emoji \
  brightnessctl maim slop scrot \
  network-manager pavucontrol blueman \
  thunar gvfs gvfs-backends gvfs-fuse \
  alacritty \
  i3lock-fancy libnotify-bin \
  fish fontconfig \
  wget curl unzip xclip lm-sensors \
  imagemagick xdg-utils xdg-user-dirs xdotool fastfetch \
  grabc \
  pipewire pipewire-audio pipewire-pulse wireplumber libspa-0.2-bluetooth

echo "  Base packages installed. (Базовые пакеты установлены.)"

# Генерация стандартных папок XDG (Загрузки, Документы и т.д.)
# Без этого Thunar будет виснуть при запуске.
sudo -u "$REAL_USER" xdg-user-dirs-update
echo "  XDG user directories updated (Стандартные папки обновлены)."

# Создание папки для скриншотов
sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/Screenshots"
echo "  Screenshots folder created (Создана папка для скриншотов): ~/Screenshots"

# ==========================================================
# Принудительный переход на PipeWire
# ==========================================================
echo "  -> Configuring audio backend (Настройка аудио-бэкенда)..."
# Если установлен чистый PulseAudio (и нет PipeWire), удаляем его во избежание конфликтов
if dpkg -l | grep -q "^ii  pulseaudio " && ! command -v wpctl &>/dev/null; then
    echo "  -> Pure PulseAudio detected. Removing to prevent conflicts. (Обнаружен чистый PulseAudio. Удаляем во избежание конфликтов.)"
    
    # Останавливаем и отключаем службы PulseAudio для текущего пользователя
    systemctl --user stop pulseaudio.socket pulseaudio.service 2>/dev/null || true
    systemctl --user disable pulseaudio.socket pulseaudio.service 2>/dev/null || true
    
    # Удаляем пакет PulseAudio
    sudo apt purge -y pulseaudio
    sudo apt autoremove -y
fi

# Перезагружаем systemd, чтобы он увидел новые аудио-сервисы
systemctl --user daemon-reload
echo "  -> PipeWire is ready. (PipeWire готов.)"
echo ""

echo "[2/5] Installing JetBrainsMono Nerd Font... (Установка шрифта JetBrainsMono Nerd Font...)"
FONT_DIR="$REAL_HOME/.local/share/fonts"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/JetBrainsMono.zip"
TMP_ZIP=$(mktemp /tmp/JetBrainsMono-XXXXXX.zip)

if sudo -u "$REAL_USER" fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    echo "  JetBrainsMono Nerd Font already installed. Skipping. (Шрифт уже установлен. Пропускаем.)"
    rm -f "$TMP_ZIP"
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
    
    TLP_PATH=$(command -v tlp || echo "/usr/sbin/tlp")
    echo "$REAL_USER ALL=(ALL) NOPASSWD: $TLP_PATH, /usr/bin/tlp-stat" | sudo tee /etc/sudoers.d/tlp > /dev/null
    sudo chmod 440 /etc/sudoers.d/tlp
else
    echo "  -> Desktop PC detected. Power management via Polybar is not configured. (Обнаружен ПК. Управление питанием через Polybar не настраивается.)"
fi
echo ""

echo "[4/5] Linking configs... (Линковка конфигов...)"
export DOTFILES
sudo -u "$REAL_USER" env HOME="$REAL_HOME" DOTFILES="$DOTFILES" bash "$DOTFILES/scripts/link.sh"
echo ""

echo "[5/5] Installing system configs to /etc/... (Установка системных конфигов в /etc/...)"
# ВНИМАНИЕ: Этот блок копирует файлы в /etc. 
# Если у тебя установлен GNOME, он может перезаписать настройки тачпада и сети. 
# В случае проблем с GNOME, восстанови файлы из бэкапа.
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
            echo "     (оригинал сохранен в бэкап)"
        fi

        sudo mkdir -p "$dst_dir"
        sudo cp "$src_file" "$dst_file"
    done
    echo "  Бэкап старых системных файлов находится здесь: $BACKUP"
fi

echo ""
echo "=== Installation complete! (Установка завершена!) ==="
echo "Please reboot or run startx. (Перезагрузите систему или запустите startx.)"