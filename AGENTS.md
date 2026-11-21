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
| `system/etc/**` | системные конфиги | копия в `/etc/**` + бэкап `/etc/dotfiles-backup-YYYYMMDD-HHMMSS` |
| `scripts/*.sh` | установка и линковка | запуск вручную |
| `requirements/*.txt` | списки пакетов | читают `scripts/*.sh` |
| `screenshots/`, `wallpapers/`, `themes/` | картинки для README и тема Telegram | — |
| `README.md`, `README.ru.md` | публичная документация | — |
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
| Лаунчер и меню Wayland | `config/wofi/{config,style.css}`, `local/bin/wofi-*` |
| Уведомления | `config/dunst/dunstrc` (X11), `config/mako/config` (Sway) |
| Тема GTK / Qt | `config/gtk-3.0`, `config/gtk-4.0`, `config/qt5ct`, `config/qt6ct` |
| Терминалы | `config/alacritty/alacritty.toml`, `config/foot/foot.ini` |
| Редакторы | `config/nvim/`, `home/vimrc` |
| Пакеты | `requirements/apt.txt` (база X11), `sway.txt` (Sway, поверх базы), `apt-system.txt` (системное), `software.txt` (опциональное) |
| Установка и линковка | `scripts/install.sh`, `link.sh`, `unlink.sh`, `software.sh`, `install-node.sh`, `install-sway.sh` |
| Системные правки | `system/etc/**` |

**Пакеты называются не как команды:** `nmtui`/`nmcli` → `network-manager`, `bluetoothctl` → `bluez`, `wpctl` → `wireplumber`, `powerprofilesctl` → `power-profiles-daemon`, `lspci` → `pciutils`, `notify-send` → `libnotify-bin`. Отдельного пакета `network-manager-tui` не существует. Neovim AppImage требует `libfuse2t64`.

`link.sh` перед заменой файлов делает бэкап в `~/.dotfiles-backup-*`; `system/**` — в `/etc/dotfiles-backup-*`.

## Правила

- **Стоковый модуль вместо скрипта.** Скрипт появляется только там, где без него нельзя: запускается по требованию и сразу завершается. Никаких фоновых циклов и мёртвого кода.
- Перед новой фичей — `TODO.md`, раздел «Отвергнуто». Без явной просьбы не возвращать: темы/прозрачность, выборщик обоев, авто-темы, автогенерацию GTK-темы.
- **Персонализацию не обобщать молча:** hostname, имена мониторов и Wi-Fi интерфейсов, пути к обоям (см. «Персонализация»).
- Новая команда: `local/bin/<имя>` без расширения, с шебангом, `chmod +x`. **Третья строка файла** — описание: её читает `rice-help`. Документация в `local/bin` — это `*.md` (`start-llm.md`): такие файлы не линкуются и не исполняются.
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
- `config/polybar/config.ini`: только `internal/*` модули. `launch.sh` экспортирует `POLYBAR_BAT` / `POLYBAR_AC` / `POLYBAR_BACKLIGHT` — не хардкодить имена. Фон «пилюль» — `bg-mid = #1f2335`, иконки требуют JetBrainsMono Nerd Font.
- `config/rofi/config.rasi`: размеры только в `em` (не `%`), чтобы меню не зависело от монитора. `em` считается от шрифта `JetBrainsMono Nerd Font 10` (18 px). Ширины: launcher 36em, battery 24em, wifi 20em (список сетей и скрытая сеть — 24em), power-profile 20em, powermenu 17em, cheatsheet 62×36em (по самой длинной строке с тегами), dunst-history 40×24em. Высота остальных — по содержимому (`fixed-height: false`, `listview { lines: N; }` как максимум). В `cheatsheet-bspwm` теги строк — `#565f89` (fg-dim): видны как подсказка и участвуют в поиске.
- `local/bin/session-restart` перезапускает sxhkd, polybar, picom, dunst, blueman-applet, xss-lock, lxpolkit, copyq и делает `bspc wm -r`.
- Хоткей-«клей» живёт в `config/sxhkd/scripts/` (`flag.sh`, `to-preselect.sh`, `preselect-cancel-all.sh`): он действует на focused-окно и вне хоткея смысла не имеет.
- Из `sxhkdrc` и Polybar команды вызываются по короткому имени: PATH с `~/.local/bin` выставляют `home/xinitrc` (`startx`) и `home/xprofile`. `config/polybar/launch.sh` — часть конфига панели, а не команда.
- `bspwmrc` содержит hostname-ветки и жёсткие имена мониторов (`DisplayPort-1`, `HDMI-A-3`) — см. «Персонализация».

## Sway

- `config/sway/config`, симлинк `~/.config/sway`; `include /etc/sway/config.d/*` остаётся абсолютным. Стоковый `bar {}` удалён — панель рисует waybar.
- Оформление: `default_border pixel 2` и `default_floating_border pixel 2` (заголовков нет), `gaps inner/outer 0`, `smart_borders on`. В режиме `pixel` рамку рисует `child_border`, поэтому он продублирован в каждом `client.*`. `client.focused #6b8dd6`, `client.unfocused`/`focused_inactive` — `#1a1b26`.
- **Все `bindsym` — с `--to-code`.** Без флага keysym привязан к текущей раскладке и в RU-режиме не срабатывает.
- Раскладка `us,ru` + `grp:caps_toggle`, автоповтор 250/30 — через `input "type:keyboard"`; тачпад — `tap`, `dwt`, `natural_scroll enabled`.
- `local/bin/sway-session` — обёртка вместо `sway`: PATH, `XDG_*`, курсор Bibata 24, Qt (`qt6ct`, `QT_QPA_PLATFORM="wayland;xcb"`), GTK (`GDK_BACKEND=wayland,x11`), `SAL_USE_VCLPLUGIN=gtk3`, `MOZ_ENABLE_WAYLAND`, Electron, Java; затем `exec sway "$@"`. `home/xinitrc`/`xprofile` под Wayland не выполняются.
- `local/bin/sway-display` — мониторы и обои. В конфиге Sway нет hostname-условий: ветка `lamer-deb` (`DP-2` + `HDMI-A-4` с `transform 90`) и фолбэк ноутбука живут в скрипте. Имена выходов wlroots ≠ X11: `DisplayPort-1`/`HDMI-A-3` → `DP-2`/`HDMI-A-4`. Вызывается как `exec_always`; обои ставит сам Sway через `output ... bg`.
- Автозапуск — `exec_always pgrep -x <имя> >/dev/null || <имя>` для waybar, mako, lxpolkit: reload не плодит дубли. `swayidle`: 10 минут и `before-sleep` → `swaylock -f`. `wl-paste --watch cliphist -max-items 100 store` — под таким же стражем. EasyEffects — обычный `exec` (при reload не повторяется).
- Хоткеи: `$mod+Return` foot, `$mod+d` `wofi --show drun`, `$mod+/` `sway-cheatsheet`, `$mod+F1..F4`/`$mod+Shift+S` скриншоты, `$mod+Shift+A` редактор, `$mod+Shift+R` запись всего экрана, `$mod+Shift+Alt+R` области, `$mod+Shift+V` буфер, `$mod+Escape`/`$mod+Shift+C` reload, `$mod+w` kill, `$mod+Alt+L` lock, `$mod+Alt+N` wifi, `$mod+Alt+B` battery, `$mod+Shift+Q` powermenu, `$mod+Shift+E` `swaynag`. Полный список — `sway-cheatsheet`. Профиль питания переключается кликом по модулю PPD в waybar (отдельного меню нет).

### Порталы (OBS, ScreenCast)

1. Переменные Sway должны попасть в systemd/dbus: в конфиге есть `dbus-update-activation-environment --systemd --all`. Проверка: `systemctl --user show-environment | grep WAYLAND_DISPLAY`.
2. `config/xdg-desktop-portal/portals.conf`: `default=gtk`, а `ScreenCast`/`Screenshot` — `wlr` (hyprland-портал тоже заявляет `sway`, поэтому выбор явный). `default=wlr` нельзя: остальные функции отвалятся.
3. OBS запускать с `QT_QPA_PLATFORM="wayland;xcb"` (как в `sway-session`), иначе он уйдёт в XWayland.
4. `slurp` нужен порталу для выбора монитора; он в `requirements/sway.txt`.

### Скриншоты, запись, буфер

- `sway-screenshot {full|window|delayed|monitor|region|annotate}`: снимает `grim` (+`slurp` для области), PNG кладёт в буфер (`wl-copy`) и в `Screenshots` внутри `xdg-user-dir PICTURES` (фолбэк `~/Screenshots`).
- `annotate` берёт картинку из буфера и открывает `swappy -f -`; экспортирует `XDG_PICTURES_DIR`, иначе `swappy` сохранит в `/Screenshots`. Если в буфере текст — уведомление и код 1.
- `sway-record {full|region}`: `wf-recorder`, повторный вызов **любого** режима останавливает запись через `pkill -INT` (mp4 закрывается только по SIGINT). Монитор передаётся явно `-o` (иначе под хоткеем `wf-recorder` молча не стартует на мультимониторе). VAAPI (`h264_vaapi`) только для полного экрана и только на `amdgpu` (узел ищется по драйверу, номер `renderD*` не фиксирован); остальное — `libx264`. Стороны области округляются вниз до чётных: VAAPI не умеет меньше 128×128, x264 пишет любой размер. Звук не пишется.
- Буфер: `cliphist list` → `wofi --dmenu` → `cliphist decode <id> | wl-copy` (`wofi-clipboard`, `Super+Shift+V`). Хранится 100 записей (`-max-items 100` — до подкоманды `store`). Под Wayland CopyQ не используется.

### Waybar

- `style.css`: палитра только через `@define-color` в начале файла, в правилах — `@имя`. `:root`/`var()` GTK-CSS не понимает. Группа `group/left` в CSS — **`#left`**, без префикса.
- Формат модуля допускает **один** плейсхолдер: `"{:L%H:%M  󰃭 %a, %d %b}"`. Локализация — `"locale": "ru_RU.UTF-8"` у модуля (префикс `L` внутри спецификатора).
- `keyboard-state` читает `/dev/input/event*` через libevdev: пользователь должен быть в группе `input` (её выдаёт `install-sway.sh`), иначе индикаторы Caps/Num/Scroll пустые.
- Звук — `wpctl` (WirePlumber; `pactl` в системе нет). Сеть — `network`: ЛКМ `nm-connection-editor`, ПКМ `wofi-wifi`. Трей `icon-size: 16`, островки — `@bg-alt`, панель непрозрачная.

### Wofi

- `config/wofi/config` + `style.css`, лаунчер Sway; в BSPWM остаётся Rofi. `show=drun`, окно 600×400 по центру, `no_actions=true`, `layer=overlay`.
- Фон окна рисует **`#outer-box`**, а не `window`. Свой CSS wofi — приоритет APPLICATION (600), `config/gtk-3.0/gtk.css` — USER (800), поэтому фон поля ввода возвращает правило `#outer-box #input` в `gtk.css`; в `style.css` значение — фолбэк.
- `--width` — ширина окна в px: launcher 600, powermenu 340, wifi 380 (сети и скрытая — 440), battery 400, cheatsheet 960×650, clipboard 860. `dynamic_lines=true`, `--lines` считает и поле ввода, поэтому в скриптах передаётся «пунктов + 2».
- Меню команд — `--dmenu --cache-file /dev/null` (иначе сортировка по частоте). `--show window` под Sway не работает (нет `wlr-foreign-toplevel-management`).
- `sway-cheatsheet` использует pango-разметку и скрытые теги цвета фона — это осознанно; не вырезать.

### Mako, Swaylock, Foot

- Mako: `config/mako/config`, `pkill -HUP -x mako` перечитывает. `on-button-left=dismiss` (не `close` — с ним mako не стартует). `outer-margin=8`: waybar резервирует зону, уведомления встают под панелью.
- OSD громкости: mako не знает dunst-хинтов `frcolor`/`hlcolor`, поэтому `local/bin/volume` кладёт уровень в `category` (`volume-*`), а цвета задают секции `[category=volume-*]` **после** `[urgency=*]`; заливка — `progress-color` по хинту `value`.
- Swaylock: `config/swaylock/config` читается сам, вызовы — `swaylock -f`. Цвета пишутся **без `#`** (строка с решёткой = комментарий, inline-комментариев нет). Обои — те же, что у `sway-display`, по именам выходов.
- Foot: `config/foot/foot.ini`, `JetBrainsMono Nerd Font:size=10`, `pad=0x0`, без прозрачности, `[csd] preferred=none` (рамку рисует Sway). Живого перечитывания нет.

## Темы: GTK, Qt, Flatpak

- `config/gtk-3.0/gtk.css` — полный CSS поверх `Adwaita-dark` (`@define-color` + прямые селекторы). `config/gtk-4.0/gtk.css` — только переменные libadwaita (`:root`) и слой `@define-color`; прямых селекторов нет.
- Светлые варианты — `gtk-light.css` в обоих каталогах, те же селекторы, другая палитра (Tokyo Night Day). Включение: скопировать light-файл поверх `gtk.css`, `gsettings set ... gtk-theme Adwaita`, `color-scheme default`, `icon-theme Papirus`. Возврат — `git checkout -- config/gtk-3.0/gtk.css config/gtk-4.0/gtk.css` + `Adwaita-dark`/`prefer-dark`/`Papirus-Dark`. В BSPWM дополнительно правится `gtk-theme-name` в `settings.ini` (в X11 нет xsettingsd).
- `Papirus-Dark` — светлые символы для тёмного фона; на светлой теме нужен `Papirus`.
- Курсор берётся из gsettings (`cursor-theme`/`cursor-size`), не из `settings.ini`; `link.sh` ставит `Bibata-Modern-Ice` 24. Без этого GTK-приложения рисуют Adwaita-курсор, пока Sway/XWayland показывают Bibata.
- GTK3: Adwaita рисует `background-image`/`box-shadow` в hover/active/checked/disabled/backdrop — в user CSS сбрасывать явно. Infobar — `infobar > revealer > box`, toolbar/searchbar — `searchbar > revealer > box`. Rubberband — отдельные правила `.rubberband`. Строки списков — и `row:selected`, не только `row.activatable:selected`.
- Qt: `config/qt5ct/colors/tokyo-night.conf` и `qt6ct/...` — 21 роль `QPalette` в порядке enum, цвет `#AARRGGBB`; светлый — `tokyo-night-day.conf` (переключение — `sed` в `qt5ct.conf`/`qt6ct.conf` + `icon_theme=Papirus`). `style=Fusion`, `custom_palette=true`. Применение — `qt5ct`/`qt6ct` или перезапуск приложения.
- Flatpak: `link.sh` при наличии Flatpak выдаёт read-only доступ к `gtk-3.0`, `gtk-4.0`, `qt5ct`, `qt6ct`, `xdg-data/themes` и `QT_QPA_PLATFORMTHEME=qt5ct`. После повторного `link.sh` Flatpak-приложения нужно перезапустить.

## Терминал и шелл

- Alacritty: `config/alacritty/alacritty.toml`, `JetBrainsMono Nerd Font 10`, `opacity = 1` (прозрачность отвергнута), `live_config_reload = true`.
- Bash-промпт: `home/bashrc` только выбирает файл из `config/bash/themes/` по `BASH_PROMPT` (по умолчанию `tokyo-night`; есть `tokyo-night-minimal` и `empty`). Нет файла — стоковый `PS1`. Применение — `exec bash` или `source ~/.bashrc`.
- Fish/Tide: `config/fish/config.fish`; Tide ставится `install.sh`. Сгенерированное в git не коммитить.
- Алиасы без лаунчера — в `home/bashrc` и `config/fish/config.fish`: `net` (nmtui), `wifi-list`, `wifi-connect[-ask]`, `wifi-on/off`, `bt[-on/-off]`, `pp`/`pp-set`, `rh` (`rice-help`).
- `rice-help` (алиас `rh`) берёт команды из `local/bin` (только исполняемые) и алиасы из `home/bashrc` (описание — комментарий в конце строки). Новый алиас с комментарием появляется сам; `rice-help <слово>` фильтрует.
- `nmtui` перекрашен: `config/newt/colors` → `~/.config/newt/colors`, переменные `NEWT_COLORS_FILE` (libnewt: nmtui, whiptail) и `NMT_NEWT_COLORS_FILE` (наборы nmtui: `badLabel`, `plainLabel`, `disabledButton`, `textboxWithBackground`). Цвета — имена ANSI, фон `default`. У компактных кнопок nmtui фокус — цвет `button`, не `actbutton`. В комментариях файла нельзя писать `имя=значение` — newt разбирает их как настройки.
- Node.js/npm: `scripts/install-node.sh`, prefix `~/.npm-global` в `~/.npmrc`; PATH добавляют оба шелла. NVM, если установлен, подключается в конце `home/bashrc` и переопределяет `node`/`npm`.

## Редакторы

- **Neovim** (`config/nvim`): Lua, менеджер — встроенный `vim.pack` (Neovim 0.12), плагины только в `lua/plugins.lua`. Файлы по зонам: `options`, `keymaps` (**все** хоткеи, включая буферные `M.lsp(buf)`/`M.git(buf)`), `plugins`, `theme`, `treesitter`, `completion`, `lsp`, `explorer`, `git`, `ui`. `nvim-pack-lock.json` версионируется, руками не править.
- Рабочий процесс — одиночный буфер (`nohidden` + `confirm`): файл из дерева заменяет текущий, изменённый — спрашивает сохранение. Сайдбар 32 колонки, `WinClosed` создаёт пустую рабочую область справа.
- Хоткеи: leader — пробел; `<C-h/j/k/l>` окна, `<leader>e` дерево, `<leader>w` сохранить, `<leader>q` `:qa`, LSP: `gd`, `gD`, `gr`, `K`, `<leader>ca/ci/rn/f/cd`, `[d`/`]d`; git: `]c`/`[c`, `<leader>gs/gr/gp/gb/gd`. Полный список — `config/nvim/CHEATSHEET.md`.
- LSP-серверы ставятся вручную: `:Mason` / `:MasonInstall <имя>` (lua_ls, bashls, pyright, ts_ls, clangd, rust_analyzer, jsonls, yamlls, html, cssls, emmet_language_server, intelephense). Treesitter требует `tree-sitter` CLI ≥ 0.26.1 (кладёт `install.sh`). Первый запуск требует сеть: `vim.pack` качает плагины.
- **Vim** (`home/vimrc`): без плагинов, палитра — из терминала. Гибридные номера, `undofile` в `~/.vim/undo`, отступы 4/2/табы по типу файла, `<C-h/j/k/l>` окна, `<Esc>` снимает подсветку поиска. Vim не знает `sxhkdrc`, `bspwmrc`, `dunstrc`, `picom*.conf` — для них в vimrc есть `augroup` с `setlocal filetype`.

## Приложения

- GIMP: `config/GIMP/3.0/themes/TokyoNight/`, переключение в Preferences → Interface → Theme.
- CopyQ: трекаются `copyq/themes/tokyo-night.ini`, `copyq.conf`, `copyq-commands.ini`, остальное игнорируется. Автозапуск в `bspwmrc`.
- EasyEffects: пресеты `config/easyeffects/output/*.json`, автозапуск в `bspwmrc` при наличии бинарника.
- Cava: `config/cava/config` (60 fps, mono, градиент Tokyo Night), перезапуск.
- Btop: `config/btop/btop.conf` + `themes/tokyo-night.theme`, тема по имени. btop перезаписывает конфиг при выходе — правки через `F2` или в репозитории.
- Fastfetch: `config/fastfetch/graphical.jsonc` (X11) и `tty.jsonc` (консоль), выбор по `$TERM` в `config.fish`.
- Midnight Commander: скины `local/share/mc/skins/*.ini`, формат INI, цвета `fg;bg`.
- Telegram: тема `themes/telegram/tokyo-night.tdesktop-palette` ставится вручную (путь Flatpak).

## Система

- `install.sh` при наличии батареи пишет `/etc/systemd/logind.conf.d/10-lid-suspend.conf`: закрытие крышки → suspend.
- Аудио — PipeWire + WirePlumber (`pipewire`, `pipewire-audio`, `pipewire-pulse`, `wireplumber`). `pactl` в системе нет: громкость и mute — `wpctl`.
- `requirements/apt-system.txt` (`power-profiles-daemon`, `flatpak`) читает `install.sh`; TLP при наличии удаляется, чтобы не конфликтовать с PPD.

## Персонализация

- Hostname-ветки: `config/bspwm/bspwmrc` (OpenRGB и раскладка мониторов — только `lamer-deb`), `local/bin/wifi` (имена Wi-Fi интерфейсов), `local/bin/sway-display` (`lamer-deb`).
- Имена мониторов: `DisplayPort-1`/`HDMI-A-3` в X11, `DP-2`/`HDMI-A-4` в Sway (в `sway-display` и `swaylock`).
- Обои: пути в `bspwmrc` — `$HOME/BSPWM-machineslego/wallpapers/`; клон в другом каталоге ломает обои. Выборщика нет и не будет.

## Устаревшее и служебное

- `config/quickshell/control-center/shell.qml` — экспериментальная панель, в окружение не интегрирована (нет хоткея, кнопки и автозапуска). Запуск вручную `qs -c control-center`, закрыть `pkill -x qs`. Пакет `quickshell` в `requirements/` не входит.
- `wallpaper.sh` удалён: обои — статичные `feh`/`output bg`.
- `TODO.md` — рабочий блокнот, не документация релиза. `AGENTS.md` — внутренняя инструкция (эта карта), не публикуется; публичное — README.

## Релизы

- Тег — аннотированный `vX.Y.Z` (все прошлые с `v`). Ветка одна — `main`, задачи — сразу в неё; откат — `git revert`/`git restore`.
- `RELEASE.md` переписывается под текущий тег: первая строка `vX.Y.Z — Название`, английский блок, `---`, русский блок, без H1. Публикация: `git tag -a` → `git push origin main --tags` → GitHub Release с содержимым файла.
- Семантика: PATCH — исправления, MINOR — новые функции, MAJOR — ломающие. В `RELEASE.md` — только видимое пользователю.
- Тег и `git push` — только по просьбе. Случайные теги без `v` (`list`, `push`) ломают `git describe` — удалять `git tag -d`.
