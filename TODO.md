# TODO

Текущие задачи и идеи для будущих релизов.

## 🎨 Темы и прозрачность

### Переключатель тем (dark / light) через Rofi

**Идея:** Rofi-меню по хоткею (`Super+Alt+T`?) с выбором «Tokyo Night Dark» / «Tokyo Night Day».

**План:**
1. Создать структуру `~/.config/themes/`:
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
2. Подключить include в существующие конфиги:
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

**Сложность:** средняя. ~1 вечер.

**Нюансы:**
- Picom и Polybar **перезапускаются** (нет сигнала reload) — на мгновение мигнут.
- Dunst перечитывает конфиг через `dunstctl reload`, без убийства.
- Rofi и Alacritty читают конфиг при каждом запуске — перезапуск не нужен.
- GTK-приложения (Thunar) подхватывают `gsettings` на лету.

---

### Переключатель прозрачности (on / off)

**Идея:** Отдельный тумблер через Rofi-меню: «Прозрачность: вкл / выкл».

**План:**
1. Два `picom.conf` (или symlink + sed):
   - `picom.conf` (непрозрачный) — текущий, `opacity-rule` закомментирован
   - `picom-transparent.conf` — с `opacity-rule = ["90:class_g = 'Alacritty'", "95:class_g = 'Thunar'", ...]`
2. Скрипт `transparency-toggle.sh`:
   - Определить текущее состояние (какой конфиг активен)
   - Переключить симлинк на `picom.conf`
   - `pkill -x picom && picom --config ... &`
   - Уведомление о смене
3. Хоткей + Rofi-меню.

**Альтернатива:** одна настройка `active_opacity` / `inactive_opacity` в `picom.conf` через `sed`. Но это грязнее — правила `opacity-rule` всё равно нужно менять.

**Сложность:** низкая. ~30 минут.

---

## 🐛 Известные ограничения (не TODO, а «принято»)

- **Dunst: второе+ уведомление появляется без анимации.** Конфликт Picom `geometry` с логикой стека Dunst. Вернёмся после обновления Picom (13+).
- **`window-height` не парсится с унарным минусом.** Пишем `"0 - window-height"` вручную.

---

## 💡 Идеи на подумать

- **Уведомление-«превью» при переключении темы** — показывать пример в Dunst, чтобы сразу видеть, как выглядит (можно проверить вручную через `notify-send`, если понадобится).
- **Автоматическая тема по времени суток** — dark с 20:00 до 08:00, light днём. Через `cron` или `systemd timer`.
- **Тема из обоев** — `matugen` / `pywal` для генерации палитры. Отдельный проект, не для этого репо.
- **`gtk-3.0/settings.ini` и `gtk-4.0/settings.ini`** — тоже переключать через `gsettings` (уже покрыто в плане темы выше).