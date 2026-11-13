v1.7.0 — Editors, Themes & a Cleaner Layout

What's done

Two weeks of work on the desktop layer: a Neovim config and a plugin-free Vim setup, one Tokyo Night palette across GTK/Qt/CopyQ/MC/Telegram/EasyEffects, user commands moved to `~/.local/bin`, and a switchable Bash prompt.

## ⌨️ Neovim & Vim

- **Neovim:** Lua config on the built-in `vim.pack` (no plugin manager), LSP through Mason + `vim.lsp.config`, Treesitter, telescope, blink.cmp, neo-tree (fixed 32-column sidebar, files open to the right), gitsigns, lualine, which-key. Plugin versions pinned by `nvim-pack-lock.json`, hotkeys documented in `CHEATSHEET.md`.
- **Vim:** plugin-free `~/.vimrc` — syntax and filetype detection, hybrid line numbers, persistent undo, 4/2-space indents per language, correct filetype for `sxhkdrc`, `bspwmrc`, `xinitrc`, `dunstrc`, `picom.conf`.

## 🎨 One theme everywhere

- **GTK3:** hand-written CSS over `Adwaita-dark` — named colors plus direct widget selectors, with Adwaita's own hover/active/backdrop backgrounds reset explicitly.
- **GTK4:** libadwaita CSS variables only, plus a `@define-color` compatibility layer.
- **Qt5/Qt6:** 21-role palettes (`#AARRGGBB`, Fusion, Papirus-Dark); `QT_QPA_PLATFORMTHEME=qt6ct` covers Qt5 apps too.
- **Also styled:** CopyQ, Midnight Commander skin, Telegram palette (manual install), EasyEffects presets, separate `fastfetch` configs for X11 and TTY.
- **Flatpak:** `link.sh` adds read-only access to the GTK/Qt configs and themes, so sandboxed apps see the same look.

## 🗂 Commands live where commands belong

- `battery`, `cheatsheet`, `dunst-history`, `powermenu`, `power-profile`, `screenshot`, `session-restart`, `volume`, `wifi` now live in `~/.local/bin` and are called by name from `sxhkdrc` and Polybar.
- `config/sxhkd/scripts/` keeps only focused-window hotkey glue: `flag.sh`, `to-preselect.sh`, `preselect-cancel-all.sh`.
- `link.sh` links commands **one file at a time**, so foreign binaries in `~/.local/bin` (`nvim`, `tree-sitter`, `zed`) are never touched; `unlink.sh` removes only its own links.
- The old sxhkd ↔ polybar cross-dependency is gone: `power-profile` is no longer a panel script.

## 🐚 Switchable Bash prompt

- The prompt moved out of `~/.bashrc` into `~/.config/bash/themes/<name>.bash`, selected by `BASH_PROMPT` (default `tokyo-night`).
- Three presets: `tokyo-night` (Debian → directory → git → arrow), `tokyo-night-minimal` (single line, no `git` calls), `empty` (template with commented examples).
- Window title is now refreshed with every prompt; the dead `force_color_prompt` block is gone.

## ⚙️ Install & maintenance

- Requirements split into `apt.txt`, `apt-system.txt` and `software.txt`; `scripts/software.sh` installs optional apps.
- `scripts/install-node.sh` sets up NodeSource LTS with npm packages in `~/.npm-global` (no sudo).
- `wallpaper.sh` removed: wallpapers are set by `feh` in `bspwmrc`.
- `unlink.sh` got a stricter symlink check and now also cleans `~/.local/bin` and MC skins.
- Eco mode: `picom-eco.conf` is chosen on `power-saver`, and `power-profile` restarts Picom when the profile changes.

## 🐛 Fixes

- Screenshots land in CopyQ history and the clipboard; a cancelled region capture stays silent.
- `pavucontrol` replaced by `pavucontrol-qt` (the GTK build pulled in Adwaita).
- Popup menus in GTK apps no longer get broken shadows in Picom.
- Battery icons, the caps-lock symbol and the fastfetch layout are aligned with the stock modules.

## 🧭 Direction

- The project stays on **BSPWM/X11**. The archive plan and the Sway/Wayland migration are dropped: Debian is stable, while the Wayland compositors worth using ship as rolling releases.

## ⚠️ Migration notes

- Commands moved out of `~/.config/sxhkd/scripts/` and `~/.config/polybar/scripts/`. Run `./scripts/link.sh` after pulling — it creates the `~/.local/bin` links. `unlink.sh` can remove them.
- The Bash prompt now comes from `config/bash` → `~/.config/bash`. To change the preset, edit `BASH_PROMPT=` in `~/.bashrc` and open a new shell.
- Neovim's first launch needs network access: `vim.pack` downloads plugins, Mason installs LSP servers.

🚀 Update Instructions

```bash
cd ~/BSPWM-machineslego
git pull origin main
./scripts/link.sh
```

Then reload the session: `Super + Alt + Shift + R`.

(`link.sh` is enough for a regular update — it re-links configs, commands and skins. `install.sh` is only needed on a fresh machine.)

---

v1.7.0 — редакторы, темы и порядок в файлах

Что сделано

Две недели работы над «рабочим столом»: конфиг Neovim и Vim без плагинов, одна палитра Tokyo Night для GTK/Qt/CopyQ/MC/Telegram/EasyEffects, пользовательские команды переехали в `~/.local/bin`, а промпт Bash стал сменным.

## ⌨️ Neovim и Vim

- **Neovim:** конфиг на Lua со встроенным `vim.pack` (без менеджера плагинов), LSP через Mason + `vim.lsp.config`, Treesitter, telescope, blink.cmp, neo-tree (фиксированный сайдбар 32 колонки, файлы открываются справа), gitsigns, lualine, which-key. Версии плагинов зафиксированы в `nvim-pack-lock.json`, хоткеи — в `CHEATSHEET.md`.
- **Vim:** `~/.vimrc` без плагинов — синтаксис и типы файлов, гибридная нумерация, постоянная история undo, отступы 4/2 пробела по языкам, правильный filetype для `sxhkdrc`, `bspwmrc`, `xinitrc`, `dunstrc`, `picom.conf`.

## 🎨 Одна тема везде

- **GTK3:** свой CSS поверх `Adwaita-dark` — именованные цвета плюс прямые селекторы; фоны Adwaita в hover/active/backdrop сброшены явно.
- **GTK4:** только переменные libadwaita, плюс слой совместимости `@define-color`.
- **Qt5/Qt6:** палитры на 21 роль (`#AARRGGBB`, Fusion, Papirus-Dark); `QT_QPA_PLATFORMTHEME=qt6ct` покрывает и Qt5-приложения.
- **Также оформлены:** CopyQ, скин Midnight Commander, палитра Telegram (ручная установка), пресеты EasyEffects, отдельные конфиги `fastfetch` для X11 и TTY.
- **Flatpak:** `link.sh` выдаёт read-only доступ к конфигам GTK/Qt и темам, чтобы приложения в песочнице выглядели так же.

## 🗂 Команды там, где им место

- `battery`, `cheatsheet`, `dunst-history`, `powermenu`, `power-profile`, `screenshot`, `session-restart`, `volume`, `wifi` теперь лежат в `~/.local/bin` и вызываются по имени из `sxhkdrc` и Polybar.
- В `config/sxhkd/scripts/` остался только хоткей-«клей» для focused-окна: `flag.sh`, `to-preselect.sh`, `preselect-cancel-all.sh`.
- `link.sh` линкует команды **поштучно**, поэтому чужие бинарники в `~/.local/bin` (`nvim`, `tree-sitter`, `zed`) не трогаются; `unlink.sh` удаляет только свои ссылки.
- Двунаправленная зависимость sxhkd ↔ polybar исчезла: `power-profile` больше не «скрипт панели».

## 🐚 Сменный промпт Bash

- Промпт вынесен из `~/.bashrc` в `~/.config/bash/themes/<имя>.bash`, выбор — через `BASH_PROMPT` (по умолчанию `tokyo-night`).
- Три пресета: `tokyo-night` (Debian → папка → git → стрелка), `tokyo-night-minimal` (одна строка, без вызовов `git`), `empty` (шаблон с закомментированными примерами).
- Заголовок окна теперь обновляется с каждым промптом; мёртвый блок `force_color_prompt` удалён.

## ⚙️ Установка и обслуживание

- Списки пакетов разделены: `apt.txt`, `apt-system.txt`, `software.txt`; `scripts/software.sh` ставит дополнительный софт.
- `scripts/install-node.sh` настраивает NodeSource LTS, глобальные npm-пакеты — в `~/.npm-global` (без sudo).
- `wallpaper.sh` удалён: обои ставятся через `feh` в `bspwmrc`.
- В `unlink.sh` усилена проверка симлинков, добавлена чистка `~/.local/bin` и скинов MC.
- Eco-режим: при `power-saver` выбирается `picom-eco.conf`, а `power-profile` перезапускает Picom при смене профиля.

## 🐛 Исправления

- Скриншоты попадают в историю CopyQ и в буфер; отмена выделения области — без уведомления.
- `pavucontrol` заменён на `pavucontrol-qt` (GTK-сборка тянула Adwaita).
- Контекстные меню GTK-приложений больше не получают кривые тени в Picom.
- Иконки батареи, символ Caps Lock и раскладка fastfetch приведены к стоковым модулям.

## 🧭 Направление

- Проект остаётся на **BSPWM/X11**. План архивации и переезд на Sway/Wayland отменены: Debian стабилен, а нужные Wayland-композиторы идут роллингом.

## ⚠️ Что сделать после обновления

- Команды уехали из `~/.config/sxhkd/scripts/` и `~/.config/polybar/scripts/`. После `git pull` запусти `./scripts/link.sh` — он создаст ссылки в `~/.local/bin`. Убрать их можно через `unlink.sh`.
- Промпт Bash теперь берётся из `config/bash` → `~/.config/bash`. Чтобы сменить пресет, поправь `BASH_PROMPT=` в `~/.bashrc` и открой новый шелл.
- Первый запуск Neovim требует сети: `vim.pack` качает плагины, Mason ставит LSP-серверы.

🚀 Инструкция по обновлению

```bash
cd ~/BSPWM-machineslego
git pull origin main
./scripts/link.sh
```

Затем перезапусти сессию: `Super + Alt + Shift + R`.

(`link.sh` достаточно для обычного обновления — он перелинкует конфиги, команды и скины. `install.sh` нужен только на новой машине.)
