#!/bin/bash
# ==========================================================
# software.sh — Установка дополнительного софта
# ==========================================================
# Читает пакеты из requirements/software.txt и устанавливает их.
# Целевая система: Debian 13 Trixie
# Запускается после install.sh, если нужен дополнительный софт.
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

echo "-> Installing packages from requirements/software.txt..."
echo ""

# Устанавливаем apt-пакеты (все строки без https и без комментариев)
while IFS= read -r pkg || [ -n "$pkg" ]; do
    # Пропускаем пустые строки, комментарии и URL
    [[ -z "$pkg" || "$pkg" =~ ^# || "$pkg" =~ ^https:// ]] && continue
    
    if ! dpkg -l | grep -q "^ii  $pkg "; then
        echo "  Installing: $pkg"
        sudo apt install -y "$pkg"
    else
        echo "  Already installed: $pkg"
    fi
done < "$DOTFILES/requirements/software.txt"

echo ""
echo "=== Additional software installed! (Доп. софт установлен!) ==="
echo ""
echo "Optional Flatpak apps can be installed manually:"
echo "  flatpak install flathub com.obsproject.Studio"
echo "  flatpak install flathub org.telegram.desktop"
echo "  flatpak install flathub org.gimp.GIMP"
echo ""
