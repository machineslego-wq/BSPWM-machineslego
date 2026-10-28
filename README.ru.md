# BSPWM-machineslego

[English](./README.md) | **Русский**

![Debian](https://img.shields.io/badge/Debian-13%20Trixie-A81D33?logo=debian&logoColor=white)
![X11](https://img.shields.io/badge/X11-only-blue)
![PipeWire](https://img.shields.io/badge/PipeWire-Audio-blue?logo=pipewire&logoColor=white)
![BSPWM](https://img.shields.io/badge/WM-BSPWM-black)
![Fish](https://img.shields.io/badge/Shell-Fish-green)
![License](https://img.shields.io/badge/License-MIT-green)

Строгое, плоское рабочее окружение на базе BSPWM для Debian 13 Trixie в палитре Tokyo Night.

![Рабочий стол](screenshots/desktop.png)

<details>
<summary><b>Показать больше скриншотов</b></summary>
<br>

![Рабочее пространство](screenshots/workspace+notify.png)
![Rofi](screenshots/rofi-showcase.png)
![Менеджер Wi-Fi](screenshots/wifi-manager.png)

</details>

## ✨ Особенности

- **Native Modules First:** Polybar использует стоковые `internal/battery`, `internal/backlight`, `internal/network` и `internal/pulseaudio`. Ноль фоновых bash-циклов.
- **Скрипты по требованию:** Кастомная логика (Wi-Fi, Rofi-меню, скриншоты) запускается только по хоткею и сразу завершается.
- **Современная оболочка:** Терминал на **Fish** с промптом **Tide**. Быстрые автодополнения, подсветка синтаксиса и интеграция с Git без фоновых демонов.
- **Плавность и плоский дизайн:** Анимации окон в стиле Hyprland через Picom, никакого блюра, строгие цвета Tokyo Night.
- **Умный OSD громкости:** Уведомления меняют цвет в зависимости от уровня звука.
- **Workflow:** История буфера (CopyQ), история уведомлений (Rofi), быстрые скриншоты в буфер и подробная шпаргалка.
- **Стабильность:** Все демоны (`picom`, `dunst`, `lxpolkit` и др.) защищены от дублирования через `pgrep` и `pkill` в `bspwmrc`.

## 📦 Структура

```text
BSPWM-machineslego/
├── config/                 # Симлинки в ~/.config/*
│   ├── bspwm, dunst, picom, rofi, alacritty...
│   ├── fish/               # Настройки Fish shell
│   │   ├── config.fish     # Алиасы и базовые настройки
│   │   └── fish_plugins    # Отслеживание плагинов Tide (через Fisher)
│   ├── polybar/
│   │   ├── config.ini      # Стоковые модули + нативные батарея/яркость
│   │   └── scripts/
│   │       └── power-profile.sh    # Чтение профиля PPD
│   └── sxhkd/
│       ├── sxhkdrc         # Горячие клавиши
│       └── scripts/        # battery (детали в Rofi), wifi, powermenu и др.
├── home/                   # Симлинки в ~/*
├── system/                 # Копируется в /etc
├── scripts/                # install.sh, link.sh, unlink.sh
├── TODO.md                 # Планы
└── wallpapers/
```

## 📋 Требования

- **ОС:** Debian 13 Trixie.
- **Утилиты:** `git`, `sudo`, интернет.
- **Аудио:** Оптимизировано под **PipeWire**.
- **Sudo:** Для установки пакетов и копирования конфигов в `/etc`.

## 🛠 Установка

```bash
git clone https://github.com/machineslego-wq/BSPWM-machineslego ~/BSPWM-machineslego
cd ~/BSPWM-machineslego
chmod +x scripts/*.sh
./scripts/install.sh
```
- **Без изменений в `/etc`:** `./scripts/link.sh`
- **Откат:** `./scripts/unlink.sh`
- **Запуск:** `startx` (или через LightDM).

### ⚙️ Кастомизация после установки

**Fish и Tide Prompt:**
`install.sh` автоматически устанавливает Fisher и промпт Tide. После установки открой терминал и выполни:
```bash
tide configure
```
Этот интерактивный мастер поможет настроить стиль, цвета и иконки промпта под твои предпочтения.

**Wi-Fi Менеджер:**
Скрипт `wifi.sh` настроен под мои устройства. Открой `~/.config/sxhkd/scripts/wifi.sh` и добавь имя своего интерфейса (например, `wlan0`, `wlp3s0`) в блок `if/elif`. Задай свой `HOTSPOT_SSID` и `HOTSPOT_PASSWORD` в начале файла.

**Поведение крышки ноутбука:**
По умолчанию закрытие крышки отправляет в сон. Чтобы **блокировать без сна**:
```bash
sudo rm /etc/systemd/logind.conf.d/10-lid-suspend.conf
sudo tee /etc/systemd/logind.conf.d/10-lid-lock.conf > /dev/null <<'EOF'
[Login]
HandleLidSwitch=lock
HandleLidSwitchExternalPower=lock
EOF
sudo systemctl kill -s HUP systemd-logind
```

## ⌨️ Горячие клавиши

**Полная шпаргалка:** `Super + /` (Rofi).

| Комбинация | Действие |
|---|---|
| `Super + Return` | Терминал (Alacritty) |
| `Super + D` | Лаунчер (Rofi) |
| `Super + /` | Шпаргалка |
| `Super + Alt + N` | Wi-Fi Менеджер |
| `Super + Shift + Q` | Меню питания (Rofi) |
| `Super + Alt + B` | Детали батареи (Rofi) |
| `Super + Alt + H` | История уведомлений |
| `Super + Ctrl + V` | История буфера (CopyQ) |
| `Super + F1/F2/F3` | Скриншоты (Экран/Окно/Задержка) |
| `Super + Shift + S` | Скриншот области |
| `Super + H/J/K/L` | Двигать флоат (Vim-style) |
| `Super + 1…0` | Переключение столов |
| `Super + Shift + 1…0` | Перенос окна на стол |
| `Super + Alt + Shift + R` | Перезапуск всей системы |

## 🐛 Известные проблемы (Picom и UI)

- **Анимация стека Dunst:** Анимируется только первое уведомление. Второе и последующие появляются мгновенно из-за известного конфликта **Picom 12.5** с позиционированием Dunst.
- **Тени контекстных меню:** У контекстных меню Telegram (Flatpak) и Firefox плохо рендерятся тени. Именно поэтому они явно исключены в `picom.conf` (`shadow = false`).
- **Сон на AMD:** На Ryzen 7000-й серии ноутбук может выключаться вместо сна. Добавь `mem_sleep_default=s2idle` в GRUB, если столкнулся с этим.

## 📄 Лицензия

MIT