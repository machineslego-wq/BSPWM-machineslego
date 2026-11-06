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

### Midnight Commander
- Скины лежат в `local/share/mc/skins/` → `~/.local/share/mc/skins/`.
- Формат INI: секции `[core]`, `[dialog]`, `[menu]`, `[filehighlight]`, `[editor]`, `[viewer]` и т.д.
- Цвета в формате `foreground;background` через точку с запятой (например, `white;blue`).

### Fish/Tide
- Fisher — менеджер плагинов (устанавливается автоматически).
- Tide — промпт (устанавливается как v6).
- Сгенерированные файлы (`fish_variables`, `conf.d/_tide_*.fish`, `functions/`, `completions/`) в git не коммитить.

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
