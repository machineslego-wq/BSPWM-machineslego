# kde-migrate — обратимая миграция GNOME → KDE Plasma

Ставит **стоковую KDE Plasma** на Debian 13, переводит вход на SDDM и убирает
GNOME. Не трогает не-DE софт (GIMP, Inkscape, LibreOffice, OBS, Krita, …),
дотфайлы и репозиторий. Любой шаг можно откатить.

Команда: `local/bin/kde-migrate` (после `link.sh` — `~/.local/bin/kde-migrate`).
Эта документация рядом с командой не линкуется и не исполняется.

## Что делает

| Шаг | Действие |
|---|---|
| `install` | ставит Plasma (Wayland + X11), модули сети/звука/питания, Dolphin, Kate, Konsole, Spectacle, Ark, Gwenview, Okular, KCalc, KFind, портал KDE |
| `switch-dm` | ставит SDDM с темой Breeze и делает его менеджером входа |
| `remove-gnome` | удаляет шелл, сессию, настройки, приложения GNOME, расширения и `gdm3` |
| `finalize` | `switch-dm` + `remove-gnome` одним вызовом |
| `rollback` | возвращает GDM и GNOME из снимка, удаляет Plasma |

## Чего не делает

- **Не меняет дотфайлы.** Ни `~/BSPWM-machineslego`, ни симлинки, ни
  `~/.config/gtk-*`, ни `~/.xprofile`. `verify` сравнивает git-статус с исходным.
- **Не настраивает Plasma.** Не создаёт `kdeglobals`, `kwinrc`, обои, панель,
  цветовую схему. Первый вход — как после чистой установки: Breeze Dark,
  стоковая панель, стоковые обои.
- **Не ставит и не удаляет не-DE софт.** Krita, GIMP, Inkscape, LibreOffice,
  OBS, VLC, Firefox, Thunar не входят ни в один набор удаления.
  Если Krita ещё не стоит — скрипт её и не поставит.
- **Не трогает Sway/BSPWM.** Обе сессии остаются в списке SDDM.
- **Не делает `purge`.** Конфиги GNOME в `/home` остаются, откат их возвращает.
- **Не запускает `autoremove` молча.** Список показывается, удаление — только
  после подтверждения.

## Требования

- Debian 13 (trixie), root через `sudo`.
- Сеть: репозиторий Debian (для установки и для отката).
- Свободно на `/`: ~3 ГБ (Plasma — около 330 пакетов).
- Снимок состояния — **до** миграции (делается командой `snapshot`).

## Быстрый старт

```bash
kde-migrate status          # посмотреть, что установлено
kde-migrate snapshot        # снимок (один раз, до миграции)

# 1. Plasma, GNOME и GDM пока живы
sudo ~/.local/bin/kde-migrate install --apply --yes

# 2. Выйти и войти в Plasma (Wayland) через GDM, проверить систему
# 3. Из терминала в Plasma:
sudo ~/.local/bin/kde-migrate finalize --apply --yes

sudo reboot                 # вход уже через SDDM
```

Если Plasma уже проверена и нужен один проход:

```bash
sudo ~/.local/bin/kde-migrate install --apply --yes
sudo ~/.local/bin/kde-migrate finalize --apply --yes
```

`finalize` можно запускать из Plasma или Sway, но **не из GNOME**: скрипт
проверит активную сессию и откажется.

Под `sudo` PATH урезан (`secure_path`), поэтому в примерах указан полный путь
`~/.local/bin/kde-migrate`. Без `sudo` команда доступна просто как `kde-migrate`.

`switch-dm` не перезапускает графическую сессию: SDDM включится при следующем
входе или перезагрузке. Не делай `systemctl restart display-manager` из-под
Sway/Plasma — это завершит текущую сессию.

## Команды

| Команда | Root | Что делает |
|---|---|---|
| `status` | нет | DE, DM, сессии, сколько пакетов из наборов установлено, защищённый софт, место на `/`, чистоту репозитория |
| `snapshot` | нет | снимок пакетов, manual/auto-флагов, DM, сессий, списка GNOME и git-статуса |
| `install` | да, с `--apply` | установка Plasma **без** SDDM и без удаления GNOME |
| `switch-dm` | да, с `--apply` | SDDM + тема Breeze, `gdm3` выключается, но остаётся установленным |
| `remove-gnome` | да, с `--apply` | удаление набора GNOME; требует, чтобы DM уже был SDDM |
| `finalize` | да, с `--apply` | `switch-dm`, затем `remove-gnome` |
| `rollback` | да, с `--apply` | GDM → удаление Plasma → установка GNOME из снимка |
| `verify` | нет | DM, сессии, наличие GNOME/Plasma, защищённый софт, изменения в репозитории |

## Флаги

| Флаг | Где работает | Смысл |
|---|---|---|
| *(без флагов)* | все | **dry-run**: печатает план, ничего не меняет |
| `--apply` | `install`, `switch-dm`, `remove-gnome`, `finalize`, `rollback` | реально выполнить изменения |
| `--yes`, `-y` | там же | не задавать вопрос «продолжить?» |
| `--force` | `snapshot` | перезаписать существующий снимок |
| `--dry-run`, `-n` | все | явный dry-run; сбрасывает ранее указанный `--apply` |
| `-h`, `--help` | все | справка |

Правила:

- Флаги пишутся **после** команды: `kde-migrate install --apply --yes`.
- `--apply` без root для изменяющих команд даёт ошибку — нужен `sudo`.
- `snapshot` без `--force` откажется перезаписывать снимок: он нужен для отката.
- `--dry-run` полезен, чтобы увидеть список пакетов перед запуском.
- `--yes` отключает только вопросы «продолжить?». Проверки безопасности
  (DM, активная GNOME-сессия, защищённые пакеты) всё равно выполняются.

Примеры:

```bash
kde-migrate install                 # план установки, без изменений
kde-migrate install --dry-run       # то же самое, явно
sudo ~/.local/bin/kde-migrate install --apply          # спросит подтверждение
sudo ~/.local/bin/kde-migrate install --apply --yes    # без вопросов
kde-migrate snapshot --force        # переснять снимок (только до миграции)
```

## Снимок состояния

Путь: `~/.local/state/kde-migrate/state/`

| Файл | Что внутри |
|---|---|
| `dpkg-selections.txt` | полный `dpkg --get-selections` |
| `manual.txt`, `auto.txt` | флаги `apt-mark` до миграции |
| `gnome.txt` | установленные пакеты GNOME + расширения (по нему идёт откат) |
| `kde.txt` | что из KDE уже стояло (обычно пусто) |
| `display-manager.txt`, `default-display-manager.txt` | прежний DM |
| `sessions.txt` | список сессий |
| `repo-status-before.txt` | git-статус отслеживаемых файлов до миграции |
| `timestamp` | время снимка |

Снимок делается **один раз до миграции**. Повторно — только `snapshot --force`.
Откат без снимка невозможен: `rollback` проверит `gnome.txt` и откажется.

## Что где менять в скрипте

Все наборы — массивы в начале `local/bin/kde-migrate`:

| Массив | Что добавлять |
|---|---|
| `KDE_PKGS` | пакеты Plasma и KDE-приложения, которые ставит `install` |
| `SDDM_PKGS` | SDDM, темы, KCM |
| `GNOME_PKGS` | пакеты GNOME, которые удаляет `remove-gnome` |
| `PROTECTED` | не-DE пакеты, которые запрещено удалять (GIMP, Krita, …) |

Правила:

- Нужен новый KDE-компонент в миграции — добавь его в `KDE_PKGS`
  (он же будет удалён при откате).
- Нужно защитить приложение — добавь имя пакета в `PROTECTED`.
  Само по себе это почти не требуется: всё, что помечено `manual` и не входит
  в наборы DE, и так защищено. `PROTECTED` страхует пакеты, которые могли быть
  установлены как зависимость.
- Пакет GNOME, который надо удалить, — в `GNOME_PKGS`. Если это приложение
  с зависимостями, apt сам удалит их как обратные зависимости; проверка
  в `guard_remove` не даст задеть не-DE пакеты.
- Не добавляй не-DE приложения в `KDE_PKGS`/`GNOME_PKGS`: откат их удалит.
- Флаги разбираются в блоке `while (($#))` внизу файла.
- Путь снимка — `STATE_ROOT` в начале файла.

После правки:

```bash
bash -n local/bin/kde-migrate
kde-migrate install            # dry-run
kde-migrate status
```

## Порталы, вход и окружение

Все настройки порталов лежат в репозитории, `config/xdg-desktop-portal/`
(этот каталог симлинком подключён к `~/.config/xdg-desktop-portal`):

| Файл | Для кого | Что внутри |
|---|---|---|
| `kde-portals.conf` | Plasma | `default=kde`, ScreenCast/Screenshot — `kde`, Secret — `kwallet`, Lockdown — `gtk` |
| `sway-portals.conf` | Sway | `default=gtk`, ScreenCast/Screenshot — `wlr`, Secret — `gnome-keyring` |
| `bspwm-portals.conf` | BSPWM | `default=gtk`, Secret — `gnome-keyring` |
| `gnome-portals.conf` | GNOME (только после отката) | `default=gnome`, Secret — `gnome-keyring` |
| `portals.conf` | fallback для остальных сессий | `default=gtk`, Secret — `gnome-keyring` |

xdg-desktop-portal выбирает файл по `XDG_CURRENT_DESKTOP`:
`kde-portals.conf` для KDE, `sway-portals.conf` для Sway,
`bspwm-portals.conf` для BSPWM, `gnome-portals.conf` для GNOME, иначе
`portals.conf`. Так ScreenCast больше не форсируется на `wlr` в Plasma,
а Sway получает `wlr` явно. Старый системный
`/etc/xdg/xdg-desktop-portal/kde-portals.conf` скрипт удаляет — все конфиги
должны быть в репозитории.

| Системный файл | Зачем | Удаляется откатом |
|---|---|---|
| `/etc/xdg/plasma-workspace/env/10-plasma-clean-env.sh` | сбрасывает `QT_STYLE_OVERRIDE=qt6ct` из `~/.xprofile` только внутри Plasma X11 | да |
| `/etc/sddm.conf.d/10-theme.conf` | тема входа Breeze | да |
| `/etc/X11/default-display-manager` | текущий DM | нет (перезаписывается) |
| symlink `/etc/systemd/system/display-manager.service` | sddm ↔ gdm | нет (переключается) |

`~/.xprofile` и `config/gtk-*` не меняются: GTK-приложения под Plasma
продолжают работать с твоим `gtk.css` и Adwaita-dark. Поэтому
`kde-config-gtk-style` намеренно **не** устанавливается.

Отдельно: в Plasma 6 `gmenudbusmenuproxy` (пакет `plasma-workspace`) при
каждом входе перезаписывает `~/.config/gtk-3.0/settings.ini`. Скрипт ставит
глобальную маску `systemctl --global mask plasma-gmenudbusmenuproxy.service`,
чтобы дотфайлы оставались нетронутыми. Побочный эффект — меню GTK-приложений
не экспортируются в глобальное меню Plasma; на стоковой панели его нет.

## Что будет после переезда

- Вход через SDDM (Breeze), сессии: **Plasma (Wayland)**, Plasma (X11),
  Sway, BSPWM.
- GNOME-сессий и `gdm3` нет; настройки GNOME в `/home` остались.
- Plasma — в стоковом состоянии, без тем и обоев из репозитория.
- GIMP, Inkscape, LibreOffice, OBS, VLC, Firefox, Thunar, Flatpak — на месте.
- Репозиторий и дотфайлы — без изменений.

Раскладку мониторов Plasma хранит у себя (kscreen): после первого входа
настрой один раз в System Settings → Display & Monitor. Скрипт туда не пишет,
чтобы состояние осталось стоковым.

## Откат

```bash
sudo ~/.local/bin/kde-migrate rollback --apply --yes
```

Порядок:

1. ставится и включается `gdm3` (нужна сеть);
2. удаляются пакеты Plasma и SDDM из наборов;
3. `autoremove` — только после подтверждения и проверки;
4. ставится GNOME ровно по списку `state/gnome.txt`;
5. удаляются системные файлы миграции.

Krita/GIMP и прочий не-DE софт не удаляются: они `manual` и вне наборов DE.
Настройки GNOME не purge-ились, поэтому возвращаются как были.

## Если что-то пошло не так

| Симптом | Что делать |
|---|---|
| `apt/dpkg уже занят` | дождаться `unattended-upgrades`/`apt`, проверить `fuser /var/lib/dpkg/lock-frontend` |
| `сначала switch-dm` | сначала `sudo ~/.local/bin/kde-migrate switch-dm --apply --yes`, потом `remove-gnome` |
| `ты сейчас в GNOME` | выйти и войти в Plasma (или Sway), повторить `finalize` |
| SDDM не стартует | Ctrl+Alt+F3, `systemctl status sddm`, `journalctl -u sddm`; аварийно `sudo systemctl enable --force gdm3`, затем `rollback` |
| Не показывается Plasma Wayland | в GDM/SDDM выбрать «Plasma (X11)»; проверить `ls /usr/share/wayland-sessions` |
| Откат без сети | вернуть сеть; снимок хранится локально, пакеты — в репозитории Debian |
| Хочу переснять снимок | `kde-migrate snapshot --force` (только до миграции!) |

Проверка в любой момент:

```bash
kde-migrate status
kde-migrate verify
```

`verify` также показывает, появились ли изменения в репозитории: если да —
значит, что-то писало в дотфайлы, и это надо разобрать до продолжения.
