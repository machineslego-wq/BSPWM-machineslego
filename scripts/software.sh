#!/bin/bash
# ==========================================================
# software.sh — Установка пользовательского софта
# ==========================================================
# Сначала читает requirements/software.txt, потом устанавливает пакеты.
# Целевая система: Debian 13 Trixie
# ==========================================================

if [ -n "$SUDO_USER" ]; then
    REAL_USER=$SUDO_USER
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    REAL_USER=$USER
    REAL_HOME=$HOME
fi

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== Installing Additional Software (Установка дополнительного софта) ==="
sudo -v || { echo "Error: sudo required. (Ошибка: требуются права sudo.)"; exit 1; }

# ==========================================================
# 1. Системные пакеты из requirements/software.txt
# ==========================================================
echo "-> Installing packages from requirements/software.txt..."

# Сначала устанавливаем AppImage (Neovim)
NEOVIM_URL=$(grep -v '^#' "$DOTFILES/requirements/software.txt" | grep -v '^$' | grep 'https://.*\.appimage')
if [ -n "$NEOVIM_URL" ]; then
    echo "  -> Installing Neovim (AppImage)..."
    NVIM_BIN="$REAL_HOME/.local/bin/nvim"
    sudo -u "$REAL_USER" mkdir -p "$REAL_HOME/.local/bin"
    if [ ! -f "$NVIM_BIN" ]; then
        sudo -u "$REAL_USER" wget -q --show-progress "$NEOVIM_URL" -O "$NVIM_BIN"
        sudo -u "$REAL_USER" chmod +x "$NVIM_BIN"
        echo "  -> Neovim AppImage installed to ~/.local/bin/nvim"
    else
        echo "  -> Neovim already installed. Skipping."
    fi
fi

# Устанавливаем apt-пакеты (все строки без https и без комментариев)
echo "  -> Installing apt packages..."
while IFS= read -r pkg || [ -n "$pkg" ]; do
    # Пропускаем пустые строки, комментарии и URL
    [[ -z "$pkg" || "$pkg" =~ ^# || "$pkg" =~ ^https:// ]] && continue
    
    if ! dpkg -l | grep -q "^ii  $pkg "; then
        echo "    Installing: $pkg"
        sudo apt install -y "$pkg"
    else
        echo "    Already installed: $pkg"
    fi
done < "$DOTFILES/requirements/software.txt"

echo ""

# ==========================================================
# 2. Дополнительные Flatpak приложения (опционально)
# ==========================================================
echo "=== Additional software installed! (Доп. софт установлен!) ==="
echo ""
echo "Flatpak apps can be installed manually with:"
echo "  flatpak install flathub com.obsproject.Studio"
echo "  flatpak install flathub org.telegram.desktop"
echo "  flatpak install flathub org.gimp.GIMP"
echo ""
