#!/bin/bash
# ==========================================================
# install-sway.sh — Sway и его окружение (переезд с BSPWM)
# ==========================================================
# Ставит только пакеты из requirements/sway.txt: конфиги не копирует
# и сессию не включает (Sway-конфиг живёт в config/sway и линкуется
# через link.sh). GDM после установки сам покажет сессию Sway.
#
# Использование (от обычного пользователя, sudo внутри):
#   ./scripts/install-sway.sh            только пакеты
#   ./scripts/install-sway.sh --session  пакеты + сессия GDM через sway-session
#
# Скрипт идемпотентен: уже установленные пакеты пропускаются,
# файл сессии перезаписывается.
# ==========================================================

set -euo pipefail

usage() {
    cat <<'EOF'
Использование: ./scripts/install-sway.sh [--session]

  без флагов  только пакеты из requirements/sway.txt
  --session   дополнительно пишет /usr/share/wayland-sessions/sway-session.desktop
              (запуск Sway через обёртку ~/.local/bin/sway-session)
  -h, --help  эта справка
EOF
}

with_session=0
for arg in "$@"; do
    case "$arg" in
        --session) with_session=1 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Error: неизвестный аргумент: $arg" >&2; usage >&2; exit 1 ;;
    esac
done

if [ "$(id -u)" -eq 0 ]; then
    echo "Error: запусти скрипт от обычного пользователя (sudo используется внутри)." >&2
    exit 1
fi

if [ ! -f /etc/debian_version ]; then
    echo "Error: скрипт рассчитан на Debian." >&2
    exit 1
fi

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIST="$DOTFILES/requirements/sway.txt"

if [ ! -f "$LIST" ]; then
    echo "Error: не найден $LIST" >&2
    exit 1
fi

log() { printf '%s\n' "$*"; }

log "=== Sway: установка пакетов ==="
log ""

sudo -v || { echo "Error: требуются права sudo." >&2; exit 1; }

missing=()
while IFS= read -r pkg || [ -n "$pkg" ]; do
    [[ -z "$pkg" || "$pkg" =~ ^[[:space:]]*# ]] && continue
    pkg="${pkg//[[:space:]]/}"

    if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q 'install ok installed'; then
        log "  уже стоит: $pkg"
    else
        log "  ставим:    $pkg"
        missing+=("$pkg")
    fi
done < "$LIST"

log ""
if [ ${#missing[@]} -gt 0 ]; then
    sudo apt install -y "${missing[@]}"
else
    log "Все пакеты уже установлены."
fi

# --- Сессия GDM (опционально) ---
# GDM читает только /usr/share/wayland-sessions, пользовательские каталоги
# сессий он не смотрит, поэтому файл создаётся с sudo.
if [ "$with_session" -eq 1 ]; then
    SESSION_FILE=/usr/share/wayland-sessions/sway-session.desktop
    WRAPPER="$HOME/.local/bin/sway-session"

    log ""
    log "=== Сессия GDM: $SESSION_FILE ==="
    if [ ! -x "$WRAPPER" ]; then
        log "  внимание: $WRAPPER ещё нет — запусти ./scripts/link.sh"
    fi

    sudo mkdir -p /usr/share/wayland-sessions
    sudo tee "$SESSION_FILE" >/dev/null <<EOF
[Desktop Entry]
Name=Sway (dotfiles)
Comment=Sway with the dotfiles environment (Qt, GTK, cursor, PATH)
Exec=$WRAPPER
Type=Application
DesktopNames=sway
EOF
    sudo chmod 644 "$SESSION_FILE"
    log "  записан: $SESSION_FILE"
    log "  Exec=$WRAPPER"
fi

log ""
log "=== Готово ==="
if command -v sway >/dev/null 2>&1; then
    log "Sway: $(sway --version | head -n 1)"
fi
log ""
log "Конфиг Sway лежит в репозитории: config/sway/config"
log "  линкуется в ~/.config/sway через ./scripts/link.sh"
log "Мониторы и обои: sway-display, терминал: config/foot"
log ""
log "Проверка конфига: sway -C -c ~/.config/sway/config"
log "Запуск из TTY: sway-session"
if [ "$with_session" -eq 1 ]; then
    log "Запуск из GDM: шестерёнка -> Sway (dotfiles)"
else
    log "Сессия GDM с окружением: ./scripts/install-sway.sh --session"
fi
log "Выход: Super+Shift+E"
