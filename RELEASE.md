v1.8.0 — Sway Takes Over

What's done

Sway becomes the everyday session, with BSPWM kept intact as the X11 fallback. This release brings the whole Wayland desktop in the same Tokyo Night style — panel, launcher, notifications, terminal, lock screen, portals and light theme variants — plus quick screen recording, screenshot annotations and clipboard history.

## 🖥️ Sway as the daily session

- `config/sway/config` mirrors the BSPWM look: 2 px pixel borders without titles, zero gaps, smart borders, borders only when a workspace has more than one window, `focus_follows_mouse no`. The active border is `#6b8dd6`; inactive borders blend into `#1a1b26`, so a lone window looks frameless.
- Every binding uses `--to-code`, so hotkeys fire in the Russian layout too.
- Hotkeys follow BSPWM where it makes sense: terminal, launcher, `Super + F1…F4` and `Super + Shift + S` screenshots, `Super + Alt + L` lock, `Super + Alt + N/B` Wi-Fi and battery menus, `Super + Shift + Q` power menu. `Super + C` toggles focus between tiling and floating windows.
- `sway-session` wraps the compositor and sets PATH, XDG session variables, the cursor, Qt/GTK and Electron/Java Wayland flags. Start it from a TTY, or let GDM show the session after `./scripts/install-sway.sh --session`.
- `sway-display` owns monitor layout and wallpapers per hostname (the desktop gets two outputs, laptops a safe fallback) and re-applies them on every reload.
- Preselect, monocle and picom analogues are not carried over: Sway has a different tree model and draws no shadows by itself.

## 🧩 Panel, launcher, notifications, terminal & lock screen

- Waybar replaces Polybar under Sway: floating islands for workspaces, mode and scratchpad on the left; brightness, clock and battery in the center; tray, layout, Caps/Num/Scroll indicators, power profile, volume, Bluetooth, network and a power button on the right.
- Battery polls every 3 s, turns yellow at 59% and red with blinking at 14%. The clock is localized (`ru_RU.UTF-8`) and shows date and time in one field. Bluetooth is the stock waybar module backed by BlueZ: left click powers on, right click powers off.
- Wofi is the launcher (`Super + D`) and the menu engine. Menus size themselves to content, widths match the Rofi ones, and the search field is painted `#24283b` by user GTK CSS so Adwaita does not override it.
- Mako reproduces the dunst look: 360 px, 2 px Tokyo Night border, progress bar, no icons, critical notifications stay until dismissed. Mouse: left dismiss, middle default action, right dismiss all. The volume OSD colors come from `category` criteria because mako ignores dunst's `frcolor`/`hlcolor` hints.
- Foot is the Sway terminal: JetBrainsMono Nerd Font 10, no padding, 100×28, Fish, no client-side decorations. Swaylock paints the desktop wallpapers (portrait for the rotated monitor), shows the us/ru layout and a Caps Lock hint.

## 🎥 Recording, annotations & clipboard

- `Super + Shift + R` records the whole screen; `Super + Shift + Alt + R` records a selected region. Pressing either hotkey again stops the recording and finalizes the MP4 in `~/Videos/Screencasts`.
- Recording always captures audio, but from the output monitor rather than the default source: on this machine the default source is the webcam, so `-a` alone would record the microphone. The script reads the default sink from `wpctl` and records its monitor.
- VAAPI (`h264_vaapi`) is used for full-screen recording on AMD/Intel GPUs; NVIDIA and everything else fall back to `libx264`. Region recording always uses `libx264`, because AMD's encoder rejects frames smaller than 128×128 and the region is rounded down to even dimensions.
- `Super + Shift + A` opens the screenshot that is already in the clipboard in swappy. It works after any capture mode — `F1…F4`, `Shift + S` or `Print` — and saves annotations to `~/Screenshots`. Tools: `a` arrow, `t` text, `r` rectangle, `o` ellipse, `b` brush, `d` blur; `Ctrl+S` saves, `Ctrl+C` copies, `Esc` quits.
- `Super + Shift + V` opens clipboard history: cliphist keeps the last 100 entries, images included, and the wofi menu decodes the selected one back into the clipboard. Previews are cut to 100 characters, but full content is restored — a 1500-line code block pastes intact. CopyQ stays in BSPWM; under Wayland it was unreliable.
- History is not filtered: passwords and tokens copied from a password manager will land there. `cliphist wipe` clears everything.

## 🪟 Screen sharing (OBS, portals)

- `xdg-desktop-portal-wlr` provides ScreenCast and Screenshot; `portals.conf` routes those two interfaces to wlr and everything else (file dialogs, notifications) to the GTK backend. `default=wlr` is not used, because wlr implements only the two.
- Sway exports its environment into systemd and D-Bus on startup, so the portal service no longer skips itself with `ConditionEnvironment=WAYLAND_DISPLAY`.
- OBS has to run as a native Wayland client (`QT_QPA_PLATFORM="wayland;xcb"` from `sway-session`); from a bare terminal it falls back to XWayland and the ScreenCast source does not appear.

## 🎨 Tokyo Night Day

- `gtk-light.css` in both GTK 3 and GTK 4 folders is a 1:1 light variant over `Adwaita` (background `#e1e2e7`, text `#3760bf`, accent `#2b6fd4`).
- `tokyo-night-day.conf` does the same for Qt5/Qt6 with the same 21 `QPalette` roles; Fusion's raised/sunken roles are inverted for a light background.
- Switching stays manual: copy the light CSS over `gtk.css`, change `gtk-theme`, `color-scheme` and the icon theme in gsettings, and point `color_scheme_path` at the day palette. Icons become `Papirus` instead of `Papirus-Dark`.
- `link.sh` now also sets the GTK cursor theme (`Bibata-Modern-Ice`, 24) in gsettings, so native GTK apps no longer draw the stock Adwaita cursor while Sway and XWayland show Bibata.

## 📊 btop & cava

- btop ships with a Tokyo Night theme and a tuned config: the palette matches Polybar/Waybar, and CPU, memory, temperature and network meters have their own gradients.
- cava draws one mono spectrum, low frequencies on the left and high on the right, at 60 fps with sharper noise reduction, gradient bars and `noncurses` rendering without flicker.

## 🐛 Fixes

- Reloading Sway no longer spawns a second waybar.
- Swaylock uses Sway's output name for the rotated monitor, so the portrait wallpaper lands on the right screen.
- Inactive window borders blend into the Tokyo Night background instead of standing out.
- The volume OSD no longer flashes a red "overflow" warning above 100%; it just reports the level.
- `install-sway.sh` adds the user to the `input` group, which the waybar `keyboard-state` module needs to read Caps/Num/Scroll state.
- Requirements gained `nm-connection-editor`, `rfkill`, `firefox-esr`, `git`, `xdg-desktop-portal`, `xdg-desktop-portal-gtk`, `qt6-wayland`, `qtwayland5`, `nfs-common`, `cava` and LibreOffice's GTK3 backend.
- README previews moved from PNG to WebP and the folder was trimmed to the current shots.

## ⚠️ Migration notes

- New packages: `./scripts/install-sway.sh` installs everything from `requirements/sway.txt`, including swappy, wf-recorder and cliphist; `--session` also adds the GDM entry.
- Group membership changes apply after a re-login: log out and back in (or reboot) before expecting the Caps/Num indicators to work.
- Run `./scripts/link.sh` after pulling: it links `config/swappy`, the new commands and the rest of the configs.
- The cliphist watcher starts with Sway on reload; `cliphist wipe` clears the history.
- BSPWM is untouched: screenshots, CopyQ and all X11 hotkeys still work there.

🚀 Update Instructions

```bash
cd ~/BSPWM-machineslego
git pull origin main
./scripts/install-sway.sh
./scripts/link.sh
```

Then reload Sway with `Super + Escape`, restart Waybar if you edited its config (`pkill -x waybar; waybar &`), or log out and back in for the `input` group.

(`link.sh` is enough for a regular update — it re-links configs, commands and skins. `install.sh` is only needed on a fresh machine.)

---

v1.8.0 — Sway становится основной сессией

Что сделано

Sway становится повседневной сессией, а BSPWM остаётся нетронутым запасным X11-вариантом. Релиз приносит весь Wayland-десктоп в той же палитре Tokyo Night — панель, лаунчер, уведомления, терминал, экран блокировки, порталы и светлые варианты тем, — а также быструю запись экрана, пометки на скриншотах и историю буфера.

## 🖥️ Sway как ежедневная сессия

- `config/sway/config` повторяет вид BSPWM: рамка 2 px без заголовка, нулевые отступы, `smart_borders` (рамка только когда окон больше одного), `focus_follows_mouse no`. Активная рамка `#6b8dd6`, неактивная сливается с фоном `#1a1b26`, поэтому одинокое окно выглядит без рамки.
- Все бинды объявлены с `--to-code`: хоткеи срабатывают и в русской раскладке.
- Хоткеи повторяют BSPWM там, где это осмысленно: терминал, лаунчер, скриншоты `Super + F1…F4` и `Super + Shift + S`, блокировка `Super + Alt + L`, меню Wi-Fi и батареи `Super + Alt + N/B`, меню питания `Super + Shift + Q`. `Super + C` переключает фокус между тайловым и плавающим окном.
- `sway-session` оборачивает композитор и выставляет PATH, переменные XDG-сессии, курсор, флаги Wayland для Qt/GTK/Electron/Java. Запуск из TTY или из GDM после `./scripts/install-sway.sh --session`.
- `sway-display` отвечает за раскладку мониторов и обои по hostname (десктопу — два выхода, ноутбукам — безопасный фолбэк) и переприменяет их при каждом reload.
- Preselect, monocle и аналоги picom не переносились: у Sway другая модель дерева, а тени он не рисует сам.

## 🧩 Панель, лаунчер, уведомления, терминал и блокировка

- Waybar заменяет Polybar под Sway: островки со столами, режимом и scratchpad слева; яркостью, часами и батареей в центре; треем, раскладкой, индикаторами Caps/Num/Scroll, профилем питания, звуком, Bluetooth, сетью и кнопкой питания справа.
- Батарея опрашивается раз в 3 с, желтеет на 59% и мигает красным на 14%. Часы локализованы (`ru_RU.UTF-8`) и показывают дату с временем в одном поле. Bluetooth — стоковый модуль waybar поверх BlueZ: ЛКМ включает, ПКМ выключает.
- Wofi — лаунчер (`Super + D`) и движок меню. Высота подстраивается под содержимое, ширины совпадают с Rofi, а поле поиска красится в `#24283b` пользовательским GTK CSS, иначе Adwaita перекрывает фон.
- Mako повторяет вид dunst: 360 px, рамка 2 px в цветах Tokyo Night, прогресс-бар, без иконок, критические уведомления не исчезают сами. Мышь: ЛКМ закрывает, СКМ — действие по умолчанию, ПКМ — закрыть все. Цвета OSD громкости задаются критериями по `category`, потому что хинты dunst `frcolor`/`hlcolor` mako не понимает.
- Foot — терминал Sway: JetBrainsMono Nerd Font 10, без отступов, 100×28, Fish, без клиентских рамок. Swaylock рисует обои рабочего стола (портретные — для повёрнутого монитора), показывает раскладку us/ru и подсказку Caps Lock.

## 🎥 Запись, пометки и буфер обмена

- `Super + Shift + R` пишет весь экран, `Super + Shift + Alt + R` — выделенную область. Повторное нажатие останавливает запись и корректно закрывает MP4 в `~/Videos/Screencasts`.
- Звук пишется всегда, но с монитора выхода, а не с источника по умолчанию: на этой машине источник по умолчанию — веб-камера, поэтому одного `-a` мало. Скрипт берёт sink из `wpctl` и записывает его monitor.
- VAAPI (`h264_vaapi`) используется для записи всего экрана на AMD/Intel; NVIDIA и остальные получают `libx264`. Область всегда пишется через `libx264`: аппаратный энкодер AMD не принимает кадры меньше 128×128, а размеры области округляются вниз до чётных.
- `Super + Shift + A` открывает в swappy скриншот, который уже лежит в буфере. Работает после любого режима — `F1…F4`, `Shift + S` или `Print` — и сохраняет пометки в `~/Screenshots`. Инструменты: `a` стрелка, `t` текст, `r` прямоугольник, `o` эллипс, `b` кисть, `d` блюр; `Ctrl+S` сохраняет, `Ctrl+C` копирует, `Esc` выходит.
- `Super + Shift + V` открывает историю буфера: cliphist хранит последние 100 записей, включая картинки, а меню wofi возвращает выбранную запись в буфер. Превью обрезается до 100 символов, но содержимое восстанавливается целиком — блок кода на 1500 строк вставляется полностью. В BSPWM остаётся CopyQ; под Wayland он вёл себя нестабильно.
- История не фильтруется: пароли и токены из менеджера паролей туда тоже попадут. `cliphist wipe` очищает всё.

## 🪟 Демонстрация экрана (OBS, порталы)

- `xdg-desktop-portal-wlr` предоставляет ScreenCast и Screenshot; `portals.conf` направляет эти два интерфейса на wlr, а всё остальное (файловые диалоги, уведомления) — на GTK-бэкенд. `default=wlr` не используется: wlr реализует только два интерфейса.
- Sway экспортирует окружение в systemd и D-Bus при старте, поэтому портал больше не пропускает себя с `ConditionEnvironment=WAYLAND_DISPLAY`.
- OBS должен быть нативным Wayland-клиентом (`QT_QPA_PLATFORM="wayland;xcb"` из `sway-session`); из голого терминала он уходит в XWayland, и источник ScreenCast не появляется.

## 🎨 Tokyo Night Day

- `gtk-light.css` в папках GTK 3 и GTK 4 — светлый вариант один-в-один поверх `Adwaita` (фон `#e1e2e7`, текст `#3760bf`, акцент `#2b6fd4`).
- `tokyo-night-day.conf` делает то же для Qt5/Qt6 с теми же 21 ролями `QPalette`; роли объёма Fusion перевёрнуты под светлый фон.
- Переключение остаётся ручным: светлый CSS копируется на место `gtk.css`, в gsettings меняются `gtk-theme`, `color-scheme` и тема иконок, а `color_scheme_path` указывает на дневную палитру. Иконки — `Papirus` вместо `Papirus-Dark`.
- `link.sh` теперь ещё и выставляет тему курсора GTK (`Bibata-Modern-Ice`, 24) в gsettings, поэтому нативные GTK-приложения больше не рисуют стоковый курсор Adwaita, пока Sway и XWayland показывают Bibata.

## 📊 btop и cava

- btop идёт с темой Tokyo Night и настроенным конфигом: палитра совпадает с Polybar/Waybar, у CPU, памяти, температуры и сети свои градиенты.
- cava рисует один моно-спектр, низкие частоты слева, высокие справа, на 60 fps с более резким спадом, градиентными столбиками и `noncurses` без мерцания.

## 🐛 Исправления

- Reload Sway больше не запускает вторую waybar.
- Swaylock берёт имя выхода Sway для повёрнутого монитора, поэтому портретные обои попадают на нужный экран.
- Рамки неактивных окон сливаются с фоном Tokyo Night, а не выделяются.
- OSD громкости больше не мигает красным предупреждением выше 100% — просто показывает уровень.
- `install-sway.sh` добавляет пользователя в группу `input`: без неё модуль waybar `keyboard-state` не видит Caps/Num/Scroll.
- В требования добавлены `nm-connection-editor`, `rfkill`, `firefox-esr`, `git`, `xdg-desktop-portal`, `xdg-desktop-portal-gtk`, `qt6-wayland`, `qtwayland5`, `nfs-common`, `cava` и GTK3-бэкенд LibreOffice.
- Превью README переведены с PNG на WebP, папка сокращена до актуальных снимков.

## ⚠️ Что сделать после обновления

- Новые пакеты: `./scripts/install-sway.sh` ставит всё из `requirements/sway.txt`, включая swappy, wf-recorder и cliphist; с `--session` добавляется ещё и запись в GDM.
- Изменение групп применяется после повторного входа: выйди из сессии и зайди снова (или перезагрузись), прежде чем ждать индикаторы Caps/Num.
- После `git pull` запусти `./scripts/link.sh`: он прилинкует `config/swappy`, новые команды и остальные конфиги.
- Watcher cliphist стартует вместе с Sway при reload; `cliphist wipe` очищает историю.
- BSPWM не тронут: скриншоты, CopyQ и все X11-хоткеи работают как раньше.

🚀 Инструкция по обновлению

```bash
cd ~/BSPWM-machineslego
git pull origin main
./scripts/install-sway.sh
./scripts/link.sh
```

Затем перезагрузи Sway через `Super + Escape`, перезапусти Waybar, если правил его конфиг (`pkill -x waybar; waybar &`), или выйди и зайди снова ради группы `input`.

(`link.sh` достаточно для обычного обновления — он перелинкует конфиги, команды и скины. `install.sh` нужен только на новой машине.)
