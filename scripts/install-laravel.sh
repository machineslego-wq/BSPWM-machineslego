#!/bin/bash
# ==========================================================
# install-laravel.sh — PHP + Composer + Laravel installer (PATH)
# ==========================================================
# Зачем: `composer global require laravel/installer` кладёт
# бинарник `laravel` в глобальный bin Composer —
# ~/.config/composer/vendor/bin, — которого обычно нет в PATH.
# После установки команда `laravel` не находится, пока этот
# каталог не добавить в PATH. Скрипт ставит PHP и расширения из
# Debian, Composer 2 (если его нет), laravel/installer глобально
# и прописывает bin-каталог Composer в PATH для bash и fish.
#
# Использование (запускать от обычного пользователя, sudo — внутри):
#   ./scripts/install-laravel.sh
#   UPDATE_COMPOSER=1 ./scripts/install-laravel.sh   # переустановить Composer
#
# Скрипт идемпотентен: повторный запуск ничего не ломает.
# ==========================================================

set -euo pipefail

UPDATE_COMPOSER="${UPDATE_COMPOSER:-0}"
LOCAL_BIN="$HOME/.local/bin"
COMPOSER_BIN="$LOCAL_BIN/composer"

if [ "$(id -u)" -eq 0 ]; then
    echo "Error: запусти скрипт от обычного пользователя (sudo используется внутри)." >&2
    exit 1
fi

if [ ! -f /etc/debian_version ]; then
    echo "Error: скрипт рассчитан на Debian." >&2
    exit 1
fi

log() { printf '%s\n' "$*"; }

log "=== PHP + Composer + Laravel Installer ==="

# ----------------------------------------------------------
# 1. PHP и расширения, которые нужны Laravel и Composer
# ----------------------------------------------------------
# php-cli тянет ctype, fileinfo, filter, hash, openssl, pcre,
# pdo, session, tokenizer; остальное — отдельными пакетами.
# unzip нужен Composer для распаковки архивов без ext-zip.
log "-> Устанавливаю PHP и расширения..."
sudo apt-get update
sudo apt-get install -y \
    php-cli php-mbstring php-xml php-curl php-zip \
    php-sqlite3 php-intl php-mysql unzip curl ca-certificates

# ----------------------------------------------------------
# 2. Проверка версии PHP: Laravel требует 8.2+
# ----------------------------------------------------------
PHP_VERSION="$(php -r 'echo PHP_VERSION;')"
if ! php -r 'exit(version_compare(PHP_VERSION, "8.2", ">=") ? 0 : 1);'; then
    log "Error: Laravel требует PHP >= 8.2, установлен $PHP_VERSION."
    exit 1
fi
log "-> PHP: $PHP_VERSION"

# ----------------------------------------------------------
# 3. Composer 2 — в ~/.local/bin, если его ещё нет
# ----------------------------------------------------------
composer_is_v2() {
    "$1" --version --no-ansi 2>/dev/null | grep -qE 'version 2\.'
}

if [ "$UPDATE_COMPOSER" != "1" ] && [ -x "$COMPOSER_BIN" ] && composer_is_v2 "$COMPOSER_BIN"; then
    composer_cmd="$COMPOSER_BIN"
    log "-> Composer уже есть: $("$composer_cmd" --version --no-ansi 2>/dev/null | head -n1)"
elif [ "$UPDATE_COMPOSER" != "1" ] && command -v composer >/dev/null 2>&1 \
        && composer_is_v2 "$(command -v composer)"; then
    composer_cmd="$(command -v composer)"
    log "-> Composer уже есть: $("$composer_cmd" --version --no-ansi 2>/dev/null | head -n1)"
else
    log "-> Устанавливаю Composer 2 в $COMPOSER_BIN..."
    mkdir -p "$LOCAL_BIN"
    TMP_SETUP="$(mktemp /tmp/composer-setup-XXXXXX.php)"
    TMP_SIG="$(mktemp /tmp/composer-sig-XXXXXX)"
    trap 'rm -f "$TMP_SETUP" "$TMP_SIG"' EXIT

    # Официальный установщик + проверка SHA-384 по свежей подписи.
    curl -fsSL https://composer.github.io/installer.sig -o "$TMP_SIG"
    curl -fsSL https://getcomposer.org/installer -o "$TMP_SETUP"
    EXPECTED_CHECKSUM="$(tr -d '[:space:]' < "$TMP_SIG")"
    ACTUAL_CHECKSUM="$(php -r 'echo hash_file("sha384", $argv[1]);' "$TMP_SETUP")"
    if [ -z "$EXPECTED_CHECKSUM" ] || [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
        log "Error: контрольная сумма установщика Composer не совпала."
        exit 1
    fi

    php "$TMP_SETUP" --install-dir="$LOCAL_BIN" --filename=composer --quiet
    composer_cmd="$COMPOSER_BIN"
    log "-> Composer: $("$composer_cmd" --version --no-ansi 2>/dev/null | head -n1)"
fi

# ----------------------------------------------------------
# 4. Куда Composer кладёт глобальные бинарники
# ----------------------------------------------------------
# По умолчанию это ~/.config/composer/vendor/bin, но COMPOSER_HOME
# или XDG_CONFIG_HOME могут изменить путь. Спрашиваем у Composer,
# а если старый Composer не умеет --absolute — считаем вручную.
BIN_DIR="$("$composer_cmd" global config bin-dir --absolute 2>/dev/null | tail -n1 || true)"
if [ -z "$BIN_DIR" ]; then
    if [ -n "${COMPOSER_HOME:-}" ]; then
        composer_home="$COMPOSER_HOME"
    elif [ -n "${XDG_CONFIG_HOME:-}" ]; then
        composer_home="$XDG_CONFIG_HOME/composer"
    else
        composer_home="$HOME/.config/composer"
    fi
    BIN_DIR="$composer_home/vendor/bin"
fi

# ----------------------------------------------------------
# 5. Ставим Laravel installer глобально
# ----------------------------------------------------------
log "-> Ставлю laravel/installer в $BIN_DIR..."
"$composer_cmd" global require laravel/installer --no-interaction --no-progress

# ----------------------------------------------------------
# 6. PATH для bash (~/.bashrc)
# ----------------------------------------------------------
# В блоке используем $HOME вместо абсолютного пути, чтобы файл
# оставался переносимым между машинами.
BIN_DIR_RC="$BIN_DIR"
case "$BIN_DIR" in
    "$HOME"/*) BIN_DIR_RC="\$HOME/${BIN_DIR#"$HOME"/}" ;;
esac

BASH_RC="$HOME/.bashrc"
if [ -f "$BASH_RC" ]; then
    if grep -qF "$BIN_DIR_RC" "$BASH_RC"; then
        log "-> PATH для Composer уже есть в ~/.bashrc"
    else
        cat >> "$BASH_RC" <<EOF

# >>> composer-global >>>
# Глобальные пакеты Composer (laravel/installer) — без sudo.
if [[ -d "$BIN_DIR_RC" && ":\$PATH:" != *":$BIN_DIR_RC:"* ]]; then
    PATH="$BIN_DIR_RC:\$PATH"
fi
# <<< composer-global <<<
EOF
        log "-> PATH для Composer добавлен в ~/.bashrc"
    fi
else
    log "WARNING: ~/.bashrc не найден — PATH для Composer не добавлен."
fi

# ----------------------------------------------------------
# 7. PATH для fish (~/.config/fish/config.fish)
# ----------------------------------------------------------
FISH_CONFIG="$HOME/.config/fish/config.fish"
if [ -f "$FISH_CONFIG" ]; then
    if grep -qF "$BIN_DIR_RC" "$FISH_CONFIG"; then
        log "-> PATH для Composer уже есть в fish config.fish"
    else
        cat >> "$FISH_CONFIG" <<EOF

# >>> composer-global >>>
# Глобальные пакеты Composer (laravel/installer) — без sudo.
if test -d "$BIN_DIR_RC"
    fish_add_path --prepend --global "$BIN_DIR_RC"
end
# <<< composer-global <<<
EOF
        log "-> PATH для Composer добавлен в fish config.fish"
    fi
else
    mkdir -p "$HOME/.config/fish"
    cat > "$FISH_CONFIG" <<EOF
# >>> composer-global >>>
# Глобальные пакеты Composer (laravel/installer) — без sudo.
if test -d "$BIN_DIR_RC"
    fish_add_path --prepend --global "$BIN_DIR_RC"
end
# <<< composer-global <<<
EOF
    log "-> Создан ~/.config/fish/config.fish с PATH для Composer"
fi

# ----------------------------------------------------------
# 8. Проверка
# ----------------------------------------------------------
hash -r
export PATH="$BIN_DIR:$PATH"

if ! command -v laravel >/dev/null 2>&1; then
    log "Error: laravel не найдена в PATH. Ожидался каталог: $BIN_DIR"
    exit 1
fi

log ""
log "=== Готово ==="
log "php:         $PHP_VERSION"
log "composer:    $("$composer_cmd" --version --no-ansi 2>/dev/null | head -n1)"
log "laravel:     $(laravel --version | head -n1)"
log "bin Composer: $BIN_DIR"
log ""
log "Новый проект: laravel new <name>"
log "Альтернатива: composer create-project laravel/laravel <name>"
log ""
log "Открой новый терминал (или: source ~/.bashrc / exec fish),"
log "чтобы PATH подхватился в текущей сессии."
