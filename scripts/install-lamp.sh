#!/bin/bash
# ==========================================================
# install-lamp.sh — локальный веб-стек: Apache + PHP + MariaDB + phpMyAdmin
# ==========================================================
# Для локальной разработки: Apache на localhost, MariaDB на 127.0.0.1,
# phpMyAdmin по адресу http://localhost/phpmyadmin.
#
# Две учётки БД:
#   devadmin — полные права на всё (локальная разработка);
#   project  — права только на базы с префиксом project_
#              (может создавать базы по маске).
#
# Пароли генерируются случайно и лежат в ~/.config/webstack/credentials
# (chmod 600, в git не попадает). Посмотреть их можно в любой момент:
#   scripts/install-lamp.sh --show-passwords
# Свой пароль на обе учётки: --password 'мойпароль'
#
# Использование (обычный пользователь, sudo внутри):
#   ./scripts/install-lamp.sh
#   ./scripts/install-lamp.sh --reset-passwords
#   ./scripts/install-lamp.sh --password 'dev'
#   ./scripts/install-lamp.sh --show-passwords
#
# Скрипт идемпотентен: повторный запуск не ломает существующие базы,
# пароли по умолчанию переиспользуются из файла.
# ==========================================================

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CRED_DIR="$HOME/.config/webstack"
CRED_FILE="$CRED_DIR/credentials"
LAMP_PKGS="$DOTFILES/requirements/lamp.txt"

SHOW=0
RESET=0
PASSWORD=""

usage() {
    sed -n '2,30p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
}

while (($#)); do
    case "$1" in
        --show-passwords) SHOW=1 ;;
        --reset-passwords) RESET=1 ;;
        --password)
            shift
            PASSWORD="${1:-}"
            [[ -n $PASSWORD ]] || { echo "Error: --password требует значение." >&2; exit 1; }
            ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Error: неизвестный аргумент: $1" >&2; usage >&2; exit 1 ;;
    esac
    shift
done

# --- Показать пароли без sudo ---
if ((SHOW)); then
    if [[ ! -f $CRED_FILE ]]; then
        echo "Нет $CRED_FILE — сначала запусти scripts/install-lamp.sh" >&2
        exit 1
    fi
    cat "$CRED_FILE"
    exit 0
fi

if [[ $(id -u) -eq 0 ]]; then
    echo "Error: запусти от обычного пользователя (sudo используется внутри)." >&2
    exit 1
fi

if [[ ! -f /etc/debian_version ]]; then
    echo "Error: скрипт рассчитан на Debian." >&2
    exit 1
fi

if [[ -n $PASSWORD && ! $PASSWORD =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "Error: пароль может содержать только A-Z a-z 0-9 . _ -" >&2
    exit 1
fi

log() { printf '%s\n' "$*"; }

gen_pass() {
    openssl rand -base64 30 | tr -dc 'A-Za-z0-9' | cut -c1-20
}

read_cred() {
    local key="$1"
    [[ -f $CRED_FILE ]] || return 0
    grep -m1 "^$key=" "$CRED_FILE" 2>/dev/null | cut -d= -f2- || true
}

# --- Пароли: свои, из файла или новые ---
DEV_PASS=""
PROJ_PASS=""
if [[ -n $PASSWORD ]]; then
    DEV_PASS="$PASSWORD"
    PROJ_PASS="$PASSWORD"
elif [[ -f $CRED_FILE && $RESET -eq 0 ]]; then
    DEV_PASS="$(read_cred DB_DEV_PASSWORD)"
    PROJ_PASS="$(read_cred DB_PROJECT_PASSWORD)"
fi
[[ -n $DEV_PASS ]] || DEV_PASS="$(gen_pass)"
[[ -n $PROJ_PASS ]] || PROJ_PASS="$(gen_pass)"

log "=== Локальный веб-стек: Apache + PHP + MariaDB + phpMyAdmin ==="
sudo -v || { echo "Error: требуются права sudo." >&2; exit 1; }

# ----------------------------------------------------------
# 1. Пакеты
# ----------------------------------------------------------
# phpmyadmin ставим неинтерактивно: dbconfig-common не должен трогать
# существующую MariaDB и спрашивать пароль root.
sudo debconf-set-selections <<'EOF'
phpmyadmin phpmyadmin/dbconfig-install boolean false
phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2
EOF

log "-> Устанавливаю пакеты из requirements/lamp.txt..."
while IFS= read -r pkg || [[ -n $pkg ]]; do
    [[ -z $pkg || $pkg =~ ^# ]] && continue
    if dpkg -l 2>/dev/null | grep -q "^ii  $pkg "; then
        log "   уже стоит: $pkg"
    else
        log "   ставлю:    $pkg"
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
    fi
done < "$LAMP_PKGS"

# ----------------------------------------------------------
# 2. MariaDB: локальный доступ и учётки
# ----------------------------------------------------------
log "-> Настраиваю MariaDB..."
sudo systemctl enable --now mariadb

# Слушать только loopback.
MDB_CONF=/etc/mysql/mariadb.conf.d/50-server.cnf
if [[ -f $MDB_CONF ]]; then
    if grep -qE '^[[:space:]]*bind-address' "$MDB_CONF"; then
        sudo sed -i -E 's/^[[:space:]]*bind-address.*/bind-address = 127.0.0.1/' "$MDB_CONF"
    else
        sudo sed -i '/^\[mysqld\]/a bind-address = 127.0.0.1' "$MDB_CONF"
    fi
    sudo systemctl restart mariadb
fi

sudo mariadb <<SQL
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.global_priv WHERE User='';

CREATE USER IF NOT EXISTS 'devadmin'@'localhost' IDENTIFIED BY '${DEV_PASS}';
ALTER USER 'devadmin'@'localhost' IDENTIFIED BY '${DEV_PASS}';
GRANT ALL PRIVILEGES ON *.* TO 'devadmin'@'localhost' WITH GRANT OPTION;

CREATE USER IF NOT EXISTS 'project'@'localhost' IDENTIFIED BY '${PROJ_PASS}';
ALTER USER 'project'@'localhost' IDENTIFIED BY '${PROJ_PASS}';
GRANT ALL PRIVILEGES ON \`project\\_%\`.* TO 'project'@'localhost';
FLUSH PRIVILEGES;
SQL

# ----------------------------------------------------------
# 3. Apache и phpMyAdmin
# ----------------------------------------------------------
log "-> Настраиваю Apache..."
sudo a2enmod rewrite headers >/dev/null
sudo a2enconf phpmyadmin >/dev/null
sudo systemctl enable --now apache2
sudo apache2ctl configtest
sudo systemctl reload apache2

# ----------------------------------------------------------
# 4. Файл с паролями (только для пользователя)
# ----------------------------------------------------------
log "-> Записываю пароли в $CRED_FILE..."
install -d -m 700 "$CRED_DIR"
(
    umask 077
    cat > "$CRED_FILE" <<EOF
# Локальный веб-стек (scripts/install-lamp.sh)
# Пароли можно посмотреть: scripts/install-lamp.sh --show-passwords
DB_HOST=127.0.0.1
DB_DEV_USER=devadmin
DB_DEV_PASSWORD=$DEV_PASS
DB_PROJECT_USER=project
DB_PROJECT_PASSWORD=$PROJ_PASS
PHPMYADMIN_URL=http://localhost/phpmyadmin
EOF
)
chmod 600 "$CRED_FILE"

# ----------------------------------------------------------
# 5. Итог
# ----------------------------------------------------------
PHP_VER="$(php -r 'echo PHP_VERSION;' 2>/dev/null || echo '?')"
HTTP_CODE="$(curl -s -o /dev/null -w '%{http_code}' http://localhost/phpmyadmin/ 2>/dev/null || true)"

log ""
log "=== Готово ==="
log "  Apache:      http://localhost (только localhost)"
log "  phpMyAdmin:  http://localhost/phpmyadmin (код $HTTP_CODE)"
log "  PHP:         $PHP_VER (mod_php)"
log "  MariaDB:     127.0.0.1"
log ""
log "  devadmin / $DEV_PASS   — полные права (локальная разработка)"
log "  project  / $PROJ_PASS  — только базы project_*"
log ""
log "  Пароли сохранены: $CRED_FILE"
log "  Посмотреть позже: scripts/install-lamp.sh --show-passwords"
log "  Свои пароли:      scripts/install-lamp.sh --password '...'"
log "  Перегенерировать: scripts/install-lamp.sh --reset-passwords"
