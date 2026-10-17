# BSPWM-machineslego

Конфигурация рабочего окружения на базе BSPWM для Debian 13 Trixie с оформлением в палитре Tokyo Night.

## TODO

- Добавить Rofi-скрипты для управления Bluetooth и Wi-Fi (полная замена `blueman-applet`).

## Последние изменения

- **Гибридное управление питанием:** Добавлен модуль в Polybar для переключения профилей. Установщик автоматически определяет тип устройства (ноутбук или ПК) и настраивает TLP или `cpupower` соответственно, включая настройку `sudoers` для работы без пароля.
- **Умный установщик:** `install.sh` теперь полностью автоматизирует процесс: устанавливает пакеты, настраивает `sudoers`, создаёт симлинки и копирует системные конфиги.
- **Глобальная смена структуры:** Репозиторий переведён на разделение по папкам `config/`, `home/`, `system/` и `scripts/`.
- Апплеты `nm-applet` и `pasystray` более не участвуют в Polybar, они заменены на встроенные модули (`internal/network` и `internal/pulseaudio`).
- Переписан скрипт яркости: теперь в `brightness.sh` можно выбрать стиль отображения (иконка, полоса или всё вместе).
- В конфиге Polybar добавлена возможность переключения между «парящей» панелью и панелью, прибитой к верхнему краю.

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
| Fastfetch | Информация о системе |
| LXAppearance | Настройка GTK-темы и курсора |
| Thunar | Файловый менеджер |
| TLP / cpupower | Управление питанием (ноутбук / ПК) |
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
│   │       ├── power-profile-laptop.sh
│   │       ├── power-profile-pc.sh
│   │       └── ...
│   ├── rofi/
│   └── sxhkd/
├── home/                   # Симлинки в ~/* (скрипт сам ставит точку)
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

Установка полностью автоматизирована скриптом `install.sh`.

### Шаг 1. Клонировать репозиторий

```bash
git clone https://github.com/machineslego-wq/BSPWM-machineslego ~/BSPWM-machineslego
cd ~/BSPWM-machineslego
```

### Шаг 2. Установить шрифты Nerd Font

В репозиториях Debian нужного шрифта нет, поэтому ставим вручную:
1. Скачать `JetBrainsMono.zip` с [nerdfonts.com](https://www.nerdfonts.com/font-downloads).
2. Установить `unzip`: `sudo apt install unzip`.
3. Распаковать в `~/.local/share/fonts/`:
   ```bash
   mkdir -p ~/.local/share/fonts
   unzip ~/Загрузки/JetBrainsMono.zip -d ~/.local/share/fonts/
   fc-cache -fv
   ```

### Шаг 3. Запустить установщик

Скрипт сам установит все нужные пакеты, настроит `sudoers` (для работы профилей питания без пароля), создаст симлинки и скопирует системные конфиги (тачпад, Wi-Fi) в `/etc`.

```bash
chmod +x scripts/*.sh
./scripts/install.sh
```
В процессе установки скрипт спросит:
1. **Установить для ноутбука (TLP) или для ПК (cpupower)?** — выбери нужный вариант.
2. Запросит пароль `sudo` для установки пакетов и изменения системных файлов.

*Если вы не хотите менять системные файлы в `/etc`, запустите только линковщик: `./scripts/link.sh`.*

### Шаг 4. Запуск графической сессии

Убедитесь, что `~/.xinitrc` создан (это делает `install.sh`). Запустите X-сервер:
```bash
startx
```

*Откатить установку пользовательских симлинков (без удаления пакетов): `./scripts/unlink.sh`*

## Настройка окружения

`install.sh` автоматически применяет конфиги тачпада и NetworkManager. Если вы запускали только `link.sh`, выполните следующие шаги вручную:

### Wi-Fi через NetworkManager

1. В `/etc/network/interfaces` закомментировать строки с Wi-Fi.
2. В `/etc/NetworkManager/NetworkManager.conf` установить `managed=true`.
3. Отключить системный `wpa_supplicant`:
   ```bash
   sudo systemctl stop wpa_supplicant
   sudo systemctl disable wpa_supplicant
   ```
4. Перезапустить: `sudo systemctl restart NetworkManager`
5. Подключиться: `nmcli device wifi connect "SSID" password "password"`

### Управление питанием

В панели Polybar есть модуль `power-profile`, который определяет тип устройства и управляет питанием:
- **На ноутбуках (TLP)**: Показывает режим `AC` или `BAT` (`A` — авто, `M` — ручной). Клик открывает меню с выбором: Авто, От сети, От батареи.
- **На ПК (cpupower)**: Показывает текущий governor (`PERF`, `BAL`, `SAVE`). Клик открывает меню с выбором Performance, Balanced, Powersave.

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

- **Два режима панели:** В `config/polybar/config.ini` закомментированы два варианта. Активный — «парящая» панель (с отступами и скруглениями). Альтернативный — «прибитая к верху» (100% ширины, без рамок).
- **Отступ под панель:** Задаётся через `bspc config top_padding` в `bspwmrc` и должен соответствовать высоте панели (сейчас 36px).
- **Скругления окон:** Обеспечивает Picom (`corner-radius = 8`). Тени и размытие отключены для слабого железа.
- **Уведомления:** Dunst рисует скругления сам (`corner_radius = 10`), Picom исключает класс `Dunst` через `rounded-corners-exclude`. Прозрачность задаётся параметром `transparency = 15`.
- **Меню питания:** Единый скрипт `powermenu.sh` вызывается и из Polybar, и по горячим клавишам. Показывает Rofi-окно с выбором «Да/Нет».

## Перенос на 1920×1080

**Polybar** (`config/polybar/config.ini`):
```ini
height = 36px # заменить на 44px
```

**BSPWM** (`config/bspwm/bspwmrc`):
```bash
bspc config top_padding 36 # заменить на 44
```

**Зазоры:** увеличить `bspc config window_gap` с `2` до `4–6`.
**Шрифт Polybar:** увеличить `size=12` до `13`.

## Известные ограничения

- На Celeron N4120 с 4 ГБ ОЗУ не рекомендуется включать эффекты размытия в Picom и тяжёлые модули в Polybar.
- Шрифты Nerd Font ставятся вручную.
- Polybar и SXHKD запускают команды через `/bin/sh` (dash). Флаг `echo -e` не работает, используйте `printf`.
- В `.ini`-конфиге Polybar inline-комментарии (`;` после значения) не поддерживаются.
- `internal/pulseaudio` в Polybar 3.7.2 не поддерживает format-теги `%{T1}` (размер только иконок громкости изменить нельзя).

## Скриншот

![Screenshot](screenshots/screenshot.png)
![2026-10-17_17-56-38.png](screenshots/2026-10-17_17-56-38.png)
![2026-10-16_22-27-15.png](screenshots/2026-10-17_17-56-43.png)

## Лицензия

Конфигурация свободна к использованию и модификации.