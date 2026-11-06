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

# ==========================================================
# ФАЗА 1: Установка без sudo (проги, шрифты, линковка)
# ==========================================================
echo "[1/4] Installing user-level software... (Установка пользовательского софта без sudo)..."

# 1.1. Установка Neovim (AppImage)
echo "  -> Installing Neovim (AppImage)..."
NVIM_BIN="$REAL_HOME/.local/bin/nvim"
NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"

mkdir -p "$REAL_HOME/.local/bin"
if [ ! -f "$NVIM_BIN" ]; then
    wget -q --show-progress "$NVIM_URL" -O "$NVIM_BIN"
    chmod +x "$NVIM_BIN"
    echo "  -> Neovim AppImage installed to ~/.local/bin/nvim"
else
    echo "  -> Neovim already installed. Skipping."
fi

# 1.2. Установка JetBrainsMono Nerd Font
echo "  -> Installing JetBrainsMono Nerd Font..."
FONT_DIR="$REAL_HOME/.local/share/fonts"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/JetBrainsMono.zip"
TMP_ZIP=$(mktemp /tmp/JetBrainsMono-XXXXXX.zip)

if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    echo "  -> JetBrainsMono Nerd Font already installed. Skipping."
    rm -f "$TMP_ZIP"
else
    mkdir -p "$FONT_DIR"
    wget -q --show-progress "$FONT_URL" -O "$TMP_ZIP"
    unzip -q "$TMP_ZIP" -d "$FONT_DIR"
    rm -f "$TMP_ZIP"
    fc-cache -f "$FONT_DIR" >/dev/null
    echo "  -> Font installed successfully."
fi

# 1.3. Линковка конфигов (без sudo)
echo "  -> Linking configs..."
export DOTFILES
env HOME="$REAL_HOME" DOTFILES="$DOTFILES" bash "$DOTFILES/scripts/link.sh"

# 1.4. Установка Fish и Tide (без sudo)
echo "  -> Installing Fisher and Tide..."
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher" 2>/dev/null
fish -c "fisher install IlanCosman/tide@v6" 2>/dev/null

echo ""
echo "[1/4] User-level software installed. (Пользовательский софт установлен.)"
echo ""

# ==========================================================
# ФАЗА 2: Установка с sudo (системные пакеты, конфиги)
# ==========================================================
sudo -v || { echo "Error: sudo privileges required (Ошибка: требуются права sudo)."; exit 1; }

echo "[2/4] Installing system packages... (Установка системных пакетов)..."

# 2.1. Основные пакеты
echo "  -> Installing base packages..."
sudo apt update

# Считываем пакеты из requirements/apt.txt (игнорируем комментарии и пустые строки)
while IFS= read -r pkg || [ -n "$pkg" ]; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    if ! dpkg -l | grep -q "^ii  $pkg "; then
        echo "    Installing: $pkg"
        sudo apt install -y "$pkg"
    else
        echo "    Already installed: $pkg"
    fi
done < "$DOTFILES/requirements/apt.txt"

echo "  -> Base packages installed."

# 2.2. Системные пакеты (TLP -> PPD, Flatpak)
echo "  -> Configuring power management..."
if dpkg -l 2>/dev/null | grep -q "^ii  tlp "; then
    echo "  -> TLP detected. Removing to avoid conflict with PPD."
    sudo systemctl disable --now tlp 2>/dev/null || true
    sudo apt purge -y tlp tlp-rdw
    sudo apt autoremove -y
    sudo rm -f /etc/sudoers.d/tlp
fi

sudo apt install -y power-profiles-daemon flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

if sudo systemctl enable --now power-profiles-daemon 2>/dev/null; then
    CURRENT_PROFILE=$(powerprofilesctl get 2>/dev/null || echo "unknown")
    echo "  -> PPD is running. Current profile: ${CURRENT_PROFILE}"
else
    echo "  -> WARNING: PPD failed to start."
fi

echo "  -> System packages installed."
echo ""

# 2.3. Системные конфиги
echo "[3/4] Installing system configs to /etc/..."
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
            echo "     (original saved to backup)"
        fi
        sudo mkdir -p "$dst_dir"
        sudo cp "$src_file" "$dst_file"
    done
    echo "  Backup of old system files: $BACKUP"
fi
echo ""

# 2.4. Настройка поведения при закрытии крышки
echo "[4/4] Configuring lid close behavior (suspend)..."
if ls /sys/class/power_supply/BAT* &>/dev/null; then
    LID_CONF="/etc/systemd/logind.conf.d/10-lid-suspend.conf"
    if [ -f "$LID_CONF" ]; then
        sudo cp "$LID_CONF" "${LID_CONF}.bak-$(date +%Y%m%d-%H%M%S)"
        echo "  -> Existing lid config backed up."
    fi
    sudo mkdir -p /etc/systemd/logind.conf.d
    if [ -f "/etc/systemd/logind.conf.d/10-lid-lock.conf" ]; then
        sudo mv "/etc/systemd/logind.conf.d/10-lid-lock.conf" \
                "/etc/systemd/logind.conf.d/10-lid-lock.conf.bak-$(date +%Y%m%d-%H%M%S)"
        echo "  -> Old lid lock config moved aside."
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
    echo "  -> Lid close will now trigger suspend."
else
    echo "  -> Desktop PC detected. Skipping lid configuration."
fi
echo ""

# ==========================================================
# ФАЗА 3: Дополнительный софт (по запросу)
# ==========================================================
echo "=== Installation complete! (Установка завершена!) ==="
echo "Please reboot or run startx. (Перезагрузите систему или запустите startx.)"
echo ""
echo "Additional software can be installed later with: bash $DOTFILES/scripts/software.sh"
echo ""
