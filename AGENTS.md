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
- `local/<dir>` → симлинк `~/.local/<dir>` (для скинов MC, шрифтов и т.д.)
- `system/**` → копируется в `/etc/**` с бэкапом в `/etc/dotfiles-backup-YYYYMMDD-HHMMSS`

Правка файла в репозитории сразу меняет живую систему (симлинк), отдельного шага синхронизации нет.

### Скрипты
- `scripts/install.sh` — полная установка: apt-пакеты, шрифты, линковка, Fish/Tide, системные конфиги, Flatpak. Запускается только при первичной настройке.
- `scripts/link.sh` — идемпотентный линковщик: делает бэкап в `~/.dotfiles-backup-*`, ставит симлинки. Меняет уже установленные пакеты.
- `scripts/unlink.sh` — безопасное удаление симлинков, созданных link.sh (только свои, не трогает чужие).
- `scripts/software.sh` — установка дополнительного софта ( lazygit, neovim, mpv, gimp и т.д.). Вызывается из install.sh по требованию.
- `scripts/install-node.sh` — Node.js LTS из NodeSource, npm с prefix `~/.npm-global` (глобальные пакеты без sudo). Запускается отдельно, не из install.sh.

Не запускай `install.sh` и `unlink.sh` без явной просьбы. `link.sh` — безопасен для запуска в любое время.

### Права на файлы
Скрипты в git имеют режим 755; новые `.sh` тоже должны быть executable (`chmod +x`).

## Применение изменений

| Компонент | Команда | Горячая клавиша |
|-----------|---------|-----------------|
| BSPWM | `bspc wm -r` | `Super + Alt + R` |
| SXHKD | `pkill -USR1 -x sxhkd` | `Super + Escape` |
| Polybar | `~/.config/polybar/launch.sh` | — |
| Picom | `pkill -x picom; picom --config <профиль>` | — |
| GTK3 / GTK4 | перезапуск приложения (CSS читается при старте) | — |
| Qt | `qt5ct` / `qt6ct` или перезапуск приложения | — |
| Полный перезапуск | `~/.config/sxhkd/scripts/session-restart.sh` | `Super + Alt + Shift + R` |

Picom автоматически выбирает профиль по `powerprofilesctl get`:
- `power-saver` → `picom-eco.conf`
- иначе → `picom.conf`

## Особенности конфигов

### sxhkdrc
- Команда под хоткеем — отступ ровно 4 пробела (не табы).
- Поддерживается brace-раскладка `super + {a,b}` (аналог `super + a; super + b`).
- Комментарии — только на отдельной строке; inline-комментарии ломают парсер.

### Picom
- Не парсит унарный минус: писать `"0 - window-height"`, а не `"-window-height"`.
- DIM effect: `dim-spec` задаёт прозрачность неактивных окон (например, `0.7` — 70% непрозрачности).

### Polybar
- Использует `internal/*` модули.
- `launch.sh` экспортирует `POLYBAR_BAT` / `POLYBAR_AC` / `POLYBAR_BACKLIGHT`. Не хардкодь имена батареи/подсветки.
- Фон для «пилюль» (окружений модулей) — `bg-mid = #1f2335`.
- Иконки требуют JetBrainsMono Nerd Font.

### Alacritty
- Шрифт: `JetBrainsMono Nerd Font:size=11` (основной), `JetBrainsMono Nerd Font:pixelsize=15` (для иконок).
- Тёмная тема Tokyo Night: фон `#1a1b26`, текст `#c0caf5`.

### GTK3 / GTK4
- `config/gtk-3.0/gtk.css` и `config/gtk-4.0/gtk.css` — пользовательский CSS поверх `Adwaita-dark`. `gtk-theme-name` в `settings.ini` не меняется.
- Меняются только цвета. Геометрия, отступы и размеры — штатные от Adwaita.
- GTK3: Adwaita жёстко прописывает цвета, поэтому нужны прямые селекторы. `@define-color` — для приложений, которые читают именованные цвета в своём CSS.
- GTK4/libadwaita: перекрашивается через именованные цвета (`window_*`, `view_*`, `accent_*`, `headerbar_*`, `sidebar_*`), обычные GTK4-виджеты — прямыми селекторами.
- Adwaita рисует `background-image` / `box-shadow` в hover/active/checked/disabled/backdrop — в user CSS их надо сбрасывать явно, иначе остаются светлые пятна.
- Фон infobar — на `infobar > revealer > box`, а не на самом `infobar`. Toolbar/searchbar (`searchbar > revealer > box`, `.toolbar`) по умолчанию серые (`#353535` / `#2d2d2d`).
- GTK3 rubberband рисуется контекстом виджета с классом `.rubberband`; фон `.view` его перекрывает, поэтому нужны отдельные правила `.rubberband` (заливка `rgba(122,162,247,0.2)`, рамка `rgba(122,162,247,0.6)`).
- GTK4 focus outline перекрашен с синего Adwaita `rgba(21,83,158,.7)` на `rgba(122,162,247,.7)` (+ варианты error/warning).
- Иконки Papirus-Dark имеют собственный светлый цвет (`#dfdfdf`) — это не баг темы.
- Применение: перезапуск приложения. Симлинки `~/.config/gtk-3.0`, `~/.config/gtk-4.0` уже стоят.

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

### Node.js / npm
- `scripts/install-node.sh` ставит NodeSource LTS и пишет `prefix=~/.npm-global` в `~/.npmrc`: `npm i -g` работает без sudo.
- PATH до `~/.npm-global/bin` добавляют оба шелла — `config/fish/config.fish` и `home/bashrc` (блоки идемпотентны, дублей не создают).
- NVM, если установлен, подключается в конце `home/bashrc` и может переопределить `node`/`npm` из NodeSource.

### .gitignore
Whitelist: отслеживаются только `config/ home/ local/ system/ scripts/ screenshots/ wallpapers/` и корневые `*.md`. Новые файлы/папки в корне молча игнорируются, пока не добавлены в `.gitignore`.

### Системные конфиги
- `system/etc/**` → копируется в `/etc/**` с бэкапом в `/etc/dotfiles-backup-YYYYMMDD-HHMMSS`.
- Логин при закрытии крышки: `suspend` (через `/etc/systemd/logind.conf.d/10-lid-suspend.conf`).
- Audio backend: принудительный переход на PipeWire (удаляет PulseAudio при обнаружении).

## Персонализация — не обобщать молча

### Hostname-специфичные ветвления
- `bspwmrc` и `wifi.sh` проверяют `hostname` (`lamer-deb`, `travelmate`, `lx15pro`, `lx15pro-deb`).
- `bspwmrc` — запуск OpenRGB (только для ПК `lamer-deb`).

### Мониторы и интерфейсы
- Жёстко заданные имена мониторов (`DisplayPort-1`, `HDMI-A-3`).
- Жёстко заданные имена Wi-Fi интерфейсов в `wifi.sh`.

### Обои
Пути к обоям в `bspwmrc` захардкожены как `$HOME/BSPWM-machineslego/wallpapers/` — клон в другом каталоге ломает обои.

## Устаревшее / неиспользуемое

- `config/sxhkd/scripts/wallpaper.sh` не используется: вызовы закомментированы в `bspwmrc`/`sxhkdrc`, README говорит о замене на статичные `feh`. Не восстанавливать без просьбы.
- В конце `sxhkdrc` — закомментированный fallback скриншотов на `xclip` (рабочая версия использует `copyq`).
- `TODO.md` устарел: Neovim уже ставится в `scripts/software.sh`.
- Документация — на русском; `README.md` и `README.ru.md` держать синхронными (оба обновляются одновременно).
- AGENTS.md — внутренняя инструкция, не публикуется.

## Проверка

- Тестов нет.
- Синтаксис скриптов: `bash -n <script>`.
- Конфиги проверяются только перезапуском соответствующего компонента/сессии.
- Перед завершением — `git status`; не коммитить `~/.dotfiles-backup-*` и сгенерированные файлы (Fish/Tide, history).
