#!/bin/bash
# ==========================================================
# software.sh — Установка пользовательского софта
# ==========================================================
# Вызывается из install.sh, если пользователь ответил "y".
# ==========================================================

if [ -n "$SUDO_USER" ]; then
    REAL_USER=$SUDO_USER
else
    REAL_USER=$USER
fi

echo "=== Installing Additional Software (Установка дополнительного софта) ==="
sudo -v || { echo "Error: sudo required."; exit 1; }

# ==========================================================
# 1. Терминальные инструменты и разработка
# ==========================================================
echo "-> Installing Dev tools (lazygit, neovim)..."
sudo apt install -y \
  lazygit \
  neovim \
  htop \
  ranger

# ==========================================================
# 2. Медиа, Документы и Архивы (Легковесные)
# ==========================================================
echo "-> Installing Media, Document and Archive apps..."
sudo apt install -y \
  mpv \                          # Видеоплеер
  nsxiv \                        # Просмотрщик картинок (Vim-style)
  zathura zathura-pdf-poppler \  # PDF-читалка (Vim-style)
  xarchiver                      # Легкий архиватор

# ==========================================================
# 3. Flatpak приложения (опционально)
# ==========================================================
# Раскомментируй, если хочешь поставить Telegram через Flatpak автоматически
# echo "-> Installing Flatpak apps..."
# sudo -u "$REAL_USER" flatpak install -y flathub org.telegram.desktop

echo ""
echo "=== Additional software installed! (Доп. софт установлен!) ==="