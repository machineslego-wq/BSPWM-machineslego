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

echo "[1/6] Installing base packages... (Установка базовых пакетов...)"
sudo apt update

# Минимальный набор для работы оболочки. 
# gvfs и xdg-user-dirs обязательны для быстрой работы Thunar.
# PipeWire и pipewire-pulse добавлены сразу для гарантии работы Polybar и volume.sh.
# copyq, xss-lock, lxpolkit — утилиты для комфорта (история буфера, автоблокировка, polkit).
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
  zsh zsh-autosuggestions zsh-syntax-highlighting \
  wget curl unzip xclip lm-sensors \
  jq \
  imagemagick xdg-utils xdg-user-dirs xdotool fastfetch \
  pipewire pipewire-audio pipewire-pulse wireplumber libspa-0.2-bluetooth \
  copyq xss-lock lxpolkit

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

echo "[2/6] Installing JetBrainsMono Nerd Font... (Установка шрифта JetBrainsMono Nerd Font...)"
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

echo "[3/7] Installing Powerlevel10k... (Установка Powerlevel10k...)"
P10K_DIR="$REAL_HOME/.powerlevel10k"

if [ ! -d "$P10K_DIR" ]; then
    echo "  -> Cloning powerlevel10k... (Клонируем powerlevel10k...)"
    sudo -u "$REAL_USER" git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    echo "  Powerlevel10k already installed. Skipping. (Уже установлен. Пропускаем.)"
fi
echo ""

echo "[4/7] Configuring power management... (Настройка управления питанием...)"
# Унифицируем управление питанием на power-profiles-daemon (PPD).
# PPD работает и на ноутбуках, и на ПК. Это стандарт для десктопных
# окружений (GNOME, KDE, Cinnamon) и рекомендация производителей
# для AMD Ryzen 7000-й серии.

# 1. Удаляем TLP, если он установлен — иначе apt откажется ставить PPD
if dpkg -l 2>/dev/null | grep -q "^ii  tlp "; then
    echo "  -> TLP detected. Removing to avoid conflict with PPD. (Обнаружен TLP. Удаляем во избежание конфликта с PPD.)"
    sudo systemctl disable --now tlp 2>/dev/null || true
    sudo apt purge -y tlp tlp-rdw
    sudo apt autoremove -y
    sudo rm -f /etc/sudoers.d/tlp
    echo "  -> TLP removed. (TLP удалён.)"
fi

# 2. Устанавливаем PPD
sudo apt install -y power-profiles-daemon

# 3. Включаем и запускаем сервис
if sudo systemctl enable --now power-profiles-daemon 2>/dev/null; then
    CURRENT_PROFILE=$(powerprofilesctl get 2>/dev/null || echo "unknown")
    echo "  -> PPD is running. Current profile: ${CURRENT_PROFILE} (PPD работает. Текущий профиль: ${CURRENT_PROFILE})"
else
    echo "  -> WARNING: PPD failed to start. Check: systemctl status power-profiles-daemon (ПРЕДУПРЕЖДЕНИЕ: PPD не запустился.)"
fi

# 4. Показываем текущий профиль
CURRENT_PROFILE=$(powerprofilesctl get 2>/dev/null || echo "unknown")
echo "  -> PPD is running. Current profile: ${CURRENT_PROFILE} (PPD работает. Текущий профиль: ${CURRENT_PROFILE})"
echo ""

echo "[5/7] Linking configs... (Линковка конфигов...)"
export DOTFILES
sudo -u "$REAL_USER" env HOME="$REAL_HOME" DOTFILES="$DOTFILES" bash "$DOTFILES/scripts/link.sh"
echo ""

echo "[6/7] Installing system configs to /etc/... (Установка системных конфигов в /etc/...)"
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

echo "[7/7] Configuring lid close behavior (suspend)... (Настройка поведения при закрытии крышки (сон)...)"
# Настраиваем уход в сон при закрытии крышки ноутбука.
# Это универсальная настройка для всех ноутбуков (наличие батареи),
# так как проблемы с засыпанием распространены на AMD-платформах.
if ls /sys/class/power_supply/BAT* &>/dev/null; then
    LID_CONF="/etc/systemd/logind.conf.d/10-lid-suspend.conf"

    # Бэкап существующего конфига (если пользователь уже настраивал вручную)
    if [ -f "$LID_CONF" ]; then
        sudo cp "$LID_CONF" "${LID_CONF}.bak-$(date +%Y%m%d-%H%M%S)"
        echo "  -> Existing lid config backed up (Существующий конфиг сохранён в бэкап)."
    fi

    sudo mkdir -p /etc/systemd/logind.conf.d
    # Удаляем старый конфиг блокировки из предыдущих версий (v1.1.0-dev)
    if [ -f "/etc/systemd/logind.conf.d/10-lid-lock.conf" ]; then
        sudo mv "/etc/systemd/logind.conf.d/10-lid-lock.conf" \
                "/etc/systemd/logind.conf.d/10-lid-lock.conf.bak-$(date +%Y%m%d-%H%M%S)"
        echo "  -> Old lid lock config moved aside (Старый конфиг блокировки отложен в бэкап)."
    fi
    sudo tee "$LID_CONF" > /dev/null <<'EOF'
# BSPWM-machineslego: уход в сон при закрытии крышки ноутбука.
# Система засыпает (suspend), а экран блокируется через xss-lock.
# Чтобы вернуть блокировку без сна, замените suspend на lock
# и выполните: sudo systemctl kill -s HUP systemd-logind

[Login]
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=suspend
HandleLidSwitchDocked=ignore
EOF

    # Мягкая перезагрузка конфигурации logind через SIGHUP.
    # Не прерывает графическую сессию, в отличие от restart.
    sudo systemctl kill -s HUP systemd-logind 2>/dev/null || true
    echo "  -> Lid close will now trigger suspend. (Закрытие крышки теперь будет отправлять систему в сон.)"
else
    echo "  -> Desktop PC detected. Skipping lid configuration. (Обнаружен ПК — пропускаем настройку крышки.)"
fi
echo ""

echo "=== Installation complete! (Установка завершена!) ==="
echo "Please reboot or run startx. (Перезагрузите систему или запустите startx.)"