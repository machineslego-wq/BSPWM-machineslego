# BSPWM-machineslego

Конфигурация рабочего окружения на базе BSPWM для Debian 13 Trixie с оформлением в палитре Tokyo Night.

## TODO

- Сделать управление питанием для ноутбука (TLP + `cpupower`).
- Добавить Rofi-скрипты для управления Bluetooth и Wi-Fi (замена `blueman-applet`).

## Последние изменения

- **Глобальная смена структуры:** Репозиторий переведён на разделение по папкам `config/`, `home/`, `system/` и `scripts/`. Обычные конфиги линкуются в `~/.config`, файлы из `home/` — в домашнюю директорию (с добавлением точки), а системные конфиги из `system/` копируются в `/etc` с созданием бэкапа.
- **Новый установщик:** Теперь всё ставится одной командой `./scripts/install.sh`, которая вызывает `link.sh` для симлинков и автоматически применяет системные настройки.
- Апплеты `nm-applet` и `pasystray` более не участвуют в Polybar, они заменены на встроенные модули (`internal/network` и `internal/pulseaudio`).
- Переписан скрипт яркости: теперь в `brightness.sh` можно выбрать стиль отображения (только иконка, только полоса, или всё вместе).
- В конфиге Polybar добавлена возможность переключения между «парящей» панелью и панелью, прибитой к верхнему краю (см. комментарии в `[bar/main]`).
- Добавлены обои в папку `wallpapers/`.

## Аппаратная база

Конфигурация собрана и протестирована на:

- Ноутбук: Acer TravelMate B1 (TMB118 C0EA)
- Экран: 1366×768
- ОЗУ: 4 ГБ
- Накопитель: 120 ГБ SSD
- Процессор: Intel Celeron N4120
- Wi-Fi: Intel Wireless 9260
- Видео: Intel UHD Graphics 600

Все размеры и настройки подобраны под низкое разрешение и слабое железо. При переносе на другую машину часть параметров нужно скорректировать — см. раздел «Перенос на 1920×1080».

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
| Fastfetch | Информация о системе в терминале |
| JetBrainsMono Nerd Font | Шрифт с иконками |
| LXAppearance | Настройка GTK-темы и курсора |
| Thunar | Файловый менеджер |
| ~~Blueman~~ | ~~Bluetooth-апплет в трее~~ (Временно оставлен, управление через `blueman-manager` по клику на модуль в Polybar) |
| ~~Pasystray~~ | ~~Апплет звука в трее~~ (Заменён на `internal/pulseaudio` в Polybar) |
| ~~nm-applet~~ | ~~Апплет Wi-Fi в трее~~ (Заменён на `internal/network` в Polybar) |
| Syncthing | Синхронизация файлов (опционально) |

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
│   ├── rofi/
│   └── sxhkd/
├── home/                   # Симлинки в ~/* (скрипт сам ставит точку перед именем)
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
├── screenshots/            # Скриншоты для README
├── wallpapers/             # Обои
├── .gitignore
└── readme.md
```

## Установка на новую машину

### Шаг 1. Установить пакеты

```bash
sudo apt install -y \
  xorg xinit \
  bspwm sxhkd \
  polybar rofi dunst picom feh \
  lxappearance \
  papirus-icon-theme \
  fonts-jetbrains-mono fonts-font-awesome \
  fonts-noto-color-emoji \
  brightnessctl scrot \
  network-manager-gnome pavucontrol \
  blueman \
  thunar alacritty \
  i3lock-fancy libnotify-bin \
  fish
```

Опционально: `sudo apt install -y syncthing`

### Шаг 2. Установить шрифты Nerd Font

В репозиториях Debian пакета `fonts-jetbrains-mono-nerd` нет — шрифт ставится вручную:

1. Скачать `JetBrainsMono.zip` с https://www.nerdfonts.com/font-downloads
2. Установить `unzip`: `sudo apt install unzip`
3. Распаковать и положить `.ttf` в `~/.local/share/fonts/`:
   ```bash
   mkdir -p ~/.local/share/fonts
   cd ~/.local/share/fonts
   unzip ~/Загрузки/JetBrainsMono.zip
   fc-cache -fv
   ```
4. Проверить: `fc-list | grep -i "Nerd"`

### Шаг 3. Настроить эмодзи

После установки `fonts-noto-color-emoji` выполнить:
```bash
sudo dpkg-reconfigure fontconfig-config
```
В интерактивном меню разрешить растровые шрифты (bitmap fonts = Yes). Затем `fc-cache -fv`.

### Шаг 4. Клонировать репозиторий

```bash
git clone https://github.com/machineslego-wq/BSPWM-machineslego ~/bspwm-machineslego
cd ~/bspwm-machineslego
```

### Шаг 5. Запустить установку

В репозитории есть единый скрипт `install.sh`, который делает всё необходимое:
1. Создаёт симлинки из `config/` в `~/.config/`.
2. Создаёт симлинки из `home/` в `~/` (превращая `xinitrc` в `~/.xinitrc`).
3. Копирует системные конфиги из `system/` в `/etc/` (запрашивая пароль `sudo`).
4. Делает бэкап старых конфигов в `~/.dotfiles-backup-*` и `/etc/dotfiles-backup-*`.

Запуск:
```bash
chmod +x scripts/install.sh scripts/link.sh scripts/unlink.sh
./scripts/install.sh
```

Если вы не хотите менять системные файлы в `/etc`, запустите только линковщик пользовательских конфигов:
```bash
./scripts/link.sh
```

Откатить установку пользовательских симлинков (репозиторий и системные файлы не тронутся):
```bash
./scripts/unlink.sh
```

### Шаг 6. Запуск графической сессии

Убедитесь, что `~/.xinitrc` создан (это делает `install.sh`). Запустите X-сервер:
```bash
startx
```

## Настройка окружения

Скрипт `install.sh` автоматически применяет конфиги тачпада и NetworkManager. Если вы ставили систему вручную или запускали только `link.sh`, выполните следующие шаги:

### Wi-Fi через NetworkManager

Debian-установщик по умолчанию настраивает Wi-Fi через `ifupdown`, из-за чего NetworkManager не может управлять адаптером. Для передачи управления:

1. В `/etc/network/interfaces` закомментировать строки с Wi-Fi (это делает `install.sh`).
2. В `/etc/NetworkManager/NetworkManager.conf` установить `managed=true` (это делает `install.sh`).
3. Отключить системный `wpa_supplicant`, чтобы он не мешал NM:
   ```bash
   sudo systemctl stop wpa_supplicant
   sudo systemctl disable wpa_supplicant
   ```
   *Не используйте `mask`, иначе NetworkManager не сможет запустить свой экземпляр.*
4. Перезапустить: `sudo systemctl restart NetworkManager`
5. Подключиться: `nmcli device wifi connect "SSID" password "password"`

### Тачпад

Файл `/etc/X11/xorg.conf.d/30-touchpad.conf` копируется автоматически скриптом `install.sh`. Он включает тапы, естественную прокрутку и отключение во время набора текста.

### Курсор

Файл `~/.Xresources` создаётся автоматически (через симлинк на `home/Xresources`). Он задаёт `Xcursor.size: 48`. Команда `xrdb -merge ~/.Xresources` уже прописана в `~/.xinitrc`.

### Права на выключение

Меню питания и горячие клавиши используют `loginctl`, который не требует пароля в активной локальной сессии. Если `loginctl` по какой-то причине не работает, замените в скриптах `loginctl poweroff` на `systemctl poweroff`.

## Горячие клавиши

| Комбинация | Действие |
|---|---|
| Super + Enter | Терминал (Alacritty) |
| Super + D | Лаунчер Rofi |
| Super + Q | Закрыть окно |
| Super + W | Закрыть / убить процесс |
| Super + Стрелки | Фокус между окнами |
| Super + Shift + Стрелки | Поменять окна местами |
| Super + 1..7 | Переключить рабочий стол |
| Super + Shift + 1..7 | Переместить окно на другой стол |
| Super + T | Переключить режим окна (тайл / плавающий) |
| Super + F | Полный экран |
| Super + Tab | Переключение между двумя последними окнами |
| Super + L | Блокировка экрана (i3lock-fancy) |
| Super + Shift + L | Выйти из аккаунта |
| Super + Shift + P | Выключение (с подтверждением) |
| Super + Shift + R | Перезагрузка (с подтверждением) |
| Super + Escape | Перезагрузить конфиг SXHKD |
| Super + Alt + R | Перезапустить BSPWM |
| Super + Alt + Shift + R | Перезапустить SXHKD и BSPWM одновременно |
| Print | Скриншот всего экрана |
| Shift + Print | Скриншот активного окна |
| Super + Shift + S | Скриншот выделенной области |
| Super + Shift + N | Тест уведомления Dunst |
| XF86MonBrightnessUp / Down | Яркость |
| XF86AudioRaiseVolume / Lower | Громкость |
| XF86AudioMute | Мьют |

## Особенности конфигурации

- **Два режима панели:** В `config/polybar/config.ini` (секция `[bar/main]`) закомментированы два варианта. Активный сейчас — «парящая» панель (с отступами и скруглениями). Если раскомментировать блок «прибитая к верху», панель станет шириной 100% без рамок и отступов. В этом случае не забудьте поправить `top_padding` в `bspwmrc`.
- **Отступ под панель:** Задаётся через `bspc config top_padding` в `bspwmrc` и должен соответствовать высоте панели (сейчас 36px).
- **Скругления окон:** Обеспечивает Picom (`corner-radius = 8`). Тени и размытие отключены для слабого железа.
- **Уведомления:** Dunst рисует скругления сам (`corner_radius = 10`), Picom исключает класс `Dunst` через `rounded-corners-exclude`. Прозрачность задаётся параметром `transparency = 15`.
- **Меню питания:** Единый скрипт `powermenu.sh` вызывается и из Polybar, и по горячим клавишам. Показывает Rofi-окно с выбором «Да/Нет».
- **Индикация сети и звука:** В Polybar используются встроенные модули `internal/pulseaudio` и `internal/network`, которые не требуют фоновых апплетов.

## Перенос на 1920×1080

Для Full HD изменить:

**Polybar** (`config/polybar/config.ini`):
```ini
height = 36px
```
заменить на:
```ini
height = 44px
```

**BSPWM** (`config/bspwm/bspwmrc`):
```bash
bspc config top_padding 36
```
заменить на:
```bash
bspc config top_padding 44
```

**Зазоры между окнами:** при желании увеличить `bspc config window_gap` с `2` до `4–6`.

**Шрифт Polybar:** оставить `size=12` или увеличить до `13`.

**Обои:** подобрать картинку под 1920×1080 из папки `wallpapers/`.

## Известные ограничения

- На Celeron N4120 с 4 ГБ ОЗУ не рекомендуется включать эффекты размытия в Picom и тяжёлые модули в Polybar (CPU, memory, graph).
- Шрифты Nerd Font ставятся вручную — в репозиториях Debian их нет.
- Если `echo -e` в скриптах не работает — заменить на `printf`. Polybar и SXHKD запускают команды через `/bin/sh` (dash), который не поддерживает `-e` у встроенного `echo`.
- В `.ini`-конфиге Polybar inline-комментарии (`;` после значения) не поддерживаются — парсер берёт всё после `=` как буквальное значение.
- `internal/pulseaudio` в Polybar 3.7.2 не поддерживает format-теги `%{T1}` внутри `ramp-volume-*` и `label-*`. Размер только иконок громкости без изменения текста изменить нельзя.

## Скриншот

![Screenshot](screenshots/screenshot.png)
![2026-10-16_21-32-07.png](screenshots/2026-10-16_21-32-07.png)
![2026-10-16_22-27-15.png](screenshots/2026-10-16_22-27-15.png)

## Лицензия

Конфигурация свободна к использованию и модификации.