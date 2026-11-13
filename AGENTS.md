# AGENTS.md

Dotfiles + установщик BSPWM-окружения для Debian 13 Trixie (X11, Tokyo Night).
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
- `scripts/link.sh` — идемпотентный линковщик: делает бэкап в `~/.dotfiles-backup-*`, ставит симлинки (конфиги, home-файлы, команды в `~/.local/bin`, скины MC). Меняет уже установленные пакеты.
- `scripts/unlink.sh` — безопасное удаление симлинков, созданных link.sh (только свои, не трогает чужие): `~/.config/*`, home-файлы, `~/.local/bin`, скины MC.
- `scripts/software.sh` — установка дополнительного софта из `requirements/software.txt` (lazygit, ripgrep, mpv, gimp и т.д.). Запускается отдельно, install.sh только печатает подсказку.
- `scripts/install-node.sh` — Node.js LTS из NodeSource, npm с prefix `~/.npm-global` (глобальные пакеты без sudo). Запускается отдельно, не из install.sh.

Не запускай `install.sh` и `unlink.sh` без явной просьбы. `link.sh` — безопасен для запуска в любое время.

### Права на файлы
Скрипты и команды в git имеют режим 755; новые файлы в `local/bin/` и `*.sh` тоже должны быть executable (`chmod +x`). `link.sh` выставляет `+x` при линковке.

### Команды и хелперы
- Пользовательские команды — в `local/bin/` → `~/.local/bin` (PATH): `battery`, `cheatsheet`, `dunst-history`, `powermenu`, `power-profile`, `screenshot`, `session-restart`, `volume`, `wifi`. Без расширения `.sh`, с шебангом.
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

### Alacritty
- Шрифт: `JetBrainsMono Nerd Font`, `size = 10`; прозрачность `opacity = 1` — прозрачность в проекте отвергнута.
- Тёмная тема Tokyo Night: фон `#1a1b26`, текст `#c0caf5`. `live_config_reload = true` — правки применяются без перезапуска.

### GTK3 / GTK4
- `config/gtk-3.0/gtk.css` — полный пользовательский CSS поверх `Adwaita-dark`: `@define-color` для именованных цветов + прямые селекторы по виджетам.
- `config/gtk-4.0/gtk.css` — только переменные libadwaita (`:root` с `--*-color`) и слой `@define-color` для совместимости; прямых селекторов нет.
- `gtk-theme-name` в `settings.ini` не меняется (`Adwaita-dark`). Меняются только цвета: геометрия, отступы и размеры — штатные от Adwaita.
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
- `qt5ct.conf` / `qt6ct.conf`: `color_scheme_path=~/.config/qt<5|6>ct/colors/tokyo-night.conf`, `custom_palette=true`, `style=Fusion`, `icon_theme=Papirus-Dark`.
- `home/xinitrc`: `export QT_QPA_PLATFORMTHEME=qt6ct` (Qt5-приложения тоже идут через qt6ct).
- Применение: `qt5ct` / `qt6ct` или перезапуск приложения.

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
- Промпт в git-репозитории делает 2–5 вызовов `git` на каждый ввод — это основная цена; сам sourcing темы незаметен. Если нужна скорость — `tokyo-night-minimal`.
- Новая тема: файл `config/bash/themes/<имя>.bash`, который выставляет `PS1` (и при необходимости `PROMPT_COMMAND`); ничего больше править не надо.
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
Whitelist: отслеживаются только `config/ home/ local/ requirements/ system/ scripts/ screenshots/ themes/ wallpapers/` и корневые `README.md`, `README.ru.md`, `LICENSE*`, `TODO.md`, `AGENTS.md`, `.gitignore`. Новые файлы/папки в корне молча игнорируются, пока не добавлены в `.gitignore`.

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
- Жёстко заданные имена мониторов (`DisplayPort-1`, `HDMI-A-3`).
- Жёстко заданные имена Wi-Fi интерфейсов в `local/bin/wifi`.

### Обои
Пути к обоям в `bspwmrc` захардкожены как `$HOME/BSPWM-machineslego/wallpapers/` — клон в другом каталоге ломает обои.

## Устаревшее / неиспользуемое

- `wallpaper.sh` удалён: обои ставятся статичными `feh` в `bspwmrc`, выборщик отвергнут (см. `TODO.md`). Не возвращать без просьбы.
- `TODO.md` — рабочий блокнот, а не документация релиза; там же «Отвергнуто» и «Известные ограничения».
- Документация — на русском; `README.md` и `README.ru.md` держать синхронными (оба обновляются одновременно).
- AGENTS.md — внутренняя инструкция, не публикуется.

## Дальние планы

- Ветка BSPWM/X11 — основная и долгосрочная: переезд на Wayland не планируется. Debian стабилен, а Wayland-композиторы с нужными возможностями идут роллингом — это противоречит политике проекта (см. «Отвергнуто» в `TODO.md`).
- `1.7.0` — очередной релиз; ветка продолжает развиваться.

## Проверка

- Тестов нет.
- Синтаксис скриптов: `bash -n <script>`.
- Конфиги проверяются только перезапуском соответствующего компонента/сессии.
- Перед завершением — `git status`; не коммитить `~/.dotfiles-backup-*` и сгенерированные файлы (Fish/Tide, history).
