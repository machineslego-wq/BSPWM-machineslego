# TODO

Текущие задачи и идеи для будущих релизов.

---

## 🚧 В работе — v1.5.0

Релиз собирается по мере появления времени. **Не «срочно»**, а «когда руки дойдут».

### ✅ Готово

- [x] **Wi-Fi Hidden Network** — пункт «Скрытая сеть» в `wifi.sh`, `hidden yes` + `--ask`, env-переменная для SSID
- [x] **Notification History** — `notify-history.sh` + `Super+Alt+H`, Rofi-меню с историей Dunst, копирование в буфер
- [x] **Custom Battery Widget** — `battery.sh`, клик → Rofi, предупреждения 60%/30%, `ICON_STYLE`, health
- [x] **xset r rate 250 30** — фикс лагов Dunst при удержании клавиш
- [x] **README (EN/RU)** обновлён под все фичи
- [x] **`.gitignore`** — `!/TODO.md` в whitelist
- [x] **Screenshot notifications** — уведомление при успешном скриншоте

### ⏳ В плане

- [ ] **Темы (dark/light)** — Rofi-меню, симлинк `~/.config/themes/current`, `theme-toggle.sh`
- [ ] **Neovim в `install.sh`** — AppImage в `~/.local/bin/nvim`, без конфига (LazyVim пользователь ставит сам)

### ⏸ Отложено (зависит от тем)

- [ ] **Прозрачность (on/off)** — Rofi-тумблер, два `picom.conf`, `transparency-toggle.sh`. Сделать **после** тем, чтобы использовать общую структуру `~/.config/themes/` для `opacity-rule`.

**Перед тегом `v1.5.0`:** прогнать `./scripts/install.sh` на чистой машине, проверить, что всё работает из коробки.

---

## 🎨 Темы (dark / light)

**Статус:** в плане v1.5.0. ~1 вечер работы.

**Идея:** Rofi-меню с выбором «Tokyo Night Dark» / «Tokyo Night Day».

**План:**
1. Структура `~/.config/themes/`:
   ```
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
   - `gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'/'Adwaita-dark'`
4. Rofi-меню выбора (2 пункта + отмена).

**Нюансы:**
- Picom и Polybar **перезапускаются** (нет сигнала reload) — на мгновение мигнут.
- Dunst перечитывает конфиг через `dunstctl reload`, без убийства.
- Rofi и Alacritty читают конфиг при каждом запуске — перезапуск не нужен.
- GTK-приложения (Thunar) подхватывают `gsettings` на лету.

**Сложность:** средняя. ~1 вечер.

---

## 📝 Neovim в `install.sh`

**Статус:** в плане v1.5.0. ~1 час работы.

**Проблема:** в Debian 13 Trixie версия Neovim в репозитории — **устаревшая** (обычно 0.9.x или ниже требуемой для LazyVim 0.11.2).

**Решение (предварительное):**

**AppImage + без конфига.** `install.sh` скачивает актуальный AppImage в `~/.local/bin/nvim`, `chmod +x`. LazyVim/AstroNvim пользователь ставит сам — одной командой из README.

Почему не своя сборка:
- Каждый апстрим-апдейт Neovim/LazyVim — твоя головная боль
- Дублирование работы (LazyVim/AstroNvim уже поддерживаются сообществом)
- «Из коробки» достаточно `nvim` в `PATH`

**Что проверить перед реализацией:**
- Есть ли `fuse` в зависимостях (`install.sh` не ставит его сейчас)
- Куда класть AppImage (стандарт — `~/.local/bin/`)
- Обновлять ли автоматически при `install.sh` (если уже есть более старая версия)
- Проверка версии: если `nvim >= 0.11.2` — пропустить скачивание

**README:** добавить пункт про LazyVim/AstroNvim:
```bash
# Хочешь LazyVim?
git clone https://github.com/LazyVim/starter ~/.config/nvim
# Хочешь AstroNvim?
git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
```

**Сложность:** средняя. ~1 час.

---

## 🪟 Прозрачность (on / off) — отложено

**Статус:** отложено до реализации тем (использует общую структуру `~/.config/themes/`).

**Идея:** Rofi-меню «Прозрачность: вкл / выкл».

**План:**
1. В каждой теме (`dark/`, `light/`) добавить `picom-opacity.conf` с правилами:
   ```lua
   opacity-rule = [
       "90:class_g = 'Alacritty'",
       "95:class_g = 'Thunar'",
       "95:class_g = 'Code'"
   ];
   ```
2. Скрипт `transparency-toggle.sh`:
   - Определить текущее состояние (флаг в `/tmp/` или отдельный файл)
   - Переключить `picom --config` (с `opacity-rule` / без)
   - Уведомление о смене
3. Хоткей + Rofi-меню.

**Альтернатива:** одна настройка `active_opacity` / `inactive_opacity` в `picom.conf` через `sed`. Грязнее — правила `opacity-rule` всё равно нужно менять.

**Сложность:** низкая. ~30 минут **после** тем.

---

## ⌨️ Спорный хоткей `Super+Alt+T` (Telegram + Proxy)

**Статус:** не решено. **Не блокирует темы**, но решить до реализации.

**Проблема:** буква **T** логично ассоциируется с двумя разными вещами:
1. **Telegram** (как сейчас)
2. **Themes** (когда будешь делать)

**Варианты:**

| Комбинация | Что | Плюс | Минус |
|---|---|---|---|
| `Super+Alt+T` → Telegram (**сейчас**) | Telegram + Proxy | Уже привык, T = Telegram | Нельзя занять под Themes |
| `Super+Alt+T` → Themes | Переключатель тем | T = Themes | Ломает привычку |
| `Super+Alt+G` → Telegram | Telegram + Proxy | G = телеГрам, свободно | Менее очевидно |
| `Super+Alt+Shift+T` → Themes | Переключатель тем | T сохранён за Telegram | Длинная комбинация |

**Решение (предварительное):** Telegram остаётся на `Super+Alt+T`. Темы — на `Super+Alt+Shift+T` (или `Super+Alt+Y`). Прозрачность — отдельно.

---

## 🐛 Известные ограничения (не TODO, а «принято»)

- **Dunst: второе+ уведомление появляется без анимации.** Конфликт Picom `geometry` с логикой стека Dunst. Вернёмся после обновления Picom (13+).
- **`window-height` не парсится с унарным минусом.** Пишем `"0 - window-height"` вручную.
- **Celeron N4120: профиль `performance` в PPD недоступен.** Особенность платформы (TDP 6 Вт, пассивное охлаждение). В PPD доступны только `balanced` и `power-saver`. Если нужен `performance` — вручную через `cpufreq-set` (не сохраняется после ребута).

---

## 💡 Идеи на подумать (не обещания)

- **Уведомление-«превью» при переключении темы** — показывать пример в Dunst.
- **Автоматическая тема по времени суток** — dark с 20:00 до 08:00, light днём. Через `cron` или `systemd timer`.
- **Тема из обоев** — `matugen` / `pywal` для генерации палитры. Отдельный проект.
- **Упрощение `brightness.sh`** — оставить только `"icon"` и `"both"`, удалить `"bar"`, `"icon-bar"`, `"bar-icon"`.
- **Ревизия `ICON_STYLE` в `battery.sh`** — если через месяц не переключал, оставить только `"horizontal"`.