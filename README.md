# BSPWM-machineslego

![Debian](https://img.shields.io/badge/Debian-13%20Trixie-A81D33?logo=debian&logoColor=white)
![X11](https://img.shields.io/badge/X11-only-blue)
![BSPWM](https://img.shields.io/badge/WM-BSPWM-black)
![License](https://img.shields.io/badge/License-MIT-green)

Конфигурация рабочего окружения на базе BSPWM для Debian 13 Trixie с оформлением в палитре Tokyo Night.

![Desktop](screenshots/desktop-actual.png)
![Workspace](screenshots/workspace-example-actual.png)
![Rofi](screenshots/rofi-actual.png)

Развернутое правая часть Polybar

![Unfolded-right-modules](screenshots/unfolded-polybar-actual.png)

## Особенности

- **Native Modules First:** Стоковые модули Polybar для батареи, сети и звука.
- **Без прозрачности и блюра:** Отключено в Alacritty, Polybar и Picom. Только строгие цвета Tokyo Night.
- **Статичная шпаргалка:** Меню `Super + /` с иконками и скрытыми тегами для поиска через Rofi.
- **Универсальное железо:** Автоопределение батарей (`BAT0`/`BAT1`) и адаптеров питания.
- **Управление без лишних апплетов:** Wi-Fi через `nmtui`, звук через `pavucontrol`. Исключение — `blueman` для Bluetooth (в трее).
- **Фикс сети:** Установщик копирует исправленный `/etc/network/interfaces` и настройки NetworkManager, решая проблемы с Wi-Fi при чистой установке.

## 📦 Структура

```text
BSPWM-machineslego/
├── config/                 # Симлинки в ~/.config/*
│   ├── alacritty, bspwm, dunst, fastfetch, picom, rofi
│   ├── gtk-3.0, gtk-4.0    # Настройки тем GTK
│   ├── polybar/
│   │   ├── config.ini      # Стоковые модули + кастомная яркость
│   │   └── scripts/
│   │       ├── battery.sh          # Фолбэк-скрипт батареи
│   │       ├── brightness.sh       # Скрипт яркости (с точечным индикатором)
│   │       ├── power-profile-ppd.sh # Профиль питания для PPD
│   │       └── power-profile-tlp.sh # Профиль питания для TLP
│   └── sxhkd/
│       ├── sxhkdrc         # Горячие клавиши
│       └── scripts/        # autocheatsheet, powermenu, sensors, volume
├── home/                   # Симлинки в ~/*
├── system/                 # Копируется в /etc (тачпад, NetworkManager, фикс сети)
├── scripts/                # install.sh, link.sh, unlink.sh
├── screenshots/
└── wallpapers/
```

## 📋 Требования

- **ОС:** Debian 13 Trixie (или совместимый дистрибутив).
- **Базовые утилиты:** `git`, `sudo`, интернет для загрузки пакетов.
- **Nerd Font** (устанавливается установщиком автоматически).
- **Права sudo** для установки пакетов `apt` и копирования файлов в `/etc`.

## 🛠 Установка

```bash
git clone https://github.com/machineslego-wq/BSPWM-machineslego ~/BSPWM-machineslego
cd ~/BSPWM-machineslego
chmod +x scripts/*.sh
./scripts/install.sh
```

**Что делает `install.sh`:**
- Ставит пакеты через `apt`.
- Скачивает Nerd Font с официального релиза и кладёт в `~/.local/share/fonts`.
- Настраивает `sudoers` для профиля питания.
- Копирует конфиги тачпада, NetworkManager и фикс `/etc/network/interfaces` в `/etc`.
- Создаёт симлинки в `~/.config/*` и `~/*`.

**Если не нужно трогать `/etc`:** используйте `./scripts/link.sh`.
**Откат:** `./scripts/unlink.sh` (удаляет только симлинки, пакеты и файлы в `/etc` остаются).

**Запуск:** `startx` (или через LightDM).

## 🖼️ Обои и тема

Затемнение обоев под палитру Tokyo Night через ImageMagick:
```bash
convert /path/to/original.jpg -fill "#1a1b26" -colorize 50% -modulate 80,80,100 /path/to/tokyo-night-wallpaper.jpg
```

## ⌨️ Горячие клавиши

**Полная шпаргалка:** `Super + /` (Rofi, поиск по скрытым тегам).

| Комбинация | Действие |
|---|---|
| `Super + Enter` | Терминал (Alacritty) |
| `Super + /` | Шпаргалка (Rofi) |
| `Super + W` | Закрыть окно |
| `Super + 1…9` | Переключение рабочих столов |
| `Super + Shift + 1…9` | Переместить окно на рабочий стол |
| `Super + D` | Лаунчер (Rofi drun) |
| `Print` | Скриншот всего экрана |
| `Shift + Print` | Скриншот окна |
| `Super + Shift + S` | Скриншот области |

> Точный список — в `config/sxhkd/sxhkdrc`.

## 🔧 Устранение неполадок

- **Нет иконок в Polybar/Rofi** → Проверьте: `fc-list | grep -i "nerd"`. Переустановите: `./scripts/install.sh`.
- **`startx` не запускается** → Проверьте наличие `exec bspwm` в `~/.xinitrc` и пакет `xorg`.
- **Не работают горячие клавиши** → Проверьте `pgrep sxhkd`. Перезапустите: `pkill -USR1 -x sxhkd`.
- **Не работает звук/яркость** → Установите `pavucontrol` и `brightnessctl`.
- **Polybar не стартует** → Проверьте симлинк `~/.config/polybar` и права на `launch.sh` (`chmod +x`).
- **Конфликт TLP и PPD** → Одновременно должен быть активен только один (`systemctl status tlp` / `power-profiles-daemon`).
- **Пропал Wi-Fi** → Перезапустите NetworkManager: `sudo systemctl restart NetworkManager` (убедитесь, что фикс `/etc/network/interfaces` скопирован).

## 📄 Лицензия

- Конфигурации и скрипты — **MIT**.
- Шрифты (JetBrains Mono Nerd Font) — **SIL Open Font License 1.1**.