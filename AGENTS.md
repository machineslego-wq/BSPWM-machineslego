# AGENTS.md

**Коротко.** Дотфайлы и установщик окружения для Debian 13 (Trixie): **BSPWM/X11** — рабочая и запасная сессия, **Sway/Wayland** — направление переезда. Тема одна — Tokyo Night. «Продукт» — конфиги и shell-скрипты; сборки, тестов, линтера и CI нет.

**Если ты ИИ-агент:** прочитай «Карту», «Правила» и «Что где менять», а разделы компонентов открывай только по нужному. Все пути ниже — реальные пути этого репозитория. Правка файла здесь **сразу меняет живую систему** (`~/.config/*` — симлинки), поэтому черновых правок не бывает. `install.sh` и `unlink.sh` без явной просьбы не запускать.

## Карта репозитория

| Путь | Что это | Куда попадает |
|---|---|---|
| `config/<pkg>/` | конфиг приложения | симлинк `~/.config/<pkg>` |
| `home/<file>` | файл домашнего каталога | симлинк `~/.<file>` |
| `local/bin/<cmd>` | команда в PATH | симлинк `~/.local/bin/<cmd>` |
| `local/share/mc/skins/*.ini` | скины Midnight Commander | `~/.local/share/mc/skins/` |
| `docs/*.md` | инструкции команд и шпаргалки | просмотр: `rice-doc <имя>` |
| `system/etc/**` | системные конфиги | копия в `/etc/**` + бэкап `/etc/dotfiles-backup-YYYYMMDD-HHMMSS` |
| `scripts/*.sh` | установка и линковка | запуск вручную |
| `requirements/*.txt` | списки пакетов | читают `scripts/*.sh` |
| `screenshots/`, `wallpapers/`, `themes/` | картинки для README, темы Telegram | — |
| `README.md`, `README.ru.md` | публичная документация; раздел «Ядро проекта» — минимальный набор дотфайлов, без которого сессия и райс не работают | — |
| `DEVICES.md` | железо, мониторы и ветки конфигов трёх машин (внутренний справочник) | — |
| `TODO.md` | блокнот: план, «Отвергнуто», ограничения | — |
| `RELEASE.md` | заметки только к текущему релизу | — |

`config/` содержит: `alacritty`, `bash`, `bspwm`, `btop`, `cava`, `copyq`, `dunst`, `easyeffects`, `fastfetch`, `fish`, `foot`, `GIMP`, `gtk-3.0`, `gtk-4.0`, `mako`, `newt`, `nvim`, `picom`, `polybar`, `qt5ct`, `qt6ct`, `quickshell`, `rofi`, `swappy`, `sway`, `swaylock`, `sxhkd`, `waybar`, `wofi`, `xdg-desktop-portal`.

## Что где менять

| Задача | Файлы |
|---|---|
| Хоткей BSPWM | `config/sxhkd/sxhkdrc` + строка в `local/bin/cheatsheet-bspwm` |
| Хоткей Sway | `config/sway/config` + строка в `local/bin/sway-cheatsheet` |
| Панель BSPWM | `config/polybar/config.ini`, `config/polybar/launch.sh` |
| Панель Sway | `config/waybar/config.jsonc`, `config/waybar/style.css` |
| Лаунчер и меню X11 | `config/rofi/config.rasi`, `local/bin/{battery,powermenu,wifi,power-profile,dunst-history}` |
| Лаунчер и меню Wayland | `config/wofi`, `local/bin/{wofi-clipboard,wifi,battery,powermenu}`; `config/rofi` — запасной (BSPWM) |
| Уведомления | `config/dunst/dunstrc` (X11), `config/mako/config` (Sway) |
| Тема GTK / Qt | `config/gtk-3.0`, `config/gtk-4.0`, `config/qt5ct`, `config/qt6ct` |
| Терминалы | `config/foot/foot.ini` (Sway, по умолчанию); `config/alacritty/alacritty.toml` (BSPWM и запасной) |
| Редакторы | `config/nvim/`, `home/vimrc` |
| Пакеты | `requirements/apt.txt` (база X11), `sway.txt` (Sway, поверх базы), `apt-system.txt` (системное), `software.txt` (опциональное) |
| Установка и линковка | `scripts/install.sh`, `link.sh`, `unlink.sh`, `software.sh`, `install-node.sh`, `install-laravel.sh`, `install-sway.sh` |
| Системные правки | `system/etc/**` |

**Пакеты называются не как команды:** `nmtui`/`nmcli` → `network-manager`, `bluetoothctl` → `bluez`, `wpctl` → `wireplumber`, `powerprofilesctl` → `power-profiles-daemon`, `lspci` → `pciutils`, `notify-send` → `libnotify-bin`. Отдельного пакета `network-manager-tui` не существует. Neovim AppImage требует `libfuse2t64`.

`link.sh` перед заменой файлов делает бэкап в `~/.dotfiles-backup-*`; `system/**` — в `/etc/dotfiles-backup-*`.

## Правила

- **Стоковый модуль вместо скрипта.** Скрипт появляется только там, где без него нельзя: запускается по требованию и сразу завершается. Никаких фоновых циклов и мёртвого кода.
- Перед новой фичей — `TODO.md`, раздел «Отвергнуто». Без явной просьбы не возвращать: темы/прозрачность, выборщик обоев, авто-темы, автогенерацию GTK-темы.
- **Персонализацию не обобщать молча:** hostname, имена мониторов и Wi-Fi интерфейсов, пути к обоям (см. «Персонализация»).
- **Палитра — сборник, а не сток.** Большинство цветов — Tokyo Night (Night/Storm/Moon/Day), но фоновая лестница и часть производных оттенков свои. Оранжевый `#ff9e64` в Telegram и Obsidian — осознанный контраст, в системе акцент синий `#7aa2f7` (глаза). Не «исправлять» это на сток без явной просьбы. Подробности — `docs/themes.md`.
- Новая команда: `local/bin/<имя>` без расширения, с шебангом, `chmod +x`. **Третья строка файла** — описание: её читает `rice-help`. Документация — `docs/*.md`, смотреть `rice-doc <имя>`; в `local/bin` файлов `*.md` не держим.
- Документация на русском. `README.md` и `README.ru.md` обновляются одновременно. `RELEASE.md` — только текущий релиз, не история.
- Не трогать: чужие файлы в `~/.local/bin` (`nvim`, `tree-sitter`, `zed`), сгенерированное Fish/Tide (`fish_variables`, `conf.d/_tide_*.fish`, `functions/`, `completions/`), `~/.dotfiles-backup-*`, истории и логи.
- `.gitignore` — whitelist: новый файл/папка в корне не попадёт в git, пока не добавлен в исключения.
- Тег и `git push` — только по явной просьбе. Ветка одна — `main`.

## Проверка

| Что | Как |
|---|---|
| Симлинки, команды из `sxhkdrc`, `bash -n`, картинки README | `rice-check` (код возврата 0/1) |
| Синтаксис любого скрипта | `bash -n <файл>` |
| Конфиг Sway | `sway -C -c config/sway/config` |
| Mako | `timeout 3 dbus-run-session -- mako --config config/mako/config` (пусто = ok) |
| Foot | `foot -C -c config/foot/foot.ini` |
| Остальные конфиги | перезапуск компонента (таблица ниже) |

Перед завершением — `git status`: ничего сгенерированного и никаких бэкапов в коммит.

## Применение изменений

| Компонент | Как |
|---|---|
| BSPWM | `bspc wm -r` / `Super + Alt + R` |
| SXHKD | `pkill -USR1 -x sxhkd` / `Super + Escape` |
| Polybar | `~/.config/polybar/launch.sh` |
| Picom | `pkill -x picom; picom --config <профиль>` |
| Sway | `swaymsg reload` / `Super + Escape` |
| Waybar | CSS сам (`reload_style_on_change`); `config.jsonc` — `pkill -x waybar; waybar &` |
| Mako | `pkill -HUP -x mako` |
| Neovim | следующий запуск (или `:source %` для текущего файла) |
| Vim | `:source ~/.vimrc` |
| GTK / Qt | перезапуск приложения (Qt: `qt5ct` / `qt6ct`) |
| Полный перезапуск BSPWM-сессии | `session-restart` / `Super + Alt + Shift + R` |

Picom выбирает профиль по `powerprofilesctl get`: `power-saver` → `picom-eco.conf`, иначе → `picom.conf`.

## BSPWM / X11

- `config/sxhkd/sxhkdrc`: команда под хоткеем — отступ ровно 4 пробела (не табы), комментарии только отдельной строкой, brace-раскладка `super + {a,b}` работает.
- `config/picom/*.conf`: унарный минус не парсится — писать `"0 - window-height"`. `dim-spec` у `dim` задаёт непрозрачность неактивных окон.
- `config/polybar/config.ini`: `internal/*` там, где есть сток; исключение — `[module/bluetooth]` на `custom/script`: в Polybar 3.7 нет `internal/bluetooth`. `launch.sh` экспортирует `POLYBAR_BAT` / `POLYBAR_AC` / `POLYBAR_BACKLIGHT` — не хардкодить имена. Фон «пилюль» — `bg-mid = #1f2335`, иконки требуют JetBrainsMono Nerd Font.
- Bluetooth в Polybar — `custom/script` с `local/bin/bluetooth`: `󰂲 OFF` / `󰂯 ON` / `󰂱 N` (N подключённых), ЛКМ `bluetooth on`, ПКМ `bluetooth off`. Опрос раз в 5 с: `bluetoothctl show` ~4 мс.
- Если адаптер залочен (`bluetoothctl show` → `PowerState: off-blocked`), `bluetoothctl power on` возвращает ошибку: `local/bin/unblock-bt` снимает rfkill-блок (`sudo` в терминале, `pkexec` из хоткея) и включает адаптер.
- `config/rofi/config.rasi`: размеры только в `em` (не `%`), чтобы меню не зависело от монитора. `em` считается от шрифта `JetBrainsMono Nerd Font 10` (18 px). Ширины: launcher 36em, battery 24em, wifi 24em (все меню), power-profile 20em, powermenu 17em, cheatsheet 62×36em (по самой длинной строке с тегами), dunst-history 40×24em. Высота: `fixed-height: true`, общий список 8 строк; в `dmenu` число строк передаётся по числу пунктов: `wifi` 5 (список сетей — до 12), `battery` — по числу строк upower, `powermenu` 4, `power-profile` 3; на Hyprland/XWayland без `fixed-height` dmenu схлопывается до строки ввода. В `cheatsheet-bspwm` теги строк — цвет фона `#1a1b26`: практически не видны, но участвуют в поиске.
- `local/bin/session-restart` перезапускает sxhkd, polybar, picom, dunst, xss-lock, lxpolkit, copyq и делает `bspc wm -r`.
- Bluetooth: `blueman-applet` в автозапуске закомментирован, индикатор и вкл/выкл — модуль Polybar (`module/bluetooth`).
- Хоткей-«клей» живёт в `config/sxhkd/scripts/` (`flag.sh`, `to-preselect.sh`, `preselect-cancel-all.sh`): он действует на focused-окно и вне хоткея смысла не имеет.
- Из `sxhkdrc` и Polybar команды вызываются по короткому имени: PATH с `~/.local/bin` выставляют `home/xinitrc` (`startx`) и `home/xprofile`. `config/polybar/launch.sh` — часть конфига панели, а не команда.
- `bspwmrc` содержит hostname-ветки и жёсткие имена мониторов (`DisplayPort-1`, `HDMI-A-3`) — см. «Персонализация».

## Sway

- `config/sway/config`, симлинк `~/.config/sway`; `include /etc/sway/config.d/*` остаётся абсолютным. Стоковый `bar {}` удалён — панель рисует waybar.
- Оформление: `default_border pixel 2` и `default_floating_border pixel 2` (заголовков нет), `gaps inner/outer 0`, `smart_borders on`. В режиме `pixel` рамку рисует `child_border`, поэтому он продублирован в каждом `client.*`. `client.focused #6b8dd6`, `client.unfocused`/`focused_inactive` — `#1a1b26`.
- **Все `bindsym` — с `--to-code`.** Без флага keysym привязан к текущей раскладке и в RU-режиме не срабатывает.
- Раскладка `us,ru` + `grp:caps_toggle`, автоповтор 250/30 — через `input "type:keyboard"`; тачпад — `tap`, `dwt`, `natural_scroll enabled`.
- `local/bin/sway-session` — обёртка вместо `sway`: PATH, `XDG_*`, курсор Bibata 24, Qt (платформенная тема `kde` из `kdeglobals`, без Plasma — фолбэк `qt6ct`; `QT_QPA_PLATFORM="wayland;xcb"`), GTK (`GDK_BACKEND=wayland,x11`), `SAL_USE_VCLPLUGIN=gtk3`, `MOZ_ENABLE_WAYLAND`, Electron, Java; перед запуском пишет карту столов в `~/.cache/sway/workspaces.conf` (ПК — 1–7 → `DP-2`, 8–10 → `HDMI-A-4`; ноутбук/нетбук — пустой файл), её подключает `config/sway/config`; затем `exec sway "$@"`. Карта нужна до старта: `workspace <n> output <выход>` действует только на ещё не созданные столы. `home/xinitrc`/`xprofile` под Wayland не выполняются.
- `local/bin/sway-display` — мониторы, геометрия и обои; вызывается как `exec_always`. Hostname-условие в конфиге Sway одно — автозапуск OpenRGB (повторяет `bspwmrc`); мониторы ветвятся в скрипте: ветка `lamer-deb` (`DP-2` + `HDMI-A-4` с `transform 90`) и фолбэк ноутбука живут здесь. Привязку столов см. в `sway-session`; `exec swaymsg workspace number 1` в конфиге задаёт стартовый фокус и при reload не повторяется. Имена выходов wlroots ≠ X11: `DisplayPort-1`/`HDMI-A-3` → `DP-2`/`HDMI-A-4`. Обои ставит сам Sway через `output ... bg`.
- Автозапуск — `exec_always pgrep -x <имя> >/dev/null || <имя>` для waybar, mako, lxpolkit: reload не плодит дубли. `swayidle`: 10 минут и `before-sleep` → `swaylock -f`. `wl-paste --watch cliphist -max-items 100 store` — под таким же стражем. EasyEffects — обычный `exec` (при reload не повторяется).
- Хоткеи: `$mod+Return` foot, `$mod+d` `wofi --show drun`, `$mod+/` `sway-cheatsheet wofi`, `$mod+F1`/`$mod+F3`/`$mod+F4`/`$mod+Shift+S` скриншоты, `$mod+Shift+A` редактор, `$mod+Shift+R` запись всего экрана, `$mod+Shift+Alt+R` области, `$mod+Shift+V` `wofi-clipboard`, `$mod+Escape`/`$mod+Shift+C` reload, `$mod+w` kill, `$mod+Alt+L` lock, `$mod+Alt+N` `wifi wofi`, `$mod+Alt+B` `battery wofi`, `$mod+Shift+Q` `powermenu wofi`, `$mod+Shift+E` `swaynag`. Полный список — `sway-cheatsheet`. Профиль питания переключается кликом по модулю PPD в waybar (отдельного меню нет).

- `local/bin/wifi {rofi|wofi}` — один скрипт на обе сессии: `rofi` в BSPWM, `wofi` в Sway; пароль спрашивается в `foot` (Wayland) или `alacritty` (X11). Список сетей — `󰤨 | SSID` (иконка из `signal_icon`, `nmcli -t --escape no -f SIGNAL,SSID` + `read` с `IFS=:`; SSID — весь остаток после первого `:`, при выборе `${SSID#*| }` срезает иконку и разделитель); адаптер выбирает `nmcli`; хотспот выключается `nmcli connection down Hotspot`.

- `local/bin/battery {rofi|wofi}` — детали батареи из `upower` (заряд, статус, потребление, здоровье, время); `wofi` в Sway, `rofi` в BSPWM. Батарея выбирается `battery_BAT*`, иначе первая `/battery_` — иначе с беспроводной мышью в меню попадает её батарея.
- `local/bin/powermenu {rofi|wofi}` — один список действий: блокировка (`i3lock-fancy`/`swaylock`), выключение, выход (`bspc quit`/`swaymsg exit`), перезагрузка. Бэкенд меню и сессия независимы: блокировку и выход скрипт выбирает по `XDG_CURRENT_DESKTOP`, а `SWAYSOCK` — только если сокет жив (`-S`), поэтому `powermenu rofi` работает и в Sway, и в BSPWM, и в GNOME с устаревшим `SWAYSOCK`.

### Порталы (OBS, ScreenCast)

1. Переменные Sway должны попасть в systemd/dbus: в конфиге есть `dbus-update-activation-environment --systemd --all`, но `GDK_BACKEND` и `I3SOCK` из экспорта исключены (`env -u`): с `GDK_BACKEND=wayland,x11` `xdg-desktop-portal-gnome` в следующей GNOME-сессии пишет «Non-compatible display server» и отдаёт только настройки. Проверка: `systemctl --user show-environment | grep WAYLAND_DISPLAY`.
2. `config/xdg-desktop-portal/sway-portals.conf`: `default=gtk`, а `ScreenCast`/`Screenshot` — `wlr` (hyprland-портал тоже заявляет `sway`, поэтому выбор явный). `default=wlr` нельзя: остальные функции отвалятся. У GNOME свой `gnome-portals.conf` (`default=gnome`), у BSPWM — `bspwm-portals.conf` (`default=gtk`).
3. OBS запускать с `QT_QPA_PLATFORM="wayland;xcb"` (как в `sway-session`), иначе он уйдёт в XWayland.
4. `slurp` нужен порталу для выбора монитора; он в `requirements/sway.txt`.
5. Смена сессии ломает порталы: generic `xdg-desktop-portal` читает `<desktop>-portals.conf` один раз при старте и остаётся с конфигом прошлой сессии. `local/bin/session-cleanup` останавливает generic и все бэкенды (gtk/wlr/gnome/kde) и чистит переменные прошлой сессии в systemd: Qt-окружение, `GDK_BACKEND` (с ним `xdg-desktop-portal-gnome` пишет «Non-compatible display server» и отдаёт только настройки), `SWAYSOCK`/`I3SOCK`, `SAL_USE_VCLPLUGIN`, `MOZ_ENABLE_WAYLAND`, Electron и Java. Вызывается только из `powermenu` перед выходом (`powermenu rofi|wofi`). Вручную — `session-cleanup`.

### Скриншоты, запись, буфер

- `sway-screenshot {full|region|delayed|monitor|annotate}`: снимает `grim` (+`slurp` для области), PNG кладёт в буфер (`wl-copy`) и в `Screenshots` внутри `xdg-user-dir PICTURES` (фолбэк `~/Screenshots`). Режима `window` нет: геометрия через `jq` по дереву Sway была костыльной; в X11 `screenshot window` остался (`maim -i` в одну строку).
- `annotate` берёт картинку из буфера и открывает `swappy -f -`; экспортирует `XDG_PICTURES_DIR`, иначе `swappy` сохранит в `/Screenshots`. Если в буфере текст — уведомление и код 1.
- `sway-record {full|region}`: `wf-recorder`, повторный вызов **любого** режима останавливает запись через `pkill -INT` (mp4 закрывается только по SIGINT). Монитор передаётся явно `-o` (иначе под хоткеем `wf-recorder` молча не стартует на мультимониторе). Кодек — `libx264` всегда: VAAPI убран, на Intel он не использовался, на AMD оставался непроверенной веткой. Стороны области округляются вниз до чётных: H.264 4:2:0 не принимает нечётные. Каждое состояние — уведомление: старт, отмена `slurp`, ошибка с кодом, завершение/прерывание с кодом; внутренний `--run` пишет код в `$XDG_RUNTIME_DIR/sway-record.rc`. Звук не пишется — для этого OBS.
- Буфер: `cliphist list` → `rofi -dmenu` → `cliphist decode <id> | wl-copy` (`rofi-clipboard`, `Super+Shift+V`; `wofi-clipboard` оставлен как запасной). Хранится 100 записей (`-max-items 100` — до подкоманды `store`). Под Wayland CopyQ не используется.

### Waybar

- `style.css`: палитра только через `@define-color` в начале файла, в правилах — `@имя`. `:root`/`var()` GTK-CSS не понимает. Группа `group/left` в CSS — **`#left`**, без префикса.
- Формат модуля допускает **один** плейсхолдер: `"{:L%H:%M  󰃭 %a, %d %b}"`. Локализация — `"locale": "ru_RU.UTF-8"` у модуля (префикс `L` внутри спецификатора).
- `keyboard-state` читает `/dev/input/event*` через libevdev: пользователь должен быть в группе `input` (её выдаёт `install-sway.sh`), иначе индикаторы Caps/Num/Scroll пустые.
- Звук — `wpctl` (WirePlumber; `pactl` в системе нет). Сеть — `network`: ЛКМ `nm-connection-editor`, ПКМ `wifi rofi`. Трей `icon-size: 16`, островки — `@bg-alt`, панель непрозрачная.

### Wofi (лаунчер Sway)

- Лаунчер Sway — `wofi`; `config/rofi` остаётся в BSPWM и как запасной. `config/wofi/config` + `style.css` оформлены 1:1 с rofi: фон `#1a1b26`, поле и рамка `#24283b`, радиус 5 (как у панелей), поля и строк 8, выбранная строка — акцент. Окно 648×419 (36em × 8 строк) по центру, `no_actions=true`, `layer=overlay`.
- Wofi `width`/`height` — это содержимое без border 4 px. Launcher — 644×415; меню: wifi/battery 428, powermenu 302, clipboard 788, cheatsheet 1112×644. Высота меню — `79 + 42*строк` (поле ввода + отступы + строка), border +4; скрипты считают её сами, `--lines` не используется.
- `dynamic_lines=false` — окно не сжимается при поиске. Поиск как `rofi -dmenu -i`: `matching=contains`, `insensitive=true`, `sort_order=default`, `filter_rate=40`; `fuzzy` пересортировывал список — не возвращать.
- Видимый фон рисует **`#outer-box`**, но у toplevel-окна GTK есть свой `.background` (#1a1b26): из-за скругления он просвечивает в углах. В `gtk.css` добавлено `#window { background-color: transparent; }` (wofi называет окно `window`), поэтому углы прозрачные. CSS wofi — APPLICATION (600), `gtk.css` — USER (800), поэтому фон и отсутствие focus-ring у поля задаёт правило `#outer-box #input` в `gtk.css`; в `style.css` — фолбэк. Padding окна вынесен в margin детей: иначе wofi центрует по width/height, а рисует на 30 px больше, и окно уезжает вправо-вниз.
- `padding-left: 44px` у строки и `margin-left: -33px` у `#img` повторяют место под иконку, которое rofi резервирует даже без неё. Prompt в wofi — это placeholder (приглушённый) плюс иконка поиска; в rofi — акцентный label. В GTK3 placeholder отдельно не красится.
- Меню команд — `--dmenu --cache-file /dev/null` (иначе сортировка по частоте). `--show window` под Sway не работает (нет `wlr-foreign-toplevel-management`).
- `allow_markup` глобально выключен: иначе меню с текстом `<...>` (clipboard) ругается Pango. `sway-cheatsheet {rofi|wofi}` включает разметку сам (`-markup-rows` / `--allow-markup`) и использует скрытые теги — не вырезать; по умолчанию `wofi`, `rofi` — запасной, те же теги и поиск.
- `wofi-clipboard` прогоняет `cliphist list` через `iconv -f UTF-8 -t UTF-8 -c`: cliphist режет превью по байтам и может разрезать UTF-8, иначе Pango сыплет предупреждениями.

### Mako, Swaylock, Foot

- Mako: `config/mako/config`, `pkill -HUP -x mako` перечитывает. `on-button-left=dismiss` (не `close` — с ним mako не стартует). `outer-margin=8`: waybar резервирует зону, уведомления встают под панелью.
- OSD громкости: mako не знает dunst-хинтов `frcolor`/`hlcolor`, поэтому `local/bin/wpctl-volume` кладёт уровень в `category` (`volume-*`), а цвета задают секции `[category=volume-*]` **после** `[urgency=*]`; заливка — `progress-color` по хинту `value`.
- Swaylock: `config/swaylock/config` читается сам, вызовы — `swaylock -f`. Цвета пишутся **без `#`** (строка с решёткой = комментарий, inline-комментариев нет). Обои — те же, что у `sway-display`, по именам выходов.
- Foot: `config/foot/foot.ini` — **терминал Sway по умолчанию**, `JetBrainsMono Nerd Font:size=10`, `pad=0x0`, без прозрачности. Alacritty (`config/alacritty`) остаётся для BSPWM и как запасной: foot не умеет X11.

## Темы: GTK, Qt, Flatpak

- GTK и Qt конфиги переключаются целиком: `theme on` принудительно линкует `~/.config/{gtk-3.0,gtk-4.0,qt5ct,qt6ct}` на каталоги репозитория (реальные каталоги/файлы уходят в `~/.dotfiles-backup-*`), `theme off` убирает ссылки и ставит `gtk-theme=Adwaita` — сток (нужен для GNOME: там пользовательский GTK-CSS не применяется и приложения красятся Adwaita; в Sway/BSPWM тема остаётся включённой), `theme status`. `link.sh` при установке линкует всё; `theme on` — принудительный возврат темы. `theme on/off` также включает/выключает Flatpak-override'ы: доступ к `gtk-3.0`, `gtk-4.0`, `qt5ct`, `qt6ct`, `xdg-data/themes` и `QT_QPA_PLATFORMTHEME=qt5ct` (как в `link.sh`). Применение — перезапуск приложений/сессия.
- **Почему CSS-оверрайды, а не своя GTK-тема.** `@define-color` меняет только именованные цвета, а большую часть цветов Adwaita прописывает жёстко в селекторах — без прямых правил Thunar, диалоги и прочий GTK3-софт остаются серыми. Полноценная тема (Adwaita SCSS → `sassc` → `~/.themes`) закрыла бы GTK3, но не решает главного: libadwaita (GTK4) игнорирует `gtk-theme` и читает только `~/.config/gtk-4.0/gtk.css`; при этом райс должен работать и под Sway/BSPWM, где нет GNOME и xsettings. Один оверлей на оба тулкита + одна палитра проще, чем тема плюс отдельный CSS. Поэтому объём правил в `gtk-3.0.css` — не случайность, а цена перекраски Adwaita без собственной темы.
- `config/gtk-3.0/gtk.css` — полный CSS поверх `Adwaita-dark` (`@define-color` + прямые селекторы). `config/gtk-4.0/gtk.css` — переменные libadwaita (`:root`) и слой `@define-color`; прямые селекторы точечно там, где libadwaita считает цвет сам (например, hover в `popover.menu modelbutton` через `color-mix(currentColor …)`).
- `Papirus-Dark` — светлые символы для тёмного фона; на светлой теме нужен `Papirus`.
- Курсор берётся из gsettings (`cursor-theme`/`cursor-size`), не из `settings.ini`; `link.sh` ставит `Bibata-Modern-Ice` 24. Без этого GTK-приложения рисуют Adwaita-курсор, пока Sway/XWayland показывают Bibata.
- GTK3: Adwaita рисует `background-image`/`box-shadow` в hover/active/checked/disabled/backdrop — в user CSS сбрасывать явно. Infobar — `infobar > revealer > box`, toolbar/searchbar — `searchbar > revealer > box`. Rubberband — отдельные правила `.rubberband`. Строки списков — и `row:selected`, не только `row.activatable:selected`.
- Qt: `config/qt5ct/colors/tokyo-night.conf` и `qt6ct/...` — 21 роль `QPalette` в порядке enum, цвет `#AARRGGBB`. `style=Fusion`, `custom_palette=true`. Применение — `qt5ct`/`qt6ct` или перезапуск приложения. Это фолбэк: в Sway/BSPWM платформенная тема — `kde` (палитра, стиль и иконки из `kdeglobals`), потому что KF6-приложения (Dolphin, Okular, Ark) палитру qt6ct игнорируют и рисуют серые виджеты Breeze. `sway-session`/`xinitrc`/`xprofile` выбирают `kde`, если установлен `plasma-integration`, иначе `qt6ct`. В Plasma цвет задаёт схема KDE, а не qt5ct/qt6ct.
- Рамка окна Qt-приложений на Wayland: её рисует сам Qt. Отдельного `environment.d` в репозитории нет: `QT_QPA_PLATFORMTHEME` для Sway/BSPWM задают `sway-session`/`xinitrc`/`xprofile` (`kde` или `qt6ct`), в GNOME Qt остаётся стоковым (gtk3/Adwaita). Если понадобится рамка Adwaita, `QT_WAYLAND_DECORATION=adwaita` можно добавить в сессионный скрипт.
- GNOME Shell: пользовательской темы нет. Стоковый Shell в GNOME 48 всегда тёмный: Style (`default`/`prefer-dark`) меняет только приложения, а светлый вариант Shell включается лишь `color-scheme=prefer-light` (UI его не выставляет). Полный вариант сохранён в ветке `themes-full`.
- VLC — Qt5, и у него есть **своя** тёмная палитра (`qt-dark-palette` в `~/.config/vlc/vlcrc`), которая перебивает системную: в KDE с Tokyo Night VLC остаётся «своим» тёмным. Выключить: Инструменты → Настройки → Интерфейс → «Use dark palette». `QtStyle=qt5ct-style` в `~/.config/vlc/vlc-qt-interface.conf` можно оставить. В Plasma палитру даёт `plasma5-integration`, в Sway/BSPWM — та же платформенная тема `kde` (её Qt5-плагин читает тот же `kdeglobals`).
- Flatpak: `link.sh` при наличии Flatpak выдаёт read-only доступ к `gtk-3.0`, `gtk-4.0`, `qt5ct`, `qt6ct`, `xdg-data/themes` и `QT_QPA_PLATFORMTHEME=qt5ct`. После повторного `link.sh` Flatpak-приложения нужно перезапустить.

## Терминал и шелл

- Alacritty: `config/alacritty/alacritty.toml`, `JetBrainsMono Nerd Font 10`, `opacity = 1` (прозрачность отвергнута), `live_config_reload = true`.
- GNOME Terminal: профили хранятся в dconf, файла для линковки нет. Палитру применяет `local/bin/gnome-terminal-palette` — фон `#1a1b26`, текст `#c0caf5`, те же 16 цветов ANSI, что в Alacritty/Foot, курсор и выделение. `--reset` возвращает цвета темы GNOME. Новые окна подхватывают сразу, открытые — после перезапуска.
- Ptyxis (терминал GNOME в Debian 13): `local/share/org.gnome.Ptyxis/palettes/tokyo-night.palette`, `link.sh` линкует его в `~/.local/share/org.gnome.Ptyxis/palettes/`. Палитра выбирается в Preferences → Palette (или `default-palette-id` в профиле). Формат — INI `[Palette]`, те же 16 цветов ANSI.
- Bash-промпт: `home/bashrc` только выбирает файл из `config/bash/themes/` по `BASH_PROMPT` (по умолчанию `tokyo-night`; есть `tokyo-night-minimal` и `empty`). Нет файла — стоковый `PS1`. Применение — `exec bash` или `source ~/.bashrc`.
- Fish/Tide: `config/fish/config.fish`; Tide ставится `install.sh`. Сгенерированное в git не коммитить.
- Алиасы без лаунчера — в `home/bashrc` и `config/fish/config.fish`: `net` (nmtui), `wifi-list`, `wifi-connect[-ask]`, `wifi-on/off`, `bt[-on/-off]`, `pp`/`pp-set bal|eco|perf`, `rh` (`rice-help`).
- `rice-help` (алиас `rh`) берёт команды из `local/bin` (только исполняемые) и алиасы из `home/bashrc` (описание — комментарий в конце строки). Новый алиас с комментарием появляется сам; `rice-help <слово>` фильтрует.
- `nmtui` перекрашен: `config/newt/colors` → `~/.config/newt/colors`, переменные `NEWT_COLORS_FILE` (libnewt: nmtui, whiptail) и `NMT_NEWT_COLORS_FILE` (наборы nmtui: `badLabel`, `plainLabel`, `disabledButton`, `textboxWithBackground`). Цвета — имена ANSI, фон `default`. У компактных кнопок nmtui фокус — цвет `button`, не `actbutton`. В комментариях файла нельзя писать `имя=значение` — newt разбирает их как настройки.
- Node.js/npm: `scripts/install-node.sh`, prefix `~/.npm-global` в `~/.npmrc`; PATH добавляют оба шелла. NVM, если установлен, подключается в конце `home/bashrc` и переопределяет `node`/`npm`.
- PHP/Composer/Laravel: `scripts/install-laravel.sh` ставит `php-cli` и расширения из Debian, Composer 2 в `~/.local/bin/composer`, `laravel/installer` глобально. Бинарник `laravel` лежит в `~/.config/composer/vendor/bin` — этот PATH добавляют оба шелла (блок `composer-global` в `home/bashrc` и `config/fish/config.fish`); `UPDATE_COMPOSER=1` переустанавливает Composer.

## Редакторы

- **Neovim** (`config/nvim`): Lua, менеджер — встроенный `vim.pack` (Neovim 0.12), плагины только в `lua/plugins.lua`. Файлы по зонам: `options`, `keymaps` (общие хоткеи), `finder` (telescope), `plugins`, `theme`, `treesitter`, `completion`, `lsp` (LSP-хоткеи вешает `LspAttach`), `explorer`, `git` (git-хунки вешает `on_attach`), `ui` (lualine + which-key). `nvim-pack-lock.json` версионируется, руками не править.
- Вкладки — это буферы: полоска сверху рисуется lualine (`tabline.buffers`), переключение — `<S-h>`/`<S-l>`, `<leader>fb` или клик. `hidden` не отключён (стоковое поведение Neovim). Сайдбар 32 колонки с `winfixwidth`, файлы открываются справа; `WinClosed` создаёт пустую рабочую область справа.
- Хоткеи: leader — пробел; `<C-h/j/k/l>` окна, `<leader>e` дерево, `<leader>ff/fg/fb/fh` поиск, `<C-\>` терминал, `<leader>w` сохранить, `<leader>q` `:qa`, LSP: `gd`, `gD`, `gr`, `gi`, `K`, `<leader>ca/rn/f/cd`, `[d`/`]d`; git: `]c`/`[c`, `<leader>gs/gr/gp/gb/gd`. Полный список — `docs/nvim.md`.
- LSP-серверы (lua_ls, bashls, pyright, ts_ls, clangd, rust_analyzer, jsonls, yamlls, html, cssls, emmet_language_server, intelephense) ставит `mason-lspconfig` при первом запуске (`ensure_installed`); вручную — `:Mason` / `:MasonInstall <имя>`. Telescope ищет через `ripgrep` (`requirements/software.txt`), без `rg` не работают `find_files`/`live_grep`. Treesitter требует `tree-sitter` CLI ≥ 0.26.1 (кладёт `install.sh`). Первый запуск требует сеть: `vim.pack` качает плагины.
- **Vim** (`home/vimrc`): без плагинов, палитра — из терминала. Гибридные номера, `undofile` в `~/.vim/undo`, отступы 4/2/табы по типу файла, `<C-h/j/k/l>` окна, `<Esc>` снимает подсветку поиска. Vim не знает `sxhkdrc`, `bspwmrc`, `dunstrc`, `picom*.conf` — для них в vimrc есть `augroup` с `setlocal filetype`.

## Приложения

- GIMP: `config/GIMP/3.0/themes/TokyoNight/`, переключение в Preferences → Interface → Theme.
- CopyQ: трекаются `copyq/themes/tokyo-night.ini`, `copyq.conf`, `copyq-commands.ini`, остальное игнорируется. Автозапуск в `bspwmrc`.
- EasyEffects: пресеты `config/easyeffects/output/*.json`, автозапуск в `bspwmrc` при наличии бинарника.
- Cava: `config/cava/config` (60 fps, mono, градиент Tokyo Night), перезапуск.
- Btop: `config/btop/btop.conf` + `themes/tokyo-night.theme`, тема по имени. btop перезаписывает конфиг при выходе — правки через `F2` или в репозитории.
- Fastfetch: `config/fastfetch/graphical.jsonc` (X11) и `tty.jsonc` (консоль), выбор по `$TERM` в `config.fish`.
- Midnight Commander: скины `local/share/mc/skins/*.ini`, формат INI, цвета `fg;bg`.
- Telegram: темы `themes/telegram/tokyo-night.*` (тёмная, оранжевый акцент) и `tokyo-night-light.*` (светлая «Tokyo Night Day», синий акцент `#2b6fd4`), обе в форматах `.tdesktop-palette` (Desktop) и `.attheme` (мобильная). Ставятся вручную (путь Flatpak).

## Система

- `install.sh` при наличии батареи пишет `/etc/systemd/logind.conf.d/10-lid-suspend.conf`: закрытие крышки → suspend.
- Аудио — PipeWire + WirePlumber (`pipewire`, `pipewire-audio`, `pipewire-pulse`, `wireplumber`). `pactl` в системе нет: громкость и mute — `wpctl`.
- `requirements/apt-system.txt` (`power-profiles-daemon`, `flatpak`) читает `install.sh`; TLP при наличии удаляется, чтобы не конфликтовать с PPD.
- `scripts/install-lamp.sh` — локальный веб-стек по `requirements/lamp.txt`: Apache, MariaDB (только `127.0.0.1`), PHP `mod_php`, phpMyAdmin на `http://localhost/phpmyadmin`. Две учётки: `devadmin` (полные права) и `project` (только базы `project_%`). Пароли генерируются и пишутся в `~/.config/webstack/credentials` (`chmod 600`); посмотреть — `scripts/install-lamp.sh --show-passwords`, свои — `--password`, перегенерировать — `--reset-passwords`. Скрипт идемпотентен.

## Устройства

Три основные машины — в `DEVICES.md`: hostname, железо, мониторы, X11/Sway-имена
выходов, ОС и диски. Кратко: `lamer-deb` — ПК с двумя мониторами (`DP-2` справа,
повёрнутый `HDMI-A-4` слева), Debian 13 GNOME, план — KDE; `lx15pro-deb` —
ноутбук NIPOGI LX15 Pro (Ryzen 5 7430U); нетбук — Acer TravelMate B3
(Celeron N4120, hostname снять на месте). На всех Debian 13 и пользователь
`nikita`; backports включены на ноутбуке и нетбуке, на ПК — нет (Docker,
стабильность). Ноутбук и нетбук — одноэкранные, попадают в ветку по умолчанию.
Всё hostname-специфичное — только в `bspwmrc`, `sway-session`
(`~/.cache/sway/workspaces.conf`) и `sway-display`; в конфигах Sway условий
нет. Не хватает данных — снимать с устройства командами из `DEVICES.md`
(`hostname`, `swaymsg -t get_outputs`, `xrandr`, `dmidecode`, `lsblk`),
а не спрашивать.

## Персонализация

- Hostname-ветки: `config/bspwm/bspwmrc` и `config/sway/config` (автозапуск OpenRGB — только `lamer-deb`), `local/bin/sway-session` (карта столов), `local/bin/sway-display` (`lamer-deb`).
- Имена хостов: ПК `lamer-deb`, ноутбук `lx15pro-deb`; нетбук TravelMate — имя снять `hostname`, в конфигах он попадает в ветку по умолчанию. Пользователь везде `nikita`.
- Имена мониторов: `DisplayPort-1`/`HDMI-A-3` в X11, `DP-2`/`HDMI-A-4` в Sway (в `sway-session`/`~/.cache/sway/workspaces.conf`, `sway-display` и `swaylock`).
- Обои: пути в `bspwmrc` — `$HOME/BSPWM-machineslego/wallpapers/`; клон в другом каталоге ломает обои. Выборщика нет и не будет.

## Устаревшее и служебное

- `wallpaper.sh` удалён: обои — статичные `feh`/`output bg`.
- `config/quickshell` — QML-исходники из другой ветки, лежат «на всякий случай»; не подключены и без просьбы не удаляются.
- `TODO.md` — рабочий блокнот, не документация релиза. `AGENTS.md` — внутренняя инструкция (эта карта), не публикуется; публичное — README.

## Релизы

- Тег — аннотированный `vX.Y.Z` (все прошлые с `v`). Ветка одна — `main`, задачи — сразу в неё; откат — `git revert`/`git restore`.
- `RELEASE.md` переписывается под текущий тег: первая строка `vX.Y.Z — Название`, английский блок, `---`, русский блок, без H1. Публикация: `git tag -a` → `git push origin main --tags` → GitHub Release с содержимым файла.
- Семантика: PATCH — исправления, MINOR — новые функции, MAJOR — ломающие. В `RELEASE.md` — только видимое пользователю.
- Тег и `git push` — только по просьбе. Случайные теги без `v` (`list`, `push`) ломают `git describe` — удалять `git tag -d`.
