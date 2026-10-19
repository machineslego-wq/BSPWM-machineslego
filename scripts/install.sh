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
  xorg xinit xserver-xorg-input-libinput \
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
  wget curl unzip xclip lm-sensors \
  imagemagick xdg-utils xdotool

echo "  Базовые пакеты установлены."
sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/Изображения/Screenshots"
echo "  Создана папка для скриншотов."

# Умная настройка звука
if command -v wpctl &>/dev/null; then
    echo "  -> Обнаружен PipeWire. Устанавливаем дополнения."
    sudo apt install -y pipewire pipewire-audio wireplumber libspa-0.2-bluetooth
elif command -v pactl &>/dev/null; then
    echo "  -> Обнаружен PulseAudio. Устанавливаем утилиты."
    sudo apt install -y pulseaudio-utils
else
    echo "  -> Звуковой сервер не обнаружен. Пропускаем."
fi
echo ""


# 2. Установка шрифта JetBrainsMono Nerd Font
# ... (этот блок у тебя написан правильно, не трогаем) ...


# =========================================================
# Настройка GTK (для GTK3 и GTK4/libadwaita приложений)
# =========================================================
echo "[2.5/5] Настройка тем GTK и иконок..."
# =========================================================
# СЮДА ПРАВКИ И УСТАНОВКУ КУРСОРА НАДО, А ЖЕЛАТЕЛЬНО 
# КОНФИГИ ВЫНЕСТИ В РЕПОЗИТОРИИ В /home И ОТСЮДА УЖЕ РЕДАЧИТЬ
# =========================================================
# 1. Записываем настройки для GTK3 от имени обычного пользователя
sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/.config/gtk-3.0"
sudo -u "$REAL_USER" tee "$REAL_HOME/.config/gtk-3.0/settings.ini" > /dev/null <<EOF
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
EOF

# 2. Записываем настройки для GTK4 от имени обычного пользователя
sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/.config/gtk-4.0"
sudo -u "$REAL_USER" tee "$REAL_HOME/.config/gtk-4.0/settings.ini" > /dev/null <<EOF
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
EOF

# 3. Добавляем переменную окружения GTK_THEME в .xprofile
if ! grep -q "GTK_THEME" "$REAL_HOME/.xprofile" 2>/dev/null; then
    echo 'export GTK_THEME=Adwaita-dark' | sudo -u "$REAL_USER" tee -a "$REAL_HOME/.xprofile" > /dev/null
fi

echo "  Настройка GTK завершена. Для полного применения перезагрузите систему."
echo ""

# 3. Создаем конфиг для GTK4, чтобы он подхватывал тему
mkdir -p "$REAL_HOME/.config/gtk-4.0"
cat > "$REAL_HOME/.config/gtk-4.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
EOF

# 4. Добавляем переменную окружения GTK_THEME в .xprofile для принудительного применения
# (это заставит GTK4 приложения использовать темную тему)
if ! grep -q "GTK_THEME" "$REAL_HOME/.xprofile" 2>/dev/null; then
    echo 'export GTK_THEME=Adwaita-dark' >> "$REAL_HOME/.xprofile"
fi

echo "  Настройка GTK завершена. Для полного применения可能需要 перезагрузка."

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
    echo "  -> Обнаружен ПК. Управление питанием через Polybar не настраивается."
    echo "     (Для десктопа рекомендуется использовать CoreCtrl или BIOS)."
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
        # Получаем путь внутри папки system (например, X11/xorg.conf.d/...)
        rel_path="${src_file#$DOTFILES/system/}"
        
        # Если папка etc отсутствует в пути, принудительно добавляем её
        if [[ "$rel_path" != etc/* ]]; then
            rel_path="etc/$rel_path"
        fi
        
        # Итоговый путь в системе
        dst_file="/$rel_path"
        dst_dir="$(dirname "$dst_file")"
        
        echo "  -> $dst_file"
        
        # Бэкапим файл, если он уже существует
        if [ -f "$dst_file" ]; then
            # Создаем структуру папок для бэкапа внутри /etc/dotfiles-backup-...
            sudo mkdir -p "$BACKUP$dst_dir"
            sudo cp "$dst_file" "$BACKUP$dst_file"
            echo "     (оригинал сохранен в бэкап)"
        fi

        # Создаем папку назначения (если ее нет) и копируем файл
        sudo mkdir -p "$dst_dir"
        sudo cp "$src_file" "$dst_file"
    done
    echo "  Бэкап старых системных файлов находится здесь: $BACKUP"
fi

echo ""
echo "=== Установка завершена! ==="
echo "Перезагрузите систему или запустите startx."