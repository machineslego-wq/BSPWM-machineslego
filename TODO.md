# TODO

Текущие задачи и идеи для будущих релизов.

---

## 🚧 В работе — v1.7.0 (и далее)

### ⏳ В плане

- [ ] **Темы (dark/light)** — Rofi-меню, симлинк `~/.config/themes/current`, `theme-toggle.sh`
- [ ] **Neovim в `install.sh`** — AppImage в `~/.local/bin/nvim`, без конфига (LazyVim пользователь ставит сам)
- [ ] **Интеграция Eco-режима (PPD + Picom)** — отключение тяжелых эффектов Picom при смене профиля на Power Saver.

---

## 🎨 Темы (dark / light)

**Статус:** в плане. ~1 вечер работы.

**Идея:** Rofi-меню с выбором «Tokyo Night Dark» / «Tokyo Night Day».

**План:**
1. Структура `~/.config/themes/`:
   ```text
   themes/
   ├── current -> dark          # симлинк на активную
   ├── dark/
   │   ├── palette.sh           # THEME_BG, THEME_FG, THEME_BORDER_*
   │   ├── colors.ini           # [colors] для Polybar
   │   ├── colors.rasi          # * { ... } для Rofi
   │   └── colors.toml          # [colors.*] для Alacritty
   └── light/
       └── (то же самое)
   ```
2. Подключить include в конфиги:
   - Polybar: `include-file = ~/.config/themes/current/colors.ini`
   - Rofi: `@import "~/.config/themes/current/colors.rasi"`
   - Alacritty: `[general] import = [...]`
   - BSPWM: `source ~/.config/themes/current/palette.sh` в `bspwmrc`
3. Скрипт `theme-toggle.sh`:
   - Переключить симлинк `current`
   - `bspc wm -r` (BSPWM + обои)
   - `pkill -x picom && picom &`
   - `pkill -x polybar && launch.sh &`
   - `dunstctl reload`
   - `gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'/'prefer-dark'`
4. Rofi-меню выбора (2 пункта + отмена).

**Нюансы:**
- Picom и Polybar **перезапускаются** (нет сигнала reload) — на мгновение мигнут.

---

## 🔋 Интеграция Eco-режима (PPD + Picom)

**Статус:** в плане. Требует доработки `power-profile-ppd.sh`.

**Идея:** Когда пользователь выбирает `Power Saver` в профиле питания, мы **отключаем тяжелые визуальные эффекты Picom** (анимации и тени) для максимальной автономности.

**План реализации:**
1. Создать два конфига Picom:
   - `picom.conf` (обычный, с тенями и анимациями)
   - `picom-eco.conf` (без теней, без анимаций, только базовый композитинг)
2. Доработать `power-profile-ppd.sh` в режиме `--menu`:
   - Если выбран *Performance* или *Balanced*: `powerprofilesctl set ...` + перезапуск Picom с обычным конфигом.
   - Если выбран *Power Saver*: `powerprofilesctl set power-saver` + перезапуск Picom с `picom-eco.conf`.

**Сложность:** низкая. ~20 минут.

---

## 🪟 Прозрачность (on / off) — отложено

**Статус:** отложено до реализации тем (использует общую структуру `~/.config/themes/`).

**Идея:** Rofi-меню «Прозрачность: вкл / выкл».

---

## ⌨️ Спорный хоткей `Super+Alt+T` (Telegram + Proxy)

**Статус:** не решено. 

**Проблема:** буква **T** логично ассоциируется с двумя вещами: **Telegram** (как сейчас) и **Themes** (когда будешь делать).

**Решение (предварительное):** Telegram уходит на `Super+Ctrl+T`. Темы — на `Super+Alt+T`.
вщс
---

## 🐛 Известные ограничения (принято)

- **Dunst: второе+ уведомление появляется без анимации.** Конфликт Picom `geometry` с логикой стека Dunst.
- **`window-height` не парсится с унарным минусом.** Пишем `"0 - window-height"` вручную.
- **Celeron N4120: профиль `performance` в PPD недоступен.** Только `balanced` и `power-saver`.

---

## 💡 Идеи на подумать

- **Автоматическая тема по времени суток** — dark с 20:00 до 08:00, light днём.
- **Тема из обоев** — `matugen` / `pywal` для генерации палитры.