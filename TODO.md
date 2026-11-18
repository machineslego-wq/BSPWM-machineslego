# TODO

Текущие задачи и планы. Файл на русском: это рабочий блокнот, а не публичная документация.

> **Правило репозитория:** если задача решается стоковым модулем — не пиши скрипт. Если скрипт нужен — запускай по требованию и сразу завершай. Без фоновых циклов. Без мёртвого кода.
> (см. [README.md](./README.md#-rule-of-the-repository) / [README.ru.md](./README.ru.md#-правило-репозитория))

---

## 🚧 В работе — v1.8.0

### ⏳ В плане

- [ ] **Переезд на Sway/Wayland — постепенно.** Sway становится повседневной сессией, BSPWM/X11 остаётся рабочей запасной сессией на случай поломок (его не удалять и не ломать). Переносить по одной вещи: хоткеи, панель, меню, OSD, темы. Прежнее решение «на Wayland не переезжаем» отменено.
- [ ] **Скриншоты в README — перевести в WebP.** Сейчас `screenshots/` — 9 PNG на 8,4 МБ; WebP даст ~1,5 МБ без заметной потери. Нюансы:
  - правится 10 ссылок в `README.md` и `README.ru.md` (по 9 картинок + путь к папке);
  - имена файлов лучше сохранить с новым расширением (`desktop.webp`), чтобы diff остался читаемым;
  - история git хранит старые PNG, поэтому размер существующего клона не уменьшится и `clone` всё равно скачает старые blob'ы — без переписывания истории (`git filter-repo`, force-push) выигрыш только для новых файлов;
  - раздутый `.git` (loose-объекты) лечится `git gc`, а не заменой картинок.

### ✅ Сделано

- [x] **Qt: светлая палитра** — `config/qt5ct/colors/tokyo-night-day.conf` и `config/qt6ct/colors/tokyo-night-day.conf`: те же 21 роль `QPalette`, палитра Tokyo Night Day. Роли объёма Fusion (`Light`/`Midlight`/`Mid`/`Dark`) перевёрнуты по яркости под светлый фон. Включение ручное — `color_scheme_path` в `qt5ct.conf`/`qt6ct.conf` и `icon_theme=Papirus`; проверено живым рендером Qt5-приложения.
- [x] **GTK: светлые варианты** — `config/gtk-3.0/gtk-light.css` и `config/gtk-4.0/gtk-light.css` один-в-один повторяют тёмные (те же селекторы и переменные), отличается только палитра Tokyo Night Day (фон `#e1e2e7`, текст `#3760bf`, акцент `#2b6fd4`) и базис — `Adwaita` вместо `Adwaita-dark`. Переключение ручное: файл копируется на место `gtk.css`, базовая тема и `color-scheme` меняются через gsettings; скрипта и автопереключения нет.
- [x] **Sway: блокировка и OSD** — `config/swaylock` в стиле Tokyo Night (обои рабочего стола, синее кольцо при вводе, оранжевые символы, красный backspace). OSD громкости красится критериями mako (`[category=volume-*]`), потому что хинты `frcolor`/`hlcolor` mako не понимает; `volume` остаётся общим с BSPWM.
- [x] **Sway: имена команд** — обвязка `sway-*` (`sway-cheatsheet`, `sway-display`, `sway-screenshot`, `sway-session`), меню на wofi — `wofi-*` (`wofi-battery`, `wofi-powermenu`, `wofi-wifi`). Команды BSPWM не переименовывались. Позже убраны как переусложнение: `wofi-power-profile` (профиль питания переключает родной модуль `power-profiles-daemon` в waybar) и `sway-switch` (`Alt+Tab` со списком окон дублировал Sway).
- [x] **Rofi: фиксированные размеры** — проценты заменены на `em`: на 1920×1080 вид прежний, на 1366×768 и выше — тот же. Launcher 40em (800 px), `battery` 29em, `wifi` 24/29em, `power-profile` 21em, `powermenu` 19em, `cheatsheet-bspwm` 48em × 38em, `dunst-history` 48em × 27em.
- [x] **Cava** — `config/cava/config`: 60 fps, `noise_reduction = 40` (резкий подъём и спад без дрожания), моно-спектр слева направо (низкие → высокие), градиент Tokyo Night по высоте, `noncurses` + `synchronized_sync` без мерцания. Пакет добавлен в `requirements/software.txt`.

- [x] **`rice-help`** — печатает все команды из `local/bin` с описанием из шапки файла (третья строка). Список не хардкожен: новая команда появляется в выводе сама.
- [x] **Машинные команды в `local/bin`** — `start-llm`, `start-comfy`, `vllm-setup`, `yacht`, `mount-nas`, `openrgb-i2c-fix`, `sddm-avatar`, `check-hardware`, `check-strawberry`. Быстрый запуск по умолчанию, установка/обслуживание — флагами, без интерактивных вопросов. Не переносились: `vhost-add` (уже есть), `create/delete-apache2-domain` (заменены `vhost-add`/`vhost-remove`), `run_comfyiu_v2` (байт-в-байт копия v1), установщик Nerd Font (дубль `install.sh`, там свежее).
- [x] **`rice-check`** — команда в `local/bin`: симлинки на репозиторий, команды и пути из `sxhkdrc`, `bash -n`, картинки README. Код возврата 0/1, запуск по требованию.

- [x] **Релиз `v1.7.0`** — аннотированный тег, `RELEASE.md` с заметками на двух языках (EN-блок, `---`, RU-блок), запись в whitelist `.gitignore`, порядок публикации в AGENTS.
- [x] **Eco-режим (PPD + Picom)** — реализован в `782477e`. `bspwmrc` выбирает `picom-eco.conf` при `power-saver`, `power-profile` перезапускает Picom при смене профиля через меню.
- [x] **Neovim** — AppImage в `~/.local/bin/nvim`, конфиг на `vim.pack`, Mason, Treesitter; neo-tree с фиксированной шириной 32 и открытием файлов справа; шпаргалка в `config/nvim/CHEATSHEET.md`.
- [x] **Vim** — `home/vimrc` без плагинов: подсветка синтаксиса и определение типов файлов, гибридная нумерация (абсолютный номер на строке курсора, относительные вокруг), постоянная история в `~/.vim/undo`, типы файлов для конфигов без расширения. `vim` добавлен в `apt.txt`.
- [x] **Единая тема** — GTK3/GTK4 (свой CSS поверх `Adwaita-dark`), Qt5/Qt6, GIMP 3, CopyQ, Telegram, Midnight Commander.
- [x] **Node.js без sudo** — `scripts/install-node.sh` (NodeSource LTS, prefix `~/.npm-global`).
- [x] **Команды в `~/.local/bin`** — `battery`, `cheatsheet-bspwm`, `dunst-history`, `powermenu`, `power-profile`, `screenshot`, `session-restart`, `volume`, `wifi` перенесены из `config/sxhkd/scripts` и `config/polybar/scripts`; `link.sh`/`unlink.sh` линкуют их поштучно, PATH выставляют `xinitrc`/`xprofile`. В `config/sxhkd/scripts` остались только хоткей-хелперы (`flag.sh`, `to-preselect.sh`, `preselect-cancel-all.sh`).
- [x] **Промпт Bash в пресетах** — `home/bashrc` только выбирает файл по `BASH_PROMPT`; пресеты `tokyo-night` (Debian → папка → git → стрелка), `tokyo-night-minimal` (одна строка, без `git`) и `empty` (шаблон для своей темы) лежат в `config/bash/themes/`. Заголовок окна перенесён внутрь `prompt_command`, мёртвый блок `force_color_prompt` удалён.

---

## ❌ Отвергнуто (оставлено для истории)

Решения, которые были обдуманы и **сознательно отброшены**. Здесь, чтобы не возвращаться к ним через полгода и не начинать заново.

- **Темы (dark / light)** — слишком много файлов, слишком много связей (симлинк + include в 4 конфига + скрипт + перезапуск 2 демонов). Пробовал, отказался. Стоимость поддержки выше пользы. Исключение по просьбе: светлые GTK3/GTK4- и Qt-палитры (`gtk-light.css`, `tokyo-night-day.conf`) — только файлы, без переключения остальных компонентов и без скрипта.
- **Прозрачность (on / off)** — зависела от тем. Тем нет — фичи нет.
- **Скрипт-выборщик обоев** (`wallpaper.sh` через Rofi) — заменён двумя статичными вызовами `feh` в `bspwmrc`. Сменить обои = отредактировать одну строку.
- **Авто-тема по времени суток** — зависела от тем.
- **Тема из обоев** (`matugen` / `pywal`) — слишком сложно для личного сетапа. Палитра Tokyo Night фиксированная, генерация не нужна.
- **rewaita / автогенерация GTK-темы** — пробовали (`3a5e1ad`), откатили. Красит аккуратно, но багов и расхождений больше, чем в своём `gtk.css` поверх `Adwaita-dark`. Не возвращать без просьбы.
- **Своя тема и плагины для Vim** — не нужны. Палитра терминала (Alacritty) уже Tokyo Night, отдельный colorscheme дублировал бы цвета; всё «умное» (LSP, сайдбар, автодополнение) живёт в Neovim, а Vim остаётся стоковым редактором для правки конфигов.

---

## 🐛 Известные ограничения (принято)

Не баги, а осознанные компромиссы. Живут здесь, чтобы не заводить на них issues.

- **Dunst: второе+ уведомление появляется без анимации.** Конфликт Picom `geometry` с логикой стека Dunst.
- **`window-height` не парсится с унарным минусом.** Пишем `"0 - window-height"` вручную в `picom.conf`.
- **Celeron N4120: профиль `performance` в PPD недоступен.** Только `balanced` и `power-saver`.
- **Dunst показывает уведомления только на мониторе `0`** (`monitor = 0` в `dunstrc`). На мультимониторном ПК это основной экран.
- **Обои привязаны к каталогу клона.** Пути в `bspwmrc` — `$HOME/BSPWM-machineslego/wallpapers/`.
- **Vim — без плагинов.** В `~/.vimrc` только настройки и подсветка: нет LSP, дерева файлов и автодополнения — для этого есть Neovim. Файлы с расширением (`*.yaml`, `*.json`, `*.toml`, `*.css` и т.д.) Vim определяет сам, а имена без расширения (`sxhkdrc`, `bspwmrc`, `dunstrc` и т.п.) перечислены в `augroup dotfiles` вручную.
