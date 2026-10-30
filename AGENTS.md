# AGENTS.md

Dotfiles + установщик BSPWM-окружения для Debian 13 Trixie (X11, Tokyo Night).
Сборки, тестов, линтера и CI нет: «продукт» — конфиги и shell-скрипты.

## Главное правило репозитория
- Решается стоковым модулем — не пиши скрипт. Скрипт нужен — запускай по требованию и сразу завершай.
- Никаких фоновых циклов и мёртвого кода.
- Перед новой фичей сверься с разделом «Отвергнуто» в `TODO.md` (темы, прозрачность, выборщик обоев, авто-темы). Не возвращай их без явной просьбы.

## Как устроены «живые» конфиги
- `config/<pkg>` → симлинк `~/.config/<pkg>`; `home/<file>` → `~/.<file>`; `system/**` → копируется в `/etc/**` с бэкапом.
- Правка файла в репозитории сразу меняет живую систему (симлинк), отдельного шага синхронизации нет.
- Не запускай `scripts/install.sh` и `scripts/unlink.sh` без явной просьбы: первый ставит apt-пакеты, перезаписывает `/etc`, меняет shell и чужие конфиги; второй удаляет симлинки из `~/.config`.
- `scripts/link.sh` — идемпотентный линковщик, реальные файлы уносит в `~/.dotfiles-backup-*`.
- Скрипты в git имеют режим 755; новые `.sh` тоже должны быть executable.

## Применение изменений
- `bspwmrc`: `bspc wm -r` (или `Super + Alt + R`).
- `sxhkdrc`: `pkill -USR1 -x sxhkd`.
- Polybar: `~/.config/polybar/launch.sh` (убивает и перезапускает панель).
- Picom: `pkill -x picom`, затем запуск вручную; профиль выбирается по `powerprofilesctl get` (`power-saver` → `picom-eco.conf`, иначе `picom.conf`).
- Полный перезапуск: `Super + Alt + Shift + R`.

## Особенности конфигов
- `sxhkdrc`: команда под хоткеем — отступ ровно 4 пробела (не табы). Поддерживается brace-раскладка `super + {a,b}`.
- Picom не парсит унарный минус: писать `"0 - window-height"`, а не `"-window-height"`.
- Polybar использует `internal/*` модули; `launch.sh` экспортирует `POLYBAR_BAT` / `POLYBAR_AC` / `POLYBAR_BACKLIGHT`. Не хардкодь имена батареи/подсветки.
- Иконки в Polybar/Rofi/скриптах требуют JetBrainsMono Nerd Font.
- `.gitignore` — whitelist: отслеживаются только `config/ home/ system/ scripts/ screenshots/ wallpapers/` и корневые `*.md`. Новые файлы/папки в корне молча игнорируются, пока не добавлены в `.gitignore`.
- Сгенерированные Fish/Tide файлы (`fish_variables`, `conf.d/_tide_*.fish`, `functions/`, `completions/`) в git не коммитить.

## Персонализация — не обобщать молча
- `bspwmrc` и `wifi.sh` ветвятся по hostname (`lamer-deb`, `travelmate`, `lx15pro`, `lx15pro-deb`), жёстко заданным мониторам (`DisplayPort-1`, `HDMI-A-3`) и именам Wi-Fi интерфейсов.
- Пути к обоям в `bspwmrc` захардкожены как `$HOME/BSPWM-machineslego/wallpapers/` — клон в другом каталоге ломает обои.

## Устаревшее / неиспользуемое
- `config/sxhkd/scripts/wallpaper.sh` не используется: вызовы закомментированы в `bspwmrc`/`sxhkdrc`, README говорит о замене на статичные `feh`. Не восстанавливать без просьбы.
- В конце `sxhkdrc` — закомментированный fallback скриншотов на `xclip` (рабочая версия использует `copyq`).
- `TODO.md` устарел: Neovim уже ставится в `scripts/software.sh`.
- Комментарии и документация — на русском; `README.md` и `README.ru.md` держать синхронными.

## Проверка
- Тестов нет. Синтаксис скриптов: `bash -n <script>`.
- Конфиги проверяются только перезапуском соответствующего компонента/сессии.
- Перед завершением — `git status`; не коммитить `~/.dotfiles-backup-*` и сгенерированные файлы.
