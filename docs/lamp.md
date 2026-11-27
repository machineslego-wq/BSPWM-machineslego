# install-lamp.sh — локальный веб-стек

Apache + PHP (`mod_php`) + MariaDB + phpMyAdmin для локальной разработки.
Пакеты — `requirements/lamp.txt`, ставит `scripts/install-lamp.sh`.

## Запуск

```bash
./scripts/install-lamp.sh
./scripts/install-lamp.sh --password 'dev'     # свои пароли на обе учётки
./scripts/install-lamp.sh --reset-passwords    # сгенерировать новые
./scripts/install-lamp.sh --show-passwords     # показать сохранённые
```

Запускать от обычного пользователя: `sudo` скрипт вызывает сам.
Скрипт идемпотентен — повторный запуск сохраняет базы и пароли.

## Учётки

| Пользователь | Пароль | Права |
|---|---|---|
| `devadmin` | случайный / свой | полные на `*.*` (локальная разработка) |
| `project` | случайный / свой | только базы `project_*`, может создавать их по маске |

## Пароли

- Генерируются `openssl rand` при первом запуске и **печатаются в конце**.
- Хранятся в `~/.config/webstack/credentials` (`chmod 600`, в git не попадают).
- Свои: `--password '...'` — только `A-Z a-z 0-9 . _ -`.
- Посмотреть позже: `./scripts/install-lamp.sh --show-passwords`.

## Что настраивается

- MariaDB слушает только `127.0.0.1`; анонимные пользователи и база `test` удаляются.
- Apache: `mod_rewrite`, `mod_headers`; phpMyAdmin по адресу `http://localhost/phpmyadmin`.
- phpMyAdmin ставится с `dbconfig-install=false` и cookie-auth — входить учётками выше.
- Страницы Apache по умолчанию — `http://localhost`.

## Проверка

```bash
systemctl status apache2 mariadb
mysql -u devadmin -p -h 127.0.0.1 -e 'SELECT 1'
curl -I http://localhost/phpmyadmin/
tail -f /var/log/apache2/error.log
```

## Ограничения

- Доступ только с этой машины: MariaDB — loopback, Apache — localhost.
- phpMyAdmin без TLS — это локальный инструмент, не выставлять наружу.
- `project` не может трогать базы вне `project_*`. Если MariaDB откажется создавать базу по маске — сообщить, грант поправим.
