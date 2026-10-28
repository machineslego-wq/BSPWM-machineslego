#!/bin/bash
# ==========================================================
# software.sh — Установка пользовательского софта
# ==========================================================
# Вызывается из install.sh, если пользователь ответил "y".
# Целевая система: Debian 13 Trixie
# ==========================================================

if [ -n "$SUDO_USER" ]; then
    REAL_USER=$SUDO_USER
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    REAL_USER=$USER
    REAL_HOME=$HOME
fi

echo "=== Installing Additional Software (Установка дополнительного софта) ==="
sudo -v || { echo "Error: sudo required. (Ошибка: требуются права sudo.)"; exit 1; }

# ==========================================================
# 1. Инструменты разработчика и терминала
# ==========================================================
echo "-> Installing Dev & Terminal tools..."
sudo apt install -y \
  lazygit \
  htop \
  ranger \
  btop \
  micro \
  tty-clock \
  tmux

# ==========================================================
# 2. Neovim (AppImage)
# ==========================================================
# В репозитории Debian 13 версия 0.10.4, что слишком старо для LazyVim.
# Ставим официальный AppImage в ~/.local/bin
echo "-> Installing Neovim (AppImage)..."
NVIM_BIN="$REAL_HOME/.local/bin/nvim"
NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"

sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/.local/bin"

if [ ! -f "$NVIM_BIN" ]; then
    sudo -u "$REAL_USER" wget -q --show-progress "$NVIM_URL" -O "$NVIM_BIN"
    sudo -u "$REAL_USER" chmod +x "$NVIM_BIN"
    echo "  -> Neovim AppImage installed to ~/.local/bin/nvim"
else
    echo "  -> Neovim already installed. Skipping."
fi

# ==========================================================
# 3. Системные утилиты для комфортной работы в BSPWM
# ==========================================================
echo "-> Installing System Utilities..."
sudo apt install -y \
  udiskie \
  lxrandr \
  redshift \
  gnome-disk-utility

# ==========================================================
# 4. Музыка
# ==========================================================
echo "-> Installing Music player..."
sudo apt install -y strawberry

# ==========================================================
# 5. Видео и стриминг
# ==========================================================
echo "-> Installing Video players & OBS Studio..."
sudo apt install -y \
  mpv \
  vlc \
  obs-studio

# ==========================================================
# 6. Просмотр изображений
# ==========================================================
echo "-> Installing Image viewer..."
sudo apt install -y nsxiv

# ==========================================================
# 7. Архиваторы (в Trixie 7zip заменяет p7zip)
# ==========================================================
echo "-> Installing Archivers..."
sudo apt install -y \
  7zip \
  xarchiver

# ==========================================================
# 8. PDF-ридеры
# ==========================================================
echo "-> Installing PDF readers..."
sudo apt install -y \
  zathura \
  zathura-pdf-poppler \
  mupdf

# ==========================================================
# 9. Графика и дизайн
# ==========================================================
echo "-> Installing Graphics tools..."
sudo apt install -y \
  gimp \
  inkscape

# ==========================================================
# 10. Офисный пакет
# ==========================================================
echo "-> Installing LibreOffice..."
sudo apt install -y libreoffice

# ==========================================================
# 11. Менеджер буфера обмена (выберите один вариант)
# ==========================================================
# --- Вариант А: Clyp (современный GUI на GTK4, превью картинок) ---
# echo "-> Installing Clyp (clipboard manager)..."
# CLYP_URL="https://github.com/murat-cileli/clyp/releases/download/0.9.6/clyp_0.9.6_amd64.deb"
# wget -q "$CLYP_URL" -O /tmp/clyp.deb
# sudo apt install -y /tmp/clyp.deb
# rm -f /tmp/clyp.deb
# echo "  -> Clyp installed. Bind to a hotkey (e.g., Super+V)."

# --- Вариант Б: Clipcat (Rust, минимализм, интеграция с rofi) ---
# echo "-> Installing Clipcat (clipboard manager)..."
# CLIPCAT_VER="0.26.0"
# CLIPCAT_URL="https://github.com/xrelkd/clipcat/releases/download/v${CLIPCAT_VER}/clipcat_${CLIPCAT_VER}_amd64.deb"
# wget -q "$CLIPCAT_URL" -O /tmp/clipcat.deb
# sudo apt install -y /tmp/clipcat.deb
# rm -f /tmp/clipcat.deb
# echo "  -> Clipcat installed. Use 'clipcat-menu' for hotkey."

# --- Вариант В: из официального репозитория Debian ---
# sudo apt install -y copyq    # мощный, кроссплатформенный
# sudo apt install -y diodon   # лёгкий, Vala/GTK

# ==========================================================
# 12. Flatpak приложения (опционально)
# ==========================================================
# Если нужна свежая версия OBS (32.x) или других приложений:
# sudo -u "$REAL_USER" flatpak install -y flathub com.obsproject.Studio
# sudo -u "$REAL_USER" flatpak install -y flathub org.telegram.desktop
# sudo -u "$REAL_USER" flatpak install -y flathub org.gimp.GIMP

echo ""
echo "=== Additional software installed! (Доп. софт установлен!) ==="