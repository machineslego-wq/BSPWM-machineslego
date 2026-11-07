#!/bin/bash
# ==========================================================
# install-node.sh — Node.js LTS из NodeSource + npm в ~/.npm-global
# ==========================================================
# Зачем: в Debian 13 npm в официальном репозитории старый (9.x).
# Скрипт подключает официальный репозиторий NodeSource, ставит
# стабильную LTS-версию Node.js (npm идёт в комплекте) и настраивает
# npm так, чтобы глобальные пакеты ставились без sudo:
#
#     npm install -g <package>   ->   ~/.npm-global/lib/node_modules
#     бинарники                  ->   ~/.npm-global/bin
#
# Использование (запускать от обычного пользователя, sudo — внутри):
#   ./scripts/install-node.sh                    # последняя LTS
#   NODE_CHANNEL=24 ./scripts/install-node.sh    # зафиксировать major
#   NODE_CHANNEL=current ./scripts/install-node.sh
#   UPDATE_NPM=1 ./scripts/install-node.sh       # ещё и npm@latest
#
# Скрипт идемпотентен: повторный запуск ничего не ломает.
# ==========================================================

set -euo pipefail

NODE_CHANNEL="${NODE_CHANNEL:-lts}"
UPDATE_NPM="${UPDATE_NPM:-0}"
NPM_PREFIX_NAME=".npm-global"

if [ "$(id -u)" -eq 0 ]; then
    echo "Error: запусти скрипт от обычного пользователя (sudo используется внутри)." >&2
    exit 1
fi

if [ ! -f /etc/debian_version ]; then
    echo "Error: скрипт рассчитан на Debian." >&2
    exit 1
fi

if ! [[ "$NODE_CHANNEL" =~ ^(lts|current|[0-9]+)$ ]]; then
    echo "Error: NODE_CHANNEL должен быть lts, current или номер major (например 24)." >&2
    exit 1
fi

NPM_PREFIX="$HOME/$NPM_PREFIX_NAME"

log() { printf '%s\n' "$*"; }

log "=== Node.js + npm (~/$NPM_PREFIX_NAME) ==="

# ----------------------------------------------------------
# 1. Базовые утилиты для подключения репозитория
# ----------------------------------------------------------
if ! command -v curl >/dev/null 2>&1 || ! command -v gpg >/dev/null 2>&1; then
    log "-> Устанавливаю curl/ca-certificates/gnupg..."
    sudo apt-get update
    sudo apt-get install -y curl ca-certificates gnupg
fi

# ----------------------------------------------------------
# 2. Убираем npm из Debian: он конфликтует с NodeSource
# ----------------------------------------------------------
if dpkg -l npm 2>/dev/null | grep -q '^ii '; then
    log "-> Удаляю Debian-пакет npm (конфликтует с NodeSource)..."
    sudo apt-get purge -y npm
fi

# ----------------------------------------------------------
# 3. Подключаем официальный репозиторий NodeSource
# ----------------------------------------------------------
# setup_lts.x всегда указывает на актуальную LTS-линию.
# setup_24.x — зафиксировать конкретный major.
SETUP_URL="https://deb.nodesource.com/setup_${NODE_CHANNEL}.x"
TMP_SETUP="$(mktemp /tmp/nodesource-setup-XXXXXX.sh)"
trap 'rm -f "$TMP_SETUP"' EXIT

log "-> Подключаю репозиторий: $SETUP_URL"
curl -fsSL "$SETUP_URL" -o "$TMP_SETUP"
sudo -E bash "$TMP_SETUP"

sudo apt-get update

# ----------------------------------------------------------
# 4. Устанавливаем Node.js (npm идёт в комплекте)
# ----------------------------------------------------------
log "-> Устанавливаю nodejs..."
sudo apt-get install -y nodejs

# ----------------------------------------------------------
# 5. Готовим ~/.npm-global и prefix для npm
# ----------------------------------------------------------
log "-> Настраиваю npm prefix: $NPM_PREFIX"
mkdir -p "$NPM_PREFIX/bin" "$NPM_PREFIX/lib"

# Пишем prefix в ~/.npmrc, не трогая остальные настройки.
NPMRC="$HOME/.npmrc"
touch "$NPMRC"
if grep -qE '^[[:space:]]*prefix[[:space:]]*=' "$NPMRC"; then
    sed -i -E "s|^[[:space:]]*prefix[[:space:]]*=.*|prefix=~/$NPM_PREFIX_NAME|" "$NPMRC"
else
    printf '\nprefix=~/%s\n' "$NPM_PREFIX_NAME" >> "$NPMRC"
fi

# ----------------------------------------------------------
# 6. PATH для bash (~/.bashrc)
# ----------------------------------------------------------
BASH_RC="$HOME/.bashrc"
if [ -f "$BASH_RC" ]; then
    if grep -q 'npm-global' "$BASH_RC"; then
        log "-> PATH для npm-global уже есть в ~/.bashrc"
    else
        cat >> "$BASH_RC" <<'EOF'

# >>> npm-global >>>
# Глобальные пакеты npm ставятся сюда (npm -g) без sudo.
case ":$PATH:" in
    *":$HOME/.npm-global/bin:"*) ;;
    *) export PATH="$HOME/.npm-global/bin:$PATH" ;;
esac
# <<< npm-global <<<
EOF
        log "-> PATH для npm-global добавлен в ~/.bashrc"
    fi
else
    log "WARNING: ~/.bashrc не найден — PATH для npm-global не добавлен."
fi

# ----------------------------------------------------------
# 7. PATH для fish (~/.config/fish/config.fish)
# ----------------------------------------------------------
FISH_CONFIG="$HOME/.config/fish/config.fish"
if [ -f "$FISH_CONFIG" ]; then
    if grep -q 'npm-global' "$FISH_CONFIG"; then
        log "-> PATH для npm-global уже есть в fish config.fish"
    else
        cat >> "$FISH_CONFIG" <<'EOF'

# >>> npm-global >>>
# Глобальные пакеты npm ставятся сюда (npm -g) без sudo.
if test -d "$HOME/.npm-global/bin"
    fish_add_path --prepend --global "$HOME/.npm-global/bin"
end
# <<< npm-global <<<
EOF
        log "-> PATH для npm-global добавлен в fish config.fish"
    fi
else
    mkdir -p "$HOME/.config/fish"
    cat > "$FISH_CONFIG" <<'EOF'
# >>> npm-global >>>
# Глобальные пакеты npm ставятся сюда (npm -g) без sudo.
if test -d "$HOME/.npm-global/bin"
    fish_add_path --prepend --global "$HOME/.npm-global/bin"
end
# <<< npm-global <<<
EOF
    log "-> Создан ~/.config/fish/config.fish с PATH для npm-global"
fi

# ----------------------------------------------------------
# 8. Опционально: npm@latest поверх встроенного в Node.js
# ----------------------------------------------------------
hash -r
if [ "$UPDATE_NPM" = "1" ]; then
    log "-> Обновляю npm до latest (в ~/$NPM_PREFIX_NAME)..."
    PATH="$NPM_PREFIX/bin:$PATH" npm install -g npm@latest
fi

# ----------------------------------------------------------
# 9. Проверка
# ----------------------------------------------------------
hash -r
export PATH="$NPM_PREFIX/bin:$PATH"

log ""
log "=== Готово ==="
log "node:        $(node -v)"
log "npm:         $(npm -v)"
log "npm prefix:  $(npm config get prefix)"
log ""
log "Глобальные пакеты: npm install -g <package>"
log "Бинарники:         $NPM_PREFIX/bin"
log ""
log "Открой новый терминал (или: source ~/.bashrc / exec fish),"
log "чтобы PATH подхватился в текущей сессии."

if [ -d "$HOME/.nvm/versions/node" ] && [ -n "$(ls -A "$HOME/.nvm/versions/node" 2>/dev/null)" ]; then
    log ""
    log "WARNING: в ~/.nvm есть версии Node. nvm.sh в ~/.bashrc может"
    log "         переопределить node/npm из NodeSource. Проверь: which node"
fi
