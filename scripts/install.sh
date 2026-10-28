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

echo "[1/8] Installing base packages... (Установка базовых пакетов...)"
sudo apt update

# Минимальный набор для работы оболочки. 
# gvfs и xdg-user-dirs обязательны для быстрой работы Thunar.
# PipeWire и pipewire-pulse добавлены сразу для гарантии работы Polybar и volume.sh.
# copyq, xss-lock, lxpolkit — утилиты для комфорта (история буфера, автоблокировка, polkit).
# fish и curl нужны для установки Tide.
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
  fish curl fontconfig \
  wget unzip xclip lm-sensors \
  jq \
  imagemagick xdg-utils xdg-user-dirs xdotool fastfetch \
  pipewire pipewire-audio pipewire-pulse wireplumber libspa-0.2-bluetooth \
  copyq xss-lock lxpolkit

echo "  Base packages installed. (Базовые пакеты установлены.)"

# Генерация стандартных папок XDG (Загрузки, Документы и т.д.)
sudo -u "$REAL_USER" xdg-user-dirs-update
echo "  XDG user directories updated (Стандартные папки обновлены)."

sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/Screenshots"
echo "  Screenshots folder created (Создана папка для скриншотов): ~/Screenshots"

# ==========================================================
# Принудительный переход на PipeWire
# ==========================================================
echo "  -> Configuring audio backend (Настройка аудио-бэкенда)..."
if dpkg -l | grep -q "^ii  pulseaudio " && ! command -v wpctl &>/dev/null; then
    echo "  -> Pure PulseAudio detected. Removing to prevent conflicts. (Обнаружен чистый PulseAudio. Удаляем во избежание конфликтов.)"
    systemctl --user stop pulseaudio.socket pulseaudio.service 2>/dev/null || true
    systemctl --user disable pulseaudio.socket pulseaudio.service 2>/dev/null || true
    sudo apt purge -y pulseaudio
    sudo apt autoremove -y
fi
systemctl --user daemon-reload
echo "  -> PipeWire is ready. (PipeWire готов.)"
echo ""

echo "[2/8] Installing JetBrainsMono Nerd Font... (Установка шрифта JetBrainsMono Nerd Font...)"
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

echo "[3/8] Configuring power management... (Настройка управления питанием...)"
if dpkg -l 2>/dev/null | grep -q "^ii  tlp "; then
    echo "  -> TLP detected. Removing to avoid conflict with PPD. (Обнаружен TLP. Удаляем во избежание конфликта с PPD.)"
    sudo systemctl disable --now tlp 2>/dev/null || true
    sudo apt purge -y tlp tlp-rdw
    sudo apt autoremove -y
    sudo rm -f /etc/sudoers.d/tlp
    echo "  -> TLP removed. (TLP удалён.)"
fi

sudo apt install -y power-profiles-daemon

if sudo systemctl enable --now power-profiles-daemon 2>/dev/null; then
    CURRENT_PROFILE=$(powerprofilesctl get 2>/dev/null || echo "unknown")
    echo "  -> PPD is running. Current profile: ${CURRENT_PROFILE} (PPD работает. Текущий профиль: ${CURRENT_PROFILE})"
else
    echo "  -> WARNING: PPD failed to start. Check: systemctl status power-profiles-daemon (ПРЕДУПРЕЖДЕНИЕ: PPD не запустился.)"
fi
echo ""

# ВАЖНО: Линковка теперь идет ДО настройки Fish!
echo "[4/8] Linking configs... (Линковка конфигов...)"
export DOTFILES
sudo -u "$REAL_USER" env HOME="$REAL_HOME" DOTFILES="$DOTFILES" bash "$DOTFILES/scripts/link.sh"
echo ""

echo "[5/8] Configuring Fish shell and Tide prompt... (Настройка Fish и промпта Tide...)"
# 1. Установка Fisher (менеджер плагинов для Fish)
echo "  -> Installing Fisher (Fish plugin manager)..."
sudo -u "$REAL_USER" fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"

# 2. Установка Tide
echo "  -> Installing Tide prompt..."
sudo -u "$REAL_USER" fish -c "fisher install IlanCosman/tide@v6"

# 3. Смена оболочки на Fish
if command -v fish &>/dev/null; then
    sudo chsh -s "$(which fish)" "$REAL_USER"
    echo "  -> Default shell changed to Fish. (Оболочка по умолчанию изменена на Fish.)"
fi

echo "  -> Tide installed. Run 'tide configure' later to customize your prompt."
echo ""

echo "[6/8] Installing system configs to /etc/... (Установка системных конфигов в /etc/...)"
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

echo "[7/8] Configuring lid close behavior (suspend)... (Настройка поведения при закрытии крышки (сон)...)"
if ls /sys/class/power_supply/BAT* &>/dev/null; then
    LID_CONF="/etc/systemd/logind.conf.d/10-lid-suspend.conf"
    if [ -f "$LID_CONF" ]; then
        sudo cp "$LID_CONF" "${LID_CONF}.bak-$(date +%Y%m%d-%H%M%S)"
        echo "  -> Existing lid config backed up (Существующий конфиг сохранён в бэкап)."
    fi
    sudo mkdir -p /etc/systemd/logind.conf.d
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

    sudo systemctl kill -s HUP systemd-logind 2>/dev/null || true
    echo "  -> Lid close will now trigger suspend. (Закрытие крышки теперь будет отправлять систему в сон.)"
else
    echo "  -> Desktop PC detected. Skipping lid configuration. (Обнаружен ПК — пропускаем настройку крышки.)"
fi
echo ""

echo "[8/8] Setting up Flatpak and optional software... (Настройка Flatpak и доп. софта...)"

# 1. Flatpak ставим в любом случае
sudo apt install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
echo "  -> Flatpak and Flathub are ready. (Flatpak и Flathub готовы.)"

# 2. Спрашиваем про доп. софт
echo ""
read -p "Do you want to install additional software (lazygit, media, etc.)? (Установить доп. софт?) [y/N]: " INSTALL_SOFTWARE

if [[ "$INSTALL_SOFTWARE" =~ ^[Yy]$ ]]; then
    echo "  -> Running software.sh... (Запускаем software.sh...)"
    # Передаем права sudo и данные пользователя в дочерний скрипт
    export SUDO_USER="$REAL_USER"
    bash "$DOTFILES/scripts/software.sh"
else
    echo "  -> Skipping additional software. (Пропускаем установку доп. софта.)"
fi
echo ""

echo "=== Installation complete! (Установка завершена!) ==="
echo "Please reboot or run startx. (Перезагрузите систему или запустите startx.)"
echo "Don't forget to run 'tide configure' in your terminal to set up the prompt!"