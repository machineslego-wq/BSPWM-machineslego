# AGENTS.md

Dotfiles + установщик окружения BSPWM/Sway для Debian 13 Trixie (X11 + Wayland, Tokyo Night). Sway — направление переезда, BSPWM остаётся запасной X11-сессией.
Сборки, тестов, линтера и CI нет: «продукт» — конфиги и shell-скрипты.

## Главное правило репозитория
- Решается стоковым модулем — не пиши скрипт. Скрипт нужен — запускай по требованию и сразу завершай.
- Никаких фоновых циклов и мёртвого кода.
- Перед новой фичей сверься с разделом «Отвергнуто» в `TODO.md` (темы, прозрачность, выборщик обоев, авто-темы). Не возвращай их без явной просьбы.

## Как устроены «живые» конфиги

### Структура репозитория
- `config/<pkg>` → симлинк `~/.config/<pkg>`
- `home/<file>` → `~/.<file>` (добавляется точка к имени)
- `local/bin/<команда>` → симлинк `~/.local/bin/<команда>` (поштучно: там же лежат nvim, tree-sitter, zed — их не трогать)
- `local/share/mc/skins/*.ini` → симлинк `~/.local/share/mc/skins/<файл>`
- `system/**` → копируется в `/etc/**` с бэкапом в `/etc/dotfiles-backup-YYYYMMDD-HHMMSS`

Правка файла в репозитории сразу меняет живую систему (симлинк), отдельного шага синхронизации нет.

### Скрипты
- `scripts/install.sh` — полная установка: Neovim AppImage и `tree-sitter` CLI в `~/.local/bin`, шрифт, линковка, Fish/Tide, пакеты из `requirements/apt.txt` и `apt-system.txt`, PPD/Flatpak, системные конфиги, поведение крышки. Запускается только при первичной настройке.
- `scripts/link.sh` — идемпотентный линковщик: делает бэкап в `~/.dotfiles-backup-*`, ставит симлинки (конфиги, home-файлы, команды в `~/.local/bin`, скины MC). Меняет уже установленные пакеты. Дополнительно выставляет тему курсора GTK в gsettings (`Bibata-Modern-Ice`, 24) — см. раздел GTK3 / GTK4.
- `scripts/unlink.sh` — безопасное удаление симлинков, созданных link.sh (только свои, не трогает чужие): `~/.config/*`, home-файлы, `~/.local/bin`, скины MC.
- `scripts/software.sh` — установка дополнительного софта из `requirements/software.txt` (lazygit, ripgrep, mpv, gimp и т.д.). Запускается отдельно, install.sh только печатает подсказку.
- `scripts/install-node.sh` — Node.js LTS из NodeSource, npm с prefix `~/.npm-global` (глобальные пакеты без sudo). Запускается отдельно, не из install.sh.
- `scripts/install-sway.sh` — ставит Sway и окружение из `requirements/sway.txt` (sway, swaybg/idle/lock, waybar, wofi, foot, mako, grim/slurp, swappy, wf-recorder, cliphist, порталы, lxpolkit) и добавляет пользователя в группу `input` (нужна waybar-модулю `keyboard-state` для индикаторов Caps/Num Lock). По умолчанию только пакеты: конфиги не копирует и сессию не включает. С `--session` дополнительно пишет `/usr/share/wayland-sessions/sway-session.desktop` с `Exec=$HOME/.local/bin/sway-session`. BSPWM при этом не удаляется: он остаётся запасной X11-сессией.

Не запускай `install.sh` и `unlink.sh` без явной просьбы. `link.sh` — безопасен для запуска в любое время.

### Права на файлы
Скрипты и команды в git имеют режим 755; новые файлы в `local/bin/` и `*.sh` тоже должны быть executable (`chmod +x`). `link.sh` выставляет `+x` при линковке.

### Команды и хелперы
- Пользовательские команды — в `local/bin/` → `~/.local/bin` (PATH): `battery`, `cheatsheet-bspwm`, `dunst-history`, `powermenu`, `power-profile`, `screenshot`, `session-restart`, `volume`, `wifi`, `rice-check`, `rice-help`; набор Sway — обвязка `sway-cheatsheet`, `sway-display`, `sway-record`, `sway-screenshot`, `sway-session`, меню на wofi — `wofi-battery`, `wofi-clipboard`, `wofi-powermenu`, `wofi-wifi`. Без расширения `.sh`, с шебангом.
- Машинные команды — там же: `start-llm` (Ollama + OpenWebUI), `start-comfy` (ComfyUI), `vllm-setup`, `yacht`, `mount-nas`, `openrgb-i2c-fix`, `sddm-avatar`, `check-hardware`, `check-strawberry`. По умолчанию — быстрый запуск; первичная установка и обслуживание — флагами. Команда с обязательным аргументом без него печатает справку и выходит с кодом 1.
- Хоткей-«клей» BSPWM остаётся в `config/sxhkd/scripts/`: `flag.sh`, `to-preselect.sh`, `preselect-cancel-all.sh`. Они действуют на focused-окно и вне хоткея смысла не имеют.
- `config/polybar/launch.sh` — часть конфига панели (запускается из `bspwmrc`), а не команда.
- Из `sxhkdrc` и Polybar команды вызываются по короткому имени, без `~/.config/...`. PATH с `~/.local/bin` выставляют `home/xinitrc` (`startx`) и `home/xprofile` (display manager), поэтому `sxhkd`, `polybar`, `dunst` и `rofi` его наследуют.
- Новая команда: файл в `local/bin/` без расширения, при необходимости строка в `sxhkdrc`. `link.sh` сам сделает симлинк и `+x`.

## Применение изменений

| Компонент | Команда | Горячая клавиша |
|-----------|---------|-----------------|
| BSPWM | `bspc wm -r` | `Super + Alt + R` |
| SXHKD | `pkill -USR1 -x sxhkd` | `Super + Escape` |
| Polybar | `~/.config/polybar/launch.sh` | — |
| Picom | `pkill -x picom; picom --config <профиль>` | — |
| Vim | `:source ~/.vimrc` | — |
| GTK3 / GTK4 | перезапуск приложения (CSS читается при старте) | — |
| Qt | `qt5ct` / `qt6ct` или перезапуск приложения | — |
| Полный перезапуск | `session-restart` | `Super + Alt + Shift + R` |

Picom автоматически выбирает профиль по `powerprofilesctl get`:
- `power-saver` → `picom-eco.conf`
- иначе → `picom.conf`

## Особенности конфигов

### sxhkdrc
- Команда под хоткеем — отступ ровно 4 пробела (не табы).
- Поддерживается brace-раскладка `super + {a,b}` (аналог `super + a; super + b`).
- Комментарии — только на отдельной строке; inline-комментарии ломают парсер.
- Команды из `~/.local/bin` вызываются по имени; хоткей-хелперы — `~/.config/sxhkd/scripts/*.sh`.

### Picom
- Не парсит унарный минус: писать `"0 - window-height"`, а не `"-window-height"`.
- DIM effect: `dim-spec` задаёт прозрачность неактивных окон (например, `0.7` — 70% непрозрачности).

### Polybar
- Использует `internal/*` модули.
- `launch.sh` экспортирует `POLYBAR_BAT` / `POLYBAR_AC` / `POLYBAR_BACKLIGHT`. Не хардкодь имена батареи/подсветки.
- Фон для «пилюль» (окружений модулей) — `bg-mid = #1f2335`.
- Иконки требуют JetBrainsMono Nerd Font.

### Rofi
- Размеры фиксированные и в `em`, не в `%`: одно и то же окно от 1366×768 до 1920×1080 и выше. `em` считается от размера шрифта (`JetBrainsMono Nerd Font 11` → 20 px), а не от монитора.
- Ширина каждого меню — та же, что была в процентах на 1920×1080, но в `em`: launcher `40em` (800 px, общий конфиг), `battery` 29em, `wifi` 24em (выбор сети и скрытая сеть — 29em), `power-profile` 21em, `powermenu` 19em, `cheatsheet-bspwm` и `dunst-history` 48em. `dunst` из `dunstrc` берёт общий 40em.
- Высота `cheatsheet-bspwm` (38em) и `dunst-history` (27em) тоже в `em`; у остальных — по содержимому: `listview { lines: N; }` задаёт максимум, `fixed-height: false` подрезает окно, поэтому короткие меню не растягиваются.
- Применение: следующий запуск Rofi (конфиг читается при каждом старте).

### Waybar (Sway)
- `config/waybar/config.jsonc` + `config/waybar/style.css` → `~/.config/waybar`. Панель только для Sway; в BSPWM работает Polybar.
- Палитра — в начале `style.css` блоком `@define-color` (имена как в `config/polybar/config.ini`: `bg`, `bg-mid`, `fg`, `primary`, `alert` и т.д.), в правилах только `@имя`. `:root` и `var()` GTK-CSS не понимает: waybar пишет `Invalid name of pseudo-class` и молча отбрасывает правило, поэтому переменные — только через `@define-color`.
- Композиция: слева `custom/debian` (логотип Debian, клик — `wofi --show drun`) и группа `group/left` — рабочие столы, режим, scratchpad; в центре группа `group/center` — яркость, часы, батарея; справа группа `group/right` — трей, Caps Lock / Num Lock / Scroll Lock (`keyboard-state`), раскладка (`sway/language`), профиль питания, звук, сеть и кнопка питания, открывающая `wofi-powermenu`. Заголовка окна (`sway/window`) нет: панель не пересказывает название приложения.
- Островки: фон `@bg-alt` (`#24283b`) и скругление 5 px рисует сама группа, а модули внутри — без фона и внешних отступов (только горизонтальный padding), поэтому блок выглядит цельным, без пустых промежутков. В CSS группа `group/left` — это **`#left`** (GTK-имя без префикса `group/`), а не `#group-left`. Панель, кнопки столов и тултипы остаются с прямыми углами.
- Рабочие столы — цифры 1–10 через `format-icons` (`default` — `•` для нестандартных имён). Активный — акцентный текст и подчёркивание 2 px, как `label-focused` в Polybar; занятый — обычный текст, пустой — приглушённый, срочный — фон `@warning`.
- Цвета как в Polybar: часы `@primary` жирным, профиль питания и сеть — обычный текст, зарядка `@success`, низкий заряд `@warning` (`states.warning = 59`), критический `@alert` с миганием (`states.critical = 14`), кнопка питания `@primary`.
- Звук — родной `wireplumber` (`wpctl`, `pactl` в системе нет): `{icon} {volume}%`, иконки `󰕿`/`󰖀`/`󰕾`, при муте — `󰝟 MUTE` красным. ЛКМ — mute, ПКМ — `pavucontrol-qt`, прокрутка — 5%. Тултип показывает имя узла. Сеть — `network` (ЛКМ — `nm-connection-editor`, ПКМ — `wofi-wifi`). rofi-команды не используются: они X11-only.
- Caps Lock / Num Lock / Scroll Lock — модуль `keyboard-state`: Num — `󰎠` (123) цветом `@primary`, Caps — `󰘲` (стрелка вверх, как Shift) цветом `@warning`, Scroll — `↕` цветом `@secondary`; выключенные — `@disabled`. Иконки заданы объектом `format` по ключам `numlock`/`capslock`/`scrolllock`. Модуль читает `/dev/input/event*` через libevdev, поэтому пользователь должен быть в группе `input` (её выдаёт `install-sway.sh`); без неё модуль не находит клавиатуру. Состояние перечитывается по нажатию Caps/Num/Scroll, а не по таймеру.
- Трей — `icon-size: 16` (в Polybar 18): иконки чуть мельче, островок не раздувается.
- Панель непрозрачная: `#1a1b26`, островки `#24283b`, акцент `#7aa2f7`.
- В формате модуля допустим только **один** плейсхолдер `{…}`: `"{:%H:%M} {:%d %b}"` даёт `clock: format error: invalid arg-id`, поэтому дата и время пишутся внутри одного спецификатора — `"{:L%H:%M  󰃭 %a, %d %b}"`. Префикс `L` сразу после `{:` включает локализованные `%a`/`%b`, язык задаёт опция `"locale": "ru_RU.UTF-8"` у модуля (как `locale` в Polybar): без неё дата печатается по-английски. Форма `%La`/`%Lb` (L перед спецификатором) не работает — fmt отвечает `invalid specifier in chrono-specs`.
- `reload_style_on_change` включён: CSS применяется без перезапуска. Правка `config.jsonc` — `pkill -x waybar; waybar &`.

### Wofi (Sway)
- `config/wofi/config` + `config/wofi/style.css` → `~/.config/wofi`. Лаунчер для Sway; в BSPWM остаётся Rofi.
- `show=drun`, окно `600x400` по центру, `no_actions=true` (без кнопок Launch/Close), `layer=overlay`.
- Фон окна рисует **`#outer-box`**, а не `window`/`#window`: эти селекторы wofi игнорирует. Само окно прозрачное, но прозрачности у панели нет — `#outer-box` непрозрачный.
- Стиль повторяет `config/rofi/config.rasi`: отступ 8 px, выбранная строка — акцент `#7aa2f7` с тёмным текстом. Окно без скруглений, поле ввода и строки — 2 px.
- Поле поиска — `@bg-alt` (`#24283b`), окно — `@bg` (`#1a1b26`). Свой CSS wofi ставит с приоритетом APPLICATION (600), а `config/gtk-3.0/gtk.css` — USER (800), поэтому правило `entry` из GTK-темы перекрывает `background-color` у `#input`. Фон возвращает отдельное правило в `gtk.css`: `#outer-box #input { background-color: #24283b; }` — id-селектор в USER-провайдере сильнее общего `entry`. Значение `bg-alt` у `#input` в `style.css` — фолбэк для системы без пользовательской GTK-темы; строки (`#entry`) прозрачные, их цвет даёт `#outer-box`. Применение — при следующем запуске wofi.
- `--width` задаёт ширину окна целиком. Ширины меню совпадают с Rofi: `powermenu` 380, `wifi` 480 (список сетей и скрытая — 580), `battery` 580, `sway-cheatsheet` 960.
- Меню подстраиваются под содержимое: `dynamic_lines=true` в конфиге (аналог `fixed-height: false` в Rofi), `--lines` считает и поле ввода, поэтому в скриптах передаётся «пунктов + 2».
- Стиль читается при каждом запуске: фон `#1a1b26`, акцент `#7aa2f7`.
- Запуск: `wofi --show drun` (хоткей Sway — `Super+D`), `--show run` — команды. `--show window` под Sway не работает: он требует `wlr-foreign-toplevel-management`, которого в Sway нет.
- Меню команд — `--dmenu` с `--cache-file /dev/null` (иначе wofi сортирует пункты по частоте выбора): `wofi-battery`, `wofi-powermenu`, `wofi-wifi`.

### Mako (Sway)
- `config/mako/config` → `~/.config/mako`. Уведомления для Sway; в BSPWM остаётся `dunst` (`config/dunst/dunstrc`).
- Оформление повторяет dunst: фон `#1a1b26`, текст `#c0caf5`, рамка 2 px `#7aa2f7`, ширина 360, скругление 2 px, прогресс-бар тёмно-синий (`#1c305b`), иконки выключены (`icons=0`), критические уведомления без таймаута и с красной рамкой `#f7768e`.
- Геометрия переведена с dunst: `origin top-right` → `anchor=top-right`, `gap_size 8` → `margin=0` (соседние уведомления разделяет рамка). `outer-margin=8`: mako — layer-shell поверхность, waybar резервирует свою зону, поэтому уведомления встают под панелью, а край экрана отделяет `outer-margin`.
- Мышь: ЛКМ — `dismiss`, СКМ — `invoke-default-action`, ПКМ — `dismiss-all`. Важно: `on-button-left` принимает действие `dismiss`, а не `close` (с `close` mako не стартует).
- OSD громкости: dunst красит его по хинтам `frcolor`/`hlcolor`, mako такие хинты не знает, поэтому `local/bin/volume` кладёт уровень в `category` (`volume-mute/low/mid/high/overflow`), а цвета задают критерии `[category=volume-*]` в конце `config/mako/config`: `border-color` — рамка, `progress-color` — заливка по хинту `value` (альфа `0x26`: у mako она занимает всю высоту уведомления, а не полоску снизу). Секции обязаны идти после `[urgency=*]`, иначе синяя рамка обычной важности их перекроет.
- Применение: `pkill -HUP -x mako` (перечитывает конфиг). Проверка синтаксиса — `timeout 3 dbus-run-session -- mako --config config/mako/config` (пустой вывод = ok).

### Sway (переезд с BSPWM)
- `config/sway/config` — конфиг в репозитории, линкуется как `~/.config/sway`; `include /etc/sway/config.d/*` внутри остаётся абсолютным (оттуда приходит `50-systemd-user.conf`). Стоковый `bar { ... }` (swaybar) удалён, его роль играет waybar.
- Оформление как в bspwm: `default_border pixel 2` / `default_floating_border pixel 2` — у окна только рамка без заголовка; `gaps inner 0`, `gaps outer 0` (внешние не нужны, место под панель резервирует layer-shell), `smart_borders on` (рамка только когда окон несколько); `client.focused #6b8dd6`, `client.unfocused`/`focused_inactive` `#1a1b26` (фон Tokyo Night, рамка сливается с окном и панелью). В режиме `pixel` рамку рисует `child_border`, поэтому он продублирован в каждом `client.*`. `focus_follows_mouse no`, `mouse_warping none` — как в bspwm.
- `local/bin/sway-session` — обёртка запуска вместо `sway`: PATH (`~/.local/bin`, `~/.npm-global/bin`), `XDG_*` сессии (`sway`/`wayland`), курсор `Bibata-Modern-Ice` 24, Qt (`qt6ct`, `QT_QPA_PLATFORM=wayland;xcb`), GTK (`GDK_BACKEND=wayland,x11`), `SAL_USE_VCLPLUGIN=gtk3`, `MOZ_ENABLE_WAYLAND`, Electron и Java; затем `exec sway "$@"`. В systemd/dbus эти переменные импортирует уже сам Sway (`config/sway/config`, строка `dbus-update-activation-environment --systemd --all`). `GTK_THEME` не задаёт — тему дают `settings.ini` и `gtk.css`.
- Запуск: из TTY — `sway-session`; из GDM — `./scripts/install-sway.sh --session` (GDM читает только `/usr/share/wayland-sessions`, пользовательские каталоги сессий не сканирует, поэтому файл создаётся с sudo и абсолютным `Exec`).
- `local/bin/sway-display` — мониторы и обои. В конфиге Sway нет условий по hostname, поэтому ветвление `lamer-deb` (DP-2 1920x1080@144 + HDMI-A-4 слева с `transform 90`, portrait-обои) и фолбэк ноутбука (`output *` + landscape) живут в скрипте. Имена выходов в Sway отличаются от X11: там же, где `xrandr` видит `DisplayPort-1`/`HDMI-A-3`, wlroots показывает `DP-2`/`HDMI-A-4`. Вызывается как `exec_always`, поэтому раскладка переприменяется при reload; обои ставит сам sway через `output ... bg` (спавнит и убивает `swaybg`). Скрипт ждёт готовности IPC, потому что `exec` при старте может опередить `swaymsg`.
- Автозапуск: `exec_always pgrep -x waybar >/dev/null || waybar`, то же для `mako`, `lxpolkit`; `swayidle` (10 минут и перед сном → `swaylock -f`) — reload не плодит дубли. История буфера: `wl-paste --watch cliphist -max-items 100 store` под тем же `pgrep`-стражем.
- Хоткеи повторяют bspwm там, где это осмысленно: `$mod+Return` — `foot`, `$mod+d` — `wofi --show drun`, `$mod+/` — `sway-cheatsheet`, `$mod+F1..F4` и `$mod+Shift+S` — `sway-screenshot`, `$mod+Shift+A` — редактор скриншота (`sway-screenshot annotate` → swappy), `$mod+Shift+R` — запись всего экрана, `$mod+Shift+Alt+R` — запись области (`sway-record`, повторное нажатие останавливает), `$mod+Shift+V` — история буфера (`wofi-clipboard`), `$mod+Escape` — reload, `$mod+w` — kill, `$mod+Alt+L` — `swaylock -f`, `$mod+Alt+N` — `wofi-wifi`, `$mod+Alt+B` — `wofi-battery`, `$mod+Shift+Q` — `wofi-powermenu`, `$mod+Shift+E` — выход через `swaynag`. Профиль питания переключается кликом по модулю `power-profiles-daemon` в waybar (свой `wofi-power-profile` убран как дубль). `Alt+Tab` и `sway-switch` убраны: список окон дублировал то, что Sway делает сам. Preselect/monocle/picom-аналогов нет.
- Раскладка `us,ru` с `grp:caps_toggle` и автоповтором 250/30 задана через `input "type:keyboard"`; сам Caps Lock включается через Shift+Caps Lock (штатное поведение опции), поэтому индикатор Caps в waybar рабочий. Тачпад — `tap`, `dwt` и `natural_scroll enabled` (как `NaturalScrolling` в X11: пальцы вверх — страница вниз).
- Все `bindsym` объявлены с `--to-code`: Sway переводит keysym в keycode по первой раскладке (`us`), поэтому хоткеи и вызовы wofi (`Super+d`, `Super+Alt+n` и остальные) срабатывают и в русской раскладке. Без флага keysym привязан к текущей раскладке и в RU-режиме не совпадает.
- Применение: `Super+Escape` или `Super+Shift+C` (`swaymsg reload`). `~/.config/sway` — симлинк, правки сразу в репозитории.
- `home/xinitrc` и `home/xprofile` под Wayland не выполняются: их переменные перенесены в `sway-session` (сессия из TTY) или в `--session`-обёртку из GDM.

### Sway: порталы (OBS, демонстрация экрана, ScreenCast)

Скриншоты по хоткеям (`sway-screenshot`) снимаются напрямую через `grim` и
`slurp` и портал не используют. Через `xdg-desktop-portal` +
`xdg-desktop-portal-wlr` и PipeWire идёт запись/демонстрация экрана (OBS) и
запросы `Screenshot` от сторонних приложений. Отдельный
`graphical-session.target` для этого не нужен: портал запускается по D-Bus
при первом запросе. Ломается цепочка из-за окружения — у
`xdg-desktop-portal-wlr.service` стоит `ConditionEnvironment=WAYLAND_DISPLAY`,
а `systemd --user` не знает переменных Sway, пока их туда не импортируют.
Тогда юнит молча пропускается (`inactive (dead)`), и в OBS нет источника
ScreenCast.

1. **Окружение в systemd/dbus.** `config/sway/config` при старте выполняет
   `exec sh -c 'command -v dbus-update-activation-environment >/dev/null && dbus-update-activation-environment --systemd --all'`: в systemd и
   dbus попадают `WAYLAND_DISPLAY`, `SWAYSOCK`, `DISPLAY`,
   `XDG_CURRENT_DESKTOP` и переменные тем/курсора из `sway-session`.
   Штатный `/etc/sway/config.d/50-systemd-user.conf` делает то же для
   четырёх переменных; строка в конфиге нужна, если файла нет (сборка не
   из пакета). Проверка: `systemctl --user show-environment | grep WAYLAND`
   должен показать `WAYLAND_DISPLAY=wayland-1`.

2. **`config/xdg-desktop-portal/portals.conf`** → `~/.config/xdg-desktop-portal/portals.conf`.
   `xdg-desktop-portal` умеет выбирать бэкенд сам (через `UseIn` и
   `sway-portals.conf` из пакета), но в системе может стоять
   `xdg-desktop-portal-hyprland`, чей `.portal` тоже заявляет `sway` в
   `UseIn`. Конфиг явно направляет ScreenCast/Screenshot на wlr, остальное —
   на gtk:

   [preferred]
   default=gtk
   org.freedesktop.impl.portal.ScreenCast=wlr
   org.freedesktop.impl.portal.Screenshot=wlr

   `default=wlr` использовать нельзя: `xdg-desktop-portal-wlr` реализует
   только ScreenCast и Screenshot, остальные функции (файловые диалоги,
   уведомления) перестанут работать.

3. **OBS должен быть Wayland-клиентом.** `QT_QPA_PLATFORM="wayland;xcb"` из
   `sway-session` для OBS работает. Если запускать OBS из терминала без
   переменной, он уйдёт в XWayland и источник ScreenCast не заработает.

4. **`slurp`** — не жёсткая зависимость пакета `xdg-desktop-portal-wlr` в
   Debian, но без него портал не показывает диалог выбора монитора.
   Пакет есть в `requirements/sway.txt`.

Проверка портала без OBS:

```bash
systemctl --user is-active xdg-desktop-portal-wlr
gdbus call --session --dest org.freedesktop.portal.Desktop \
    --object-path /org/freedesktop/portal/desktop \
    --method org.freedesktop.DBus.Properties.Get \
    org.freedesktop.portal.ScreenCast version
```

Первая команда после запроса должна вернуть `active`, вторая — версию
интерфейса (например, `(<uint32 5>,)`). Если `wlr` не стартует, смотреть
`systemctl --user status xdg-desktop-portal-wlr` — чаще всего это
`unmet condition check ConditionEnvironment=WAYLAND_DISPLAY`.

### Sway: запись экрана и буфер обмена

- `local/bin/sway-record {full|region}` — запись через `wf-recorder` (пакет
  из `requirements/sway.txt`), не через портал: wlr-screencopy работает
  напрямую и OBS не мешает. Повторный вызов **любого** режима останавливает
  текущую запись: mp4 корректно закрывается только по `SIGINT`, поэтому в
  скрипте `pkill -INT -x wf-recorder`, а не `kill`. Один хоткей на старт и
  стоп, как `screenshot` в X11.
- Файлы — `~/Videos/Screencasts/YYYY-MM-DD_HH-MM-SS.mp4`. Хоткеи:
  `Super+Shift+R` — весь экран, `Super+Shift+Alt+R` — область (геометрия из
  `slurp`, Esc — отмена). Область округляется вниз до чётных сторон:
  `libx264` и VAAPI не принимают нечётные размеры, а slurp может дать 101x101.
- Звук — всегда, но это **монитор текущего выхода** (системный звук), а не
  `-a`: `-a` берёт источник по умолчанию, а на этой машине это веб-камера
  `icspring camera`. Скрипт читает `node.name` через
  `wpctl inspect @DEFAULT_AUDIO_SINK@` и передаёт
  `--audio="<sink>.monitor"`; если sink не определился — фолбэк на `-a`.
- Кодек — `h264_vaapi` только для полного экрана и только на
  `amdgpu`/`i915`/`xe` (драйвер `renderD128`): `-d /dev/dri/renderD128`
  плюс `-F scale_vaapi=format=nv12`. На NVIDIA и прочих — `libx264`.
  Область всегда `libx264`: VAAPI у AMD не умеет меньше 128x128
  (`Hardware does not support encoding at size 112x112`) и падает на
  маленьком выделении, а `libx264` пишет любой размер. Размер кадра
  дополнительно ужимается до чётного.
- `local/bin/sway-screenshot annotate` — редактор: берёт из буфера картинку
  (`wl-paste --list-types` → первый `image/*`) и открывает `swappy -f -`.
  Работает после любого режима скриншота, потому что все они кладут PNG в
  буфер. Если в буфере текст — уведомление «В буфере нет изображения» и
  выход 1. Хоткей `Super+Shift+A`.
- `config/swappy/config` → `~/.config/swappy`: `save_dir=$HOME/Screenshots`
  (тот же каталог, что у `sway-screenshot`), формат имени с датой, панель
  инструментов, `text_font=JetBrainsMono Nerd Font 11`, `early_exit=false`
  (можно и сохранить, и скопировать). Инструменты swappy: `b` кисть,
  `t` текст, `r` прямоугольник, `o` эллипс, `a` стрелка, `d` блюр;
  Ctrl+S — сохранить, Ctrl+C — в буфер, Esc — выход.
- `local/bin/wofi-clipboard` — история буфера: `cliphist list` → `wofi
  --dmenu --cache-file /dev/null` → `cliphist decode <id> | wl-copy`.
  Хоткей `Super+Shift+V`. Под Wayland CopyQ не используется (нестабилен,
  стартует только из `bspwmrc`); в BSPWM остаётся CopyQ.
- `cliphist` хранит последние 100 записей (`-max-items 100` — глобальный
  флаг **до** подкоманды `store`, иначе не разберёт). Превью в `list`
  обрезается до 100 символов, но `decode` отдаёт запись целиком: блок кода
  на 1500+ строк вставляется полностью. `cliphist wipe` очищает историю.
  Пароли и токены туда тоже попадают — `wl-clipboard` не помечает их
  sensitive; это принято осознанно.
- Индикатора REC в waybar нет: стокового модуля записи не существует, а
  `custom/recording` с `exec-if=pgrep` — лишний костыль. Статус виден по
  уведомлению mako при старте/стопе.
- Применение: `swaymsg reload` (хоткеи, watcher). `swappy` читает конфиг
  при старте; у `wf-recorder` своего конфига нет — всё передаёт скрипт.

### Foot (Sway)
- `config/foot/foot.ini` → `~/.config/foot`. Терминал Sway, аналог `config/alacritty`: `JetBrainsMono Nerd Font:size=10`, `pad=0x0` (внутренних отступов нет), `initial-window-size-chars=100x28`, `shell=/usr/bin/fish`, буфер 10000 строк.
- Палитра та же, что в Alacritty (Tokyo Night), `alpha=1.0` — прозрачности нет. Секция `[csd] preferred=none` + `size=0`/`border-width=0`: рамку рисует Sway, иначе получается двойная обводка.
- Живого перечитывания нет: правка действует со следующего запуска. Проверка синтаксиса — `foot -C -c ~/.config/foot/foot.ini`.

### Swaylock (Sway)
- `config/swaylock/config` → `~/.config/swaylock`. Swaylock 1.8.2 сам читает этот путь, поэтому все вызовы — `swaylock -f` (`swayidle` на 10 минут и `before-sleep`, хоткей `Super+Alt+L`, `wofi-powermenu`).
- Обои — те же, что ставит `sway-display`: `image=` без выхода даёт горизонтальные `wallpapers/tokyo-night-girl-landscape.jpg` всем мониторам, `image=HDMI-A-4:$HOME/.../tokyo-night-girl-portrait.jpg` — вертикальные для повёрнутого HDMI-A-4 на `lamer-deb` (в Sway тот же порт, что X11 зовёт HDMI-A-3, называется HDMI-A-4). `select_image()` берёт образ с точным именем выхода, иначе последний образ без имени, поэтому порядок строк не важен. `scaling=fill` совпадает с `bg ... fill`; `color=1a1b26` — заглушка, если файл не найдётся.
- Стиль Tokyo Night: при вводе кольцо синее `#7aa2f7`, набранные символы оранжевые `#ff9e64`, стёртые (backspace) — красные `#f7768e`, разделители тёмные `#1a1b26`; внутри полупрозрачный `#1a1b26d9` (`line-uses-inside` убирает обводку). Состояния: пустой ввод — `#565f89`, проверка — `#bb9af7`, ошибка — `#f7768e`, Caps Lock — `#e0af68`. `show-keyboard-layout` показывает us/ru при наборе.
- Индикатор: `indicator-radius=90`, `indicator-thickness=8`, `font-size=20`, `JetBrainsMono Nerd Font`; в покое скрыт.
- Цвета в конфиге пишутся **без `#`**: строка, начинающаяся с решётки, считается комментарием, а inline-комментарии не поддерживаются. Ошибки парсинга swaylock не печатает — проверять `swaylock -C config/swaylock/config -d` в сессии Sway.

### Alacritty
- Шрифт: `JetBrainsMono Nerd Font`, `size = 10`; прозрачность `opacity = 1` — прозрачность в проекте отвергнута.
- Тёмная тема Tokyo Night: фон `#1a1b26`, текст `#c0caf5`. `live_config_reload = true` — правки применяются без перезапуска.

### GTK3 / GTK4
- `config/gtk-3.0/gtk.css` — полный пользовательский CSS поверх `Adwaita-dark`: `@define-color` для именованных цветов + прямые селекторы по виджетам.
- `config/gtk-4.0/gtk.css` — только переменные libadwaita (`:root` с `--*-color`) и слой `@define-color` для совместимости; прямых селекторов нет.
- `config/gtk-3.0/gtk-light.css` и `config/gtk-4.0/gtk-light.css` — светлые варианты один-в-один: те же селекторы, свойства и переменные, отличается только палитра (Tokyo Night Day: фон `#e1e2e7`, поверхности `#f4f5f9`, текст `#3760bf`, акцент `#2b6fd4`). Светлая палитра рассчитана на базис `Adwaita`, а не `Adwaita-dark`, поэтому переключение — это подмена CSS плюс смена базовой темы.
  - Включить светлую: `cp config/gtk-3.0/gtk-light.css config/gtk-3.0/gtk.css`, `cp config/gtk-4.0/gtk-light.css config/gtk-4.0/gtk.css`, `gsettings set org.gnome.desktop.interface gtk-theme Adwaita`, `gsettings set org.gnome.desktop.interface color-scheme default`, `gsettings set org.gnome.desktop.interface icon-theme Papirus`. Затем перезапустить приложения.
  - Вернуть тёмную: `git checkout -- config/gtk-3.0/gtk.css config/gtk-4.0/gtk.css`, `gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark`, `gsettings set org.gnome.desktop.interface color-scheme prefer-dark`, `gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark`.
  - Иконки: `Papirus-Dark` — это светлые символы для тёмного фона, на светлой теме они пропадают; светлому варианту нужен `Papirus` (то же и в Qt, `icon_theme`).
  - `~/.config/gtk-3.0` и `~/.config/gtk-4.0` — симлинки на репозиторий, поэтому `cp` пишет прямо в отслеживаемый `gtk.css`; `git checkout` возвращает тёмный файл. Автопереключения по системной теме нет (см. «Отвергнуто» в `TODO.md`).
- `gtk-theme-name` в `settings.ini` не меняется (`Adwaita-dark`). Базовую тему под Wayland задаёт gsettings, а в X11-сессии `xsettingsd` нет и её берёт `settings.ini` — проверено: при `gsettings gtk-theme Adwaita` GTK3 на Wayland отдаёт `Adwaita`, на X11 — `Adwaita-dark`. Поэтому светлая тема в BSPWM дополнительно требует правки `gtk-theme-name` в обоих `settings.ini`. Меняются только цвета: геометрия, отступы и размеры — штатные от Adwaita.
- Курсор берётся из gsettings (`org.gnome.desktop.interface cursor-theme` / `cursor-size`), а не из `settings.ini`: dconf перекрывает файл, а GTK4 значения оттуда не подхватывает. `link.sh` выставляет `Bibata-Modern-Ice` 24 — тот же курсор, что `XCURSOR_THEME` / `XCURSOR_SIZE` в `xinitrc` и `sway-session`. Без этого GTK-приложения (LibreOffice Writer) рисуют стоковый Adwaita, пока Sway и XWayland показывают Bibata, и курсор «скачет» между ними.
- Приложения без libadwaita (тема `Default`) читают только `@define-color`-имена; полной перекраски там нет.
- GTK3: Adwaita рисует `background-image` / `box-shadow` в hover/active/checked/disabled/backdrop — в user CSS их надо сбрасывать явно, иначе остаются светлые пятна.
- GTK3: фон infobar — на `infobar > revealer > box`, а не на самом `infobar`. Toolbar/searchbar (`searchbar > revealer > box`, `.toolbar`) по умолчанию серые (`#353535` / `#2d2d2d`).
- GTK3: rubberband рисуется контекстом виджета с классом `.rubberband`; фон `.view` его перекрывает, поэтому нужны отдельные правила `.rubberband` (заливка `rgba(122,162,247,0.2)`, рамка `rgba(122,162,247,0.6)`).
- GTK3: строки списков стилизуются и через `row:selected`, а не только `row.activatable:selected`: у `Gtk.ListBoxRow` без `activatable` второго класса нет.
- Рамка `window.csd` в Adwaita — белый `outline` с прозрачностью; bspwm не ставит окну класс `tiled`, поэтому `window.csd.tiled` не матчится.
- Иконки Papirus-Dark имеют собственный светлый цвет (`#dfdfdf`) — это не баг темы.
- Применение: перезапуск приложения. Симлинки `~/.config/gtk-3.0`, `gtk-4.0` уже стоят; Flatpak видит CSS после повторного `link.sh`.

### GIMP
- `config/GIMP/3.0/themes/TokyoNight/` уезжает в `~/.config/GIMP` вместе с папкой (симлинк целого `config/GIMP`). GIMP 3 читает тему на старте, переключение — Preferences → Interface → Theme.
- Тема переопределяет именованные цвета тёмной темы GIMP (`fg-color`, `bg-color`, `border-color` и т.д.), от системной GTK-темы не зависит.

### Fastfetch
- `config/fastfetch/graphical.jsonc` — для X11, `tty.jsonc` — для консоли. `config.fish` выбирает конфиг по `$TERM` (`linux` → TTY-вариант).

### Qt (qt5ct / qt6ct)
- `config/qt5ct/colors/tokyo-night.conf`, `config/qt6ct/colors/tokyo-night.conf` — 21 роль `QPalette` в порядке enum, формат цвета `#AARRGGBB`.
- `tokyo-night-day.conf` в обеих папках — светлый вариант один-в-один: те же 21 роль, палитра Tokyo Night Day (окно `#e1e2e7`, база/поля `#e1e2e7`, текст `#3760bf`, акцент `#2b6fd4`, текст на акценте `#ffffff`). Роли Fusion перевёрнуты по яркости: `Light` `#ffffff` > `Midlight` `#f4f5f9` > `Button` `#dfe2eb` > `Mid` `#c6ccdb` > `Dark` `#bcc4d6`, иначе объёмная рамка Fusion рисуется наоборот.
  - Включить светлую: `sed -i 's|tokyo-night.conf|tokyo-night-day.conf|' config/qt5ct/qt5ct.conf config/qt6ct/qt6ct.conf` и `icon_theme=Papirus` там же (у `Papirus-Dark` символы светлые и на светлом фоне пропадают). Вернуть тёмную — `git checkout -- config/qt5ct/qt5ct.conf config/qt6ct/qt6ct.conf`.
  - В GUI то же самое: `qt5ct` / `qt6ct` → Appearance → Color scheme.
  - Цвет текста прогресс-бара Fusion берёт из `ButtonText`, а не из `HighlightedText`, поэтому на светлой заливке подпись синяя — так же, как в тёмной теме, отдельной роли под это в `QPalette` нет.
- `qt5ct.conf` / `qt6ct.conf`: `color_scheme_path=~/.config/qt<5|6>ct/colors/tokyo-night.conf`, `custom_palette=true`, `style=Fusion`, `icon_theme=Papirus-Dark`.
- `home/xinitrc`: `export QT_QPA_PLATFORMTHEME=qt6ct` (Qt5-приложения тоже идут через qt6ct).
- Применение: `qt5ct` / `qt6ct` или перезапуск приложения (палитра читается при старте).

### Flatpak и темы
- `link.sh` при наличии Flatpak выдаёт override'ы: read-only доступ к `xdg-config/gtk-3.0`, `gtk-4.0`, `xdg-config/qt5ct`, `qt6ct`, `xdg-data/themes` и `QT_QPA_PLATFORMTHEME=qt5ct`.
- Flatpak-приложения видят пользовательские CSS/палитры только после повторного запуска `link.sh`.

### CopyQ
- `config/copyq/themes/tokyo-night.ini` — тема Tokyo Night. В git также трекаются `copyq.conf` и `copyq-commands.ini`.
- Остальное содержимое `config/copyq/` (история, lock-файлы, geometry) игнорируется через `.gitignore`.
- Автозапуск в `bspwmrc`: `copyq --start-server` (без окна), меню — `copyq menu` по хоткею.

### EasyEffects
- `config/easyeffects/output/*.json` — пресеты эквалайзера/эффектов.
- Автозапуск в `bspwmrc`: `easyeffects --gapplication-service`, только если бинарник установлен.

### Cava
- `config/cava/config` → `~/.config/cava/config`. Пакет `cava` — в `requirements/software.txt`, вход не задан: cava сам выбирает PipeWire первым.
- `framerate = 60` — отклик около 16 мс. `noise_reduction` управляет только спадом: 0 — дёргается, 100 — «желе»; 40 — резче дефолтных 77, но без дрожания.
- `bars = 0`, `bar_width = 2`, `bar_spacing = 1` — число столбиков подстраивается под ширину терминала.
- `channels = mono` — один спектр по всей ширине: низкие частоты слева, высокие справа. `stereo` зеркалит каналы и ставит низкие в центр — для этой раскладки не подходит.
- `method = noncurses` + `synchronized_sync = 1` — без мерцания и расслоения; `show_idle_bar_heads = 1` рисует точки на нулевой линии в тишине.
- Градиент по высоте: `#7aa2f7` → `#7dcfff` → `#bb9af7` → `#f7768e`, фон `#1a1b26`.
- Применение: перезапуск `cava` (конфиг читается при старте).

### Btop
- `config/btop/` → `~/.config/btop`: `btop.conf` и `themes/tokyo-night.theme`. Пакет `btop` — в `requirements/software.txt`.
- `color_theme = "tokyo-night"` — btop ищет тему по имени (stem) в `~/.config/btop/themes` и в системном каталоге; пользовательский каталог проверяется первым, поэтому системный путь не хардкодится.
- Палитра как в Polybar/Waybar: `main_bg #1a1b26`, `main_fg #c0caf5`, `title #7aa2f7`, `hi_fg #7dcfff`, `inactive_fg #565f89`, `meter_bg #24283b`, рамки `#565f89`, `div_line #3b4261`.
- Градиенты: CPU и processes `#7aa2f7` → `#bb9af7` → `#f7768e`; температура и used `#9ece6a` → `#e0af68` → `#f7768e`; free/available наоборот (красный при нехватке, зелёный при запасе); cached и download — голубой → синий → фиолетовый.
- `btop.conf` — пользовательские настройки раскладки и процессов; при выходе btop перезаписывает файл сам, поэтому правки вносятся через меню `F2` или в репозитории.
- Применение: перезапуск `btop` (конфиг и тема читаются при старте).

### Telegram
- `themes/telegram/tokyo-night.tdesktop-palette` — тема Tokyo Night с оранжевым акцентом. Хранится вручную, автоматической установки нет (чтобы не ломать пути Flatpak).
- Установка: положить файл в `~/.var/app/org.telegram.desktop/data/TelegramDesktop/tdata/theme/` и выбрать в настройках Telegram.

### Midnight Commander
- Скины лежат в `local/share/mc/skins/` → `~/.local/share/mc/skins/`.
- Формат INI: секции `[core]`, `[dialog]`, `[menu]`, `[filehighlight]`, `[editor]`, `[viewer]` и т.д.
- Цвета в формате `foreground;background` через точку с запятой (например, `white;blue`).

### Fish/Tide
- Fisher — менеджер плагинов (устанавливается автоматически).
- Tide — промпт (устанавливается как v6).
- Сгенерированные файлы (`fish_variables`, `conf.d/_tide_*.fish`, `functions/`, `completions/`) в git не коммитить.

### Bash-промпт
- Промпт вынесен из `home/bashrc`: пресеты лежат в `config/bash/themes/` → `~/.config/bash/themes/`, подключаются через `.` (не исполняемые, режим 644).
- `home/bashrc` только выбирает файл: `BASH_PROMPT="${BASH_PROMPT:-tokyo-night}"`; нет файла — фолбэк `PS1='\u@\h:\w\$ '`.
- `tokyo-night.bash` — текущий промпт (Debian → папка → git → стрелка), `PROMPT_COMMAND=prompt_command`, заголовок окна выставляется там же.
- `tokyo-night-minimal.bash` — статичный `PS1` без `PROMPT_COMMAND` и вызовов `git`; весь код — в одной строке, только цвета.
- `empty.bash` — шаблон для своей темы: пустой `PS1='\u@\h:\w\$ '` плюс закомментированные варианты (цвет, динамический `prompt_command`, заголовок окна). Начинать новую тему с копии этого файла.
- Промпт в git-репозитории делает 2–5 вызовов `git` на каждый ввод — это основная цена; сам sourcing темы незаметен. Если нужна скорость — `tokyo-night-minimal`.
- Новая тема: файл `config/bash/themes/<имя>.bash`, который выставляет `PS1` (и при необходимости `PROMPT_COMMAND`); ничего больше править не надо. `empty.bash` обнуляет `PROMPT_COMMAND`, чтобы при `source ~/.bashrc` не осталась функция прошлой темы.
- Применение: новый шелл (`exec bash`) или `source ~/.bashrc`.

### Node.js / npm
- `scripts/install-node.sh` ставит NodeSource LTS и пишет `prefix=~/.npm-global` в `~/.npmrc`: `npm i -g` работает без sudo.
- PATH до `~/.npm-global/bin` добавляют оба шелла — `config/fish/config.fish` и `home/bashrc` (блоки идемпотентны, дублей не создают).
- NVM, если установлен, подключается в конце `home/bashrc` и может переопределить `node`/`npm` из NodeSource.

### Neovim
- `config/nvim` → `~/.config/nvim`. Конфиг на Lua, менеджер плагинов — встроенный `vim.pack` (Neovim 0.12), список только в `lua/plugins.lua`. Шпаргалка по хоткеям — `config/nvim/CHEATSHEET.md`.
- `nvim-pack-lock.json` версионируется вместе с конфигом. Обновление плагинов: `:lua vim.pack.update()`, затем `:restart`. Lock-файл руками не править.
- Плагины: tokyonight (тема), nvim-treesitter (ветка main), lspconfig + Mason, blink.cmp, neo-tree (+ plenary, nui, devicons), gitsigns, telescope, lualine, which-key.
- LSP: Mason (`:Mason`) + нативный `vim.lsp.config` / `vim.lsp.enable`. Серверы: lua_ls, bashls, pyright, ts_ls, clangd, rust_analyzer, jsonls, yamlls, html, cssls, emmet_language_server, intelephense. `gopls` отложен: Go в системе не установлен.
- Treesitter требует `tree-sitter` CLI ≥ 0.26.1 (Debian-пакет старый). `install.sh` кладёт бинарник в `~/.local/bin/tree-sitter`. Парсеры ставятся автоматически при первом запуске, обновление — `:TSUpdate`.
- Telescope ищет файлы и текст через `ripgrep` (есть в `requirements/software.txt`). Без `rg` команды `find_files` / `live_grep` не работают. `fd` не нужен.
- Тема — `tokyonight-night`: фон `#1a1b26`, текст `#c0caf5`. Оверрайды сайдбара и статуслайна — в `lua/theme.lua`.
- Leader — пробел. `<leader>e` — сайдбар, `<leader>ff` / `fg` / `fb` / `fh` — поиск, `<C-h/j/k/l>` — окна (в т.ч. из сайдбара в редактор), `<S-h>` / `<S-l>` — буферы, `<leader>q` — выйти из всех окон (`:qa`), `<C-\>` — встроенный терминал, `gd` / `gr` / `K` — LSP, `<leader>ca` / `rn` / `f` — действия/переименование/формат, `]c` / `[c` — git-хунки. Всё остальное — стоковые команды.
- Вкладки — это буферы: полоска сверху рисуется lualine (`tabline.buffers`), клик/`<S-h>`/`<S-l>`/`<leader>fb` — переключение.
- `:bd` / `:bd!` и `:q` / `:wq` — стоковые команды, конфиг их не переопределяет. `:q` закрывает только текущее окно, `:bd` — буфер вместе с его окном; Neovim при этом не выходит. Выйти целиком — `<leader>q` / `:qa`.
- Сайдбар: `window.width = 32` + `winfixwidth`, файлы открываются справа. В Vim единственное окно занимает весь экран, поэтому в `explorer.lua` есть обработчик `WinClosed`: когда закрывается последнее окно с файлом, справа создаётся пустая рабочая область (`vnew`, `buflisted = false`), а сайдбару возвращается ширина 32. Если закрывается сама пустая область через `:q` (`QuitPre`), Neovim выходит; `:bd` не выходит.
- Кастомных модулей буферов нет: `lua/buffers.lua` удалён, `cnoreabbrev` убран.
- Первый запуск требует сеть: `vim.pack` качает плагины, Mason — серверы в `~/.local/share/nvim/mason/bin`.
- Применение: правка Lua-файлов — со следующего запуска (или `:source %` для текущего файла); плагины обновляются только вручную.

### Vim
- `home/vimrc` → `~/.vimrc`. Обычный Vim 9.1 из `requirements/apt.txt`, без плагинов и менеджеров: только настройки и один блок автокоманд для типов файлов.
- Подсветка: `syntax on` + `filetype plugin indent on`. Тема не задаётся — цвета берутся из палитры терминала (в Alacritty это Tokyo Night). `termguicolors` и `colorscheme` намеренно не включаются.
- Нумерация гибридная: `set number relativenumber` (на строке курсора — абсолютный номер, вокруг — относительные) + `cursorline` с `cursorlineopt=number`.
- Отступы: 4 пробела по умолчанию, 2 для json/yaml/html/css/scss/js/ts/vue, табы для make.
- `undofile` в `~/.vim/undo` (каталог создаётся при загрузке vimrc). Swap-файлы остаются стоковыми.
- Хоткеи: `<Esc>` снимает подсветку поиска, `<C-h/j/k/l>` — переход между окнами, `<` / `>` в визуальном режиме сохраняют выделение.
- Типы файлов: `sxhkdrc`, `bspwmrc`, `xinitrc` → sh; `dunstrc`, `*.tdesktop-palette` → dosini; `picom*.conf`, `qt5ct.conf`, `qt6ct.conf`, `NetworkManager.conf`, `copyq*.conf` → dosini через `setlocal filetype` (Vim по умолчанию считает их generic `conf`). `*.conf` без правил Vim показывает как `conf`, `*.toml` / `*.jsonc` / `*.rasi` распознаёт сам.
- Применение: `:source ~/.vimrc`. Новый файл подхватывается `link.sh`.

### .gitignore
Whitelist: отслеживаются только `config/ home/ local/ requirements/ system/ scripts/ screenshots/ themes/ wallpapers/` и корневые `README.md`, `README.ru.md`, `RELEASE.md`, `LICENSE*`, `TODO.md`, `AGENTS.md`, `.gitignore`. Новые файлы/папки в корне молча игнорируются, пока не добавлены в `.gitignore`.

### Системные конфиги
- `system/etc/**` → копируется в `/etc/**` с бэкапом в `/etc/dotfiles-backup-YYYYMMDD-HHMMSS`.
- Логин при закрытии крышки: `suspend` (через `/etc/systemd/logind.conf.d/10-lid-suspend.conf`).
- Audio backend: `requirements/apt.txt` ставит `pipewire`, `pipewire-audio`, `pipewire-pulse`, `wireplumber`. Автоматического удаления PulseAudio в скриптах нет.
- `requirements/apt-system.txt` (`power-profiles-daemon`, `flatpak`) читается `install.sh`; TLP при наличии удаляется, чтобы не конфликтовать с PPD.

## Персонализация — не обобщать молча

### Hostname-специфичные ветвления
- `bspwmrc` и команда `wifi` проверяют `hostname` (`lamer-deb`, `travelmate`, `lx15pro`, `lx15pro-deb`).
- `bspwmrc` — запуск OpenRGB (только для ПК `lamer-deb`).

### Мониторы и интерфейсы
- Жёстко заданные имена мониторов: `DisplayPort-1`/`HDMI-A-3` в X11 (`bspwmrc`) и `DP-2`/`HDMI-A-4` в Sway (`sway-display`, `swaylock`).
- Жёстко заданные имена Wi-Fi интерфейсов в `local/bin/wifi`.

### Обои
Пути к обоям в `bspwmrc` захардкожены как `$HOME/BSPWM-machineslego/wallpapers/` — клон в другом каталоге ломает обои.

## Устаревшее / неиспользуемое

- `wallpaper.sh` удалён: обои ставятся статичными `feh` в `bspwmrc`, выборщик отвергнут (см. `TODO.md`). Не возвращать без просьбы.
- `TODO.md` — рабочий блокнот, а не документация релиза; там же «Отвергнуто» и «Известные ограничения».
- Документация — на русском; `README.md` и `README.ru.md` держать синхронными (оба обновляются одновременно).
- AGENTS.md — внутренняя инструкция, не публикуется.

## Дальние планы

- Sway/Wayland — направление переезда: окружение переносится постепенно, а BSPWM/X11 остаётся рабочей сессией на случай поломок Wayland. Прежнее решение «на Wayland не переезжаем» отменено.
- `1.8.0` выпущен; следующая — `1.9.0`.

## Релизы

- Тег — аннотированный, `vX.Y.Z` (все прошлые теги с `v`). Ветка одна — `main`.
- `RELEASE.md` в корне — заметки к **текущему** релизу, а не история: файл полностью переписывается под каждый тег, старые релизы живут на GitHub.
- Формат как в прошлых релизах: первая строка `vX.Y.Z — Название` (по-английски), английский блок, `---`, русский блок. Заголовок GitHub-релиза вводится отдельно, поэтому H1 в файле не ставим.
- Публикация: `git tag -a vX.Y.Z -m "..."` → `git push origin main --tags` → на GitHub «Draft a new release» → выбрать тег → вставить всё содержимое `RELEASE.md` в описание.
- Семантика: PATCH — только исправления, MINOR — новые функции, MAJOR — ломающие изменения. В `RELEASE.md` держим только то, что видит пользователь, без пересказа коммитов.
- `RELEASE.md` добавлен в whitelist `.gitignore`; без этого корневые файлы молча игнорируются.
- Тег и `git push` — только по явной просьбе. Мусорные теги без `v` (например `list`, `push`) ломают `git describe`; удалять `git tag -d <имя>`.

## Проверка

- Тестов нет.
- `rice-check` — состояние райса и дотфайлов: симлинки на репозиторий, команды и пути из `sxhkdrc`, `bash -n`, картинки README. Код возврата 0/1, запуск по требованию.
- Синтаксис скриптов: `bash -n <script>`.
- Конфиги проверяются только перезапуском соответствующего компонента/сессии.
- Перед завершением — `git status`; не коммитить `~/.dotfiles-backup-*` и сгенерированные файлы (Fish/Tide, history).
