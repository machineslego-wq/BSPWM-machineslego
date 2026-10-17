# BSPWM-machineslego

Конфигурация рабочего окружения на базе BSPWM для Debian 13 Trixie с оформлением в палитре Tokyo Night.

## TODO

- Добавить Rofi-скрипты для управления Bluetooth и Wi-Fi (полная замена `blueman-applet`).

## Последние изменения

- **Динамическое определение батареи:** В Polybar возвращён стоковый модуль `internal/battery`, но имена устройств (`BAT0`/`BAT1` и `AC`/`ADP1`) теперь определяются автоматически через переменные окружения в `bspwmrc`. Работает на любых ноутбуках без правки конфига.
- **Универсальный звук:** Добавлен скрипт `volume.sh`, который автоматически определяет аудиосервер. Если запущен PipeWire — используется `wpctl`, если PulseAudio — `pactl`.
- **Гибридное управление питанием:** Установщик определяет наличие `power-profiles-daemon` (GNOME), TLP или настраивает `cpupower` для ПК.
- **Фикс клавиатуры:** В `bspwmrc` добавлена принудительная установка раскладки `setxkbmap`, чтобы CapsLock работал как переключатель языка даже при входе через GDM.
- **Смена структуры:** Репозиторий разделён на папки `config/`, `home/`, `system/` и `scripts/`.

## Аппаратная база

Конфигурация собрана и протестирована на двух ноутбуках:

1. **Acer TravelMate B1 (TMB118 C0EA)** — 1366×768, 4 ГБ ОЗУ, Celeron N4120, 120 ГБ SSD.
2. **Nipogi LX15 Pro** — 1920×1080, 20 ГБ ОЗУ, Ryzen 5 7430U, 256 ГБ NVMe.

Все размеры в конфигах по умолчанию подобраны под 1366×768. При развёртывании на FullHD экране (второй ноутбук) необходимо внести правки — см. раздел «Перенос на 1920×1080».

## Состав

| Компонент | Назначение |
|---|---|
| BSPWM | Тайловый оконный менеджер |
| SXHKD | Демон горячих клавиш |
| Polybar | Статус-панель |
| Rofi | Лаунчер и меню |
| Dunst | Уведомления |
| Picom | Композитор |
| Alacritty | Терминал |
| Feh | Установка обоев |
| Scrot | Скриншоты |
| i3lock-fancy | Блокировка экрана |
| Fastfetch | Информация о системе |
| LXAppearance | Настройка GTK-темы и курсора |
| Thunar | Файловый менеджер |
| TLP / cpupower / PPD | Управление питанием (зависит от системы) |
| Blueman | Bluetooth-апплет (временно) |

Цветовая палитра: Tokyo Night (background `#1a1b26`, акцент `#7aa2f7`).

## Структура репозитория

```text
BSPWM-machineslego/
├── config/                 # Симлинки в ~/.config/*
│   ├── alacritty/
│   ├── bspwm/
│   ├── dunst/
│   ├── fastfetch/
│   ├── picom/
│   ├── polybar/
│   │   └── scripts/
│   │       ├── battery-menu.sh
│   │       ├── power-profile-laptop.sh
│   │       ├── power-profile-pc.sh
│   │       ├── power-profile-ppd.sh
│   │       └── volume.sh
│   ├── rofi/
│   └── sxhkd/
├── home/                   # Симлинки в ~/*
│   ├── xinitrc             # -> ~/.xinitrc
│   └── Xresources          # -> ~/.Xresources
├── system/                 # Копируется в /etc (с бэкапом)
│   ├── X11/xorg.conf.d/30-touchpad.conf
│   ├── NetworkManager/NetworkManager.conf
│   └── network/interfaces
├── scripts/                # Служебные скрипты
│   ├── install.sh          # Главный установщик
│   ├── link.sh             # Линковщик конфигов
│   └── unlink.sh           # Удаление симлинков
├── screenshots/
├── wallpapers/
├── .gitignore
└── readme.md
```

## Установка на новую машину

### Шаг 1. Клонировать репозиторий
```bash
git clone https://github.com/machineslego-wq/BSPWM-machineslego ~/BSPWM-machineslego
cd ~/BSPWM-machineslego
```

### Шаг 2. Установить шрифты Nerd Font
В репозиториях Debian нужного шрифта нет, поэтому ставим вручную:
1. Скачать `JetBrainsMono.zip` с [nerdfonts.com](https://www.nerdfonts.com/font-downloads).
2. `sudo apt install unzip`
3. Распаковать в `~/.local/share/fonts/`:
   ```bash
   mkdir -p ~/.local/share/fonts
   unzip ~/Загрузки/JetBrainsMono.zip -d ~/.local/share/fonts/
   fc-cache -fv
   ```

### Шаг 3. Запустить установщик
Скрипт установит нужные пакеты, настроит `sudoers` (для работы профилей питания без пароля), создаст симлинки и скопирует системные конфиги.

```bash
chmod +x scripts/*.sh
./scripts/install.sh
```
В процессе установки скрипт:
1. Проверит наличие `power-profiles-daemon` (если он есть, как в GNOME, — пропустит установку TLP/`cpupower`).
2. Если PPD нет, спросит тип устройства: **Ноутбук (TLP)** или **ПК (cpupower)**.
3. Запросит пароль `sudo` для установки пакетов и настройки `/etc`.

*Если вы не хотите менять системные файлы в `/etc`, запустите только линковщик: `./scripts/link.sh`.*

### Шаг 4. Запуск графической сессии
Убедитесь, что `~/.xinitrc` создан. Запустите X-сервер:
```bash
startx
```

*Откатить установку пользовательских симлинков: `./scripts/unlink.sh`*

## Настройка окружения

`install.sh` автоматически применяет конфиги тачпада и NetworkManager. Если вы запускали только `link.sh`, выполните вручную:

### Wi-Fi через NetworkManager
1. В `/etc/network/interfaces` закомментировать строки с Wi-Fi.
2. В `/etc/NetworkManager/NetworkManager.conf` установить `managed=true`.
3. `sudo systemctl stop wpa_supplicant && sudo systemctl disable wpa_supplicant`
4. `sudo systemctl restart NetworkManager`
5. `nmcli device wifi connect "SSID" password "password"`

### Управление питанием
В панели Polybar есть модуль `power-profile`, который автоматически подстраивается под систему:
- **power-profiles-daemon (PPD)**: Если установлен (обычно вместе с GNOME), скрипт использует `powerprofilesctl` для переключения между Performance, Balanced и Power Saver.
- **Ноутбуки (TLP)**: Использует `tlp` для переключения между режимами Авто, От сети, От батареи.
- **ПК (cpupower)**: Переключает governor процессора (Performance, Balanced, Powersave).

## Особенности конфигурации

- **Универсальная батарея:** В `config/polybar/config.ini` используется стоковый `internal/battery`, но имена устройств берутся из переменных `${env:POLYBAR_BAT:BAT0}` и `${env:POLYBAR_AC:AC}`. Переменные задаются в `bspwmrc` через автоопределение, что делает конфиг рабочим на любом ноутбуке.
- **Универсальный звук:** Горячие клавиши громкости вызывают `volume.sh`, который проверяет наличие процесса `pipewire` и выбирает между `wpctl` и `pactl`.
- **Два режима панели:** В `config/polybar/config.ini` закомментированы два варианта. Активный — «парящая» панель. Альтернативный — «прибитая к верху».
- **Скругления окон:** Обеспечивает Picom (`corner-radius = 8`). Тени и размытие отключены для слабого железа.
- **Уведомления:** Dunst рисует скругления сам (`corner_radius = 10`), Picom исключает класс `Dunst`.
- **Меню питания:** Единый скрипт `powermenu.sh` вызывается и из Polybar, и по горячим клавишам. Показывает Rofi-окно с выбором «Да/Нет».

## Перенос на 1920×1080

При развёртывании на Lenovo (FHD) необходимо внести следующие правки:

**Polybar** (`config/polybar/config.ini`):
```ini
height = 36px # заменить на 44px
```

**BSPWM** (`config/bspwm/bspwmrc`):
```bash
bspc config top_padding 36 # заменить на 44
bspc config window_gap 2   # заменить на 4-6
```

**Шрифт Polybar:** Увеличить `size=12` до `13` или `14`.
**Обои:** Подобрать картинку под 1920×1080 из папки `wallpapers/`.

## Известные ограничения

- На Celeron N4120 (Acer) не рекомендуется включать эффекты размытия в Picom и тяжёлые модули в Polybar.
- Polybar и SXHKD запускают команды через `/bin/sh` (dash). Флаг `echo -e` не работает, используйте `printf`.
- В `.ini`-конфиге Polybar inline-комментарии (`;` после значения) не поддерживаются.
- `internal/pulseaudio` в Polybar 3.7.2 не поддерживает format-теги `%{T1}` (размер только иконок громкости изменить нельзя).

## Скриншоты

![Screenshot](screenshots/screenshot.png)
![2026-10-17_17-56-38.png](screenshots/2026-10-17_17-56-38.png)
![2026-10-17_17-56-43.png](screenshots/2026-10-17_17-56-43.png)

## Лицензия

Конфигурация свободна к использованию и модификации.