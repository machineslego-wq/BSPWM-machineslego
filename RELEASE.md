v1.7.1 — Fixed Menus & Machine Tools

What's done

A compact release around the menus and the setup itself: Rofi no longer depends on the monitor size, two helpers describe and verify the rice, nine machine commands moved into `local/bin`, and the little rendering annoyances are gone.

## 🧩 Rofi: one size on every screen

- Menu widths used to be a percentage of the monitor, so the same menu was 574 px on a 1366-wide screen and 806 px on a 1920-wide one. They are now set in `em`: the unit follows the font, not the screen.
- Launcher 800 px; `battery` 580; `wifi` 480 (network picker and hidden SSID 580); `power-profile` 420; `powermenu` 380; `cheatsheet` 960×760; notification history 960×540. All of them are identical from 1366×768 up.
- Short menus still take their height from the content: `lines` is only an upper bound, so a four-item prompt stays compact instead of stretching into a tall empty block.

## 🧰 Helpers for the setup

- `rice-help` prints every command in `local/bin` with a one-line description. The list is built from the files themselves, so a new command shows up without editing anything.
- `rice-check` verifies the live setup: symlinks into the repo, the commands and paths used by `sxhkdrc`, `bash -n` on the scripts, and the README screenshots. Run on demand, exit code 0/1.

## 🐳 Machine commands

- `start-llm` (Ollama + OpenWebUI), `start-comfy` (ComfyUI), `vllm-setup`, `yacht`, `mount-nas` (NFS), `openrgb-i2c-fix`, `sddm-avatar`, `check-hardware`, `check-strawberry`.
- A bare command is the quick start; first-time setup and maintenance are flags (`--setup`, `--models`, `--recreate`, `--status`, `--stop`, `--logs`). The interactive y/N questions are gone.
- A command that needs an argument prints usage and exits with 1; `--help` exits with 0.
- `vllm-setup` keeps the API key in `~/.config/vllm/api-key` and reuses it, so restarting the container no longer breaks the client config.
- `start-llm` recreates the Ollama container only when its environment no longer matches, instead of wiping it on every run.

## 🌐 Apache2 virtual hosts

- `vhost-add` and `vhost-remove` create and delete a virtual host together with its `/etc/hosts` entry, site directory and test page.

## 🐛 Fixes

- Polybar: the deprecated `content*` and `label-indicator` keys are replaced with `format`/`label` and `label-indicator-on` — the deprecation warnings are gone.
- Picom: open and close animations are centered, and the shadow follows the window instead of jumping to a corner.
- Alacritty: vertical padding set to 0.
- Telegram: icons and date labels on read media are visible again in the dark palette.
- `start-llm`: `HSA_OVERRIDE_GFX_VERSION=11.0.1` for the current ROCm/GPU combination.

## ⚠️ Migration notes

- The new commands need symlinks: run `./scripts/link.sh` after pulling.
- Rofi reads its config on every launch; Polybar and Telegram need a restart, Alacritty — a new window.

🚀 Update Instructions

```bash
cd ~/BSPWM-machineslego
git pull origin main
./scripts/link.sh
```

Then reload the session: `Super + Alt + Shift + R`.

(`link.sh` is enough for a regular update — it re-links configs, commands and skins. `install.sh` is only needed on a fresh machine.)

---

v1.7.1 — фиксированные меню и машинные команды

Что сделано

Компактный релиз про меню и сам райс: Rofi больше не зависит от размера монитора, две команды описывают и проверяют окружение, девять машинных скриптов переехали в `local/bin`, а мелкие недочёты отрисовки исправлены.

## 🧩 Rofi: один размер на любом экране

- Ширина меню раньше задавалась в процентах от монитора: одно и то же меню было 574 px на экране 1366 и 806 px на 1920. Теперь размеры в `em` — эта единица считается от шрифта, а не от экрана.
- Launcher 800 px; `battery` 580; `wifi` 480 (выбор сети и скрытая сеть — 580); `power-profile` 420; `powermenu` 380; `cheatsheet` 960×760; история уведомлений 960×540. От 1366×768 и выше всё совпадает.
- Высоту короткие меню по-прежнему берут из содержимого: `lines` задаёт только максимум, поэтому меню из четырёх пунктов остаётся компактным, а не растягивается в пустой блок.

## 🧰 Помощники по райсу

- `rice-help` печатает все команды из `local/bin` с описанием в одну строку. Список строится по самим файлам: новая команда появляется в нём без правок.
- `rice-check` проверяет живое окружение: симлинки на репозиторий, команды и пути из `sxhkdrc`, `bash -n` для скриптов, картинки README. Запуск по требованию, код возврата 0/1.

## 🐳 Машинные команды

- `start-llm` (Ollama + OpenWebUI), `start-comfy` (ComfyUI), `vllm-setup`, `yacht`, `mount-nas` (NFS), `openrgb-i2c-fix`, `sddm-avatar`, `check-hardware`, `check-strawberry`.
- Команда без аргументов — быстрый запуск; первичная установка и обслуживание вынесены во флаги (`--setup`, `--models`, `--recreate`, `--status`, `--stop`, `--logs`). Интерактивных вопросов y/N больше нет.
- Команда, которой нужен аргумент, печатает справку и выходит с кодом 1; `--help` — с кодом 0.
- `vllm-setup` хранит API-ключ в `~/.config/vllm/api-key` и переиспользует его: перезапуск контейнера больше не ломает конфиг клиента.
- `start-llm` пересоздаёт контейнер Ollama только если его окружение перестало совпадать, а не при каждом запуске.

## 🌐 Виртуальные хосты Apache2

- `vhost-add` и `vhost-remove` создают и удаляют виртуальный хост вместе с записью в `/etc/hosts`, каталогом сайта и тестовой страницей.

## 🐛 Исправления

- Polybar: устаревшие ключи `content*` и `label-indicator` заменены на `format`/`label` и `label-indicator-on` — предупреждения о deprecation исчезли.
- Picom: анимации открытия и закрытия центрированы, тень следует за окном, а не прыгает в угол.
- Alacritty: вертикальный отступ выставлен в 0.
- Telegram: иконки и дата на прочитанных медиа снова видны в тёмной палитре.
- `start-llm`: `HSA_OVERRIDE_GFX_VERSION=11.0.1` под текущую связку ROCm/GPU.

## ⚠️ Что сделать после обновления

- Новым командам нужны симлинки: после `git pull` запусти `./scripts/link.sh`.
- Rofi читает конфиг при каждом запуске; Polybar и Telegram нужен перезапуск, Alacritty — новое окно.

🚀 Инструкция по обновлению

```bash
cd ~/BSPWM-machineslego
git pull origin main
./scripts/link.sh
```

Затем перезапусти сессию: `Super + Alt + Shift + R`.

(`link.sh` достаточно для обычного обновления — он перелинкует конфиги, команды и скины. `install.sh` нужен только на новой машине.)
