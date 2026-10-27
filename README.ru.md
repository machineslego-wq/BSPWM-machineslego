# BSPWM-machineslego

[English](./README.md) | **Русский**

![Debian](https://img.shields.io/badge/Debian-13%20Trixie-A81D33?logo=debian&logoColor=white)
![X11](https://img.shields.io/badge/X11-only-blue)
![PipeWire](https://img.shields.io/badge/PipeWire-Audio-blue?logo=pipewire&logoColor=white)
![BSPWM](https://img.shields.io/badge/WM-BSPWM-black)
![License](https://img.shields.io/badge/License-MIT-green)

Конфигурация рабочего окружения на базе BSPWM для Debian 13 Trixie в палитре Tokyo Night.

![Рабочий стол](screenshots/desktop.png)
![Рабочее пространство](screenshots/workspace+notify.png)

<details>
<summary><b>Показать больше скриншотов (Rofi, Polybar, Питание, Wi-Fi, Шпаргалка)</b></summary>
<br>

**Rofi**
![Rofi](screenshots/rofi-showcase.png)
![Пример Alt+X](screenshots/alt+x-example.png)

**Polybar (правая часть, все модули включены)**
![Правая часть Polybar со всеми включёнными модулями](screenshots/polybar-right-expanded.png)

**Профили питания**
![Профили питания](screenshots/power-profiles.png)

**Wi-Fi**
![Менеджер Wi-Fi](screenshots/wifi-manager.png)
![Меню Wi-Fi](screenshots/wifi-manager-menu.png)

**Шпаргалка**
![Шпаргалка](screenshots/cheatsheet.png)

</details>

## Особенности

- **Native Modules First:** Стоковые модули Polybar для батареи, сети и звука.
- **Плавность и плоский дизайн:** Никакого блюра, строгие цвета Tokyo Night и аккуратные анимации окон в стиле Hyprland (Picom).
- **Единое меню питания:** Кнопка питания в панели и хоткей открывают меню Rofi (мгновенное выполнение без лишних подтверждений).
- **Умный OSD громкости:** Уведомление меняет цвет рамки и полоски в зависимости от уровня (Синий < 50%, Желтый > 50%, Красный > 80%, Ярко-алый > 100%).
- **Собственный Wi-Fi менеджер:** Легковесный скрипт `wifi.sh` (на Rofi и `nmcli`) для подключения к сетям, включения адаптера, создания хотспота и подключения к **скрытым сетям** (запрашивает SSID, использует `hidden yes`). **Требует ручной настройки интерфейса.**
- **Эргономичные хоткеи:** Быстрый запуск приложений (`Super+B` для Firefox, `Super+V` для VS Code, `Super+Alt+T` для Telegram), поиск окон (`Alt+Tab`) и удобные скриншоты для ноутбуков (`Super+F1`/`F2`/`F3`).
- **Vim-keys для плавающих окон:** `Super+H/J/K/L` двигает плавающие окна (H=влево, J=вниз, K=вверх, L=вправо). С `xset r rate 250 30` они двигаются плавно при удержании — тот же приём работает для громкости и яркости.
- **Анимированные уведомления (Dunst):** Уведомления выезжают сверху с fade и уезжают вверх при закрытии. Стек уведомлений плавно сдвигается при появлении новых. **Известное ограничение:** второе и последующие уведомления в стеке появляются без анимации из-за конфликта Picom 12.5 с логикой позиционирования Dunst.
- **Перезапуск одной кнопкой:** `Super+Alt+Shift+R` мгновенно перезапускает SXHKD, BSPWM, Polybar, Dunst и Picom.
- **История буфера (CopyQ):** Нажмите `Super+Ctrl+V`, чтобы открыть всплывающее меню с историей буфера. CopyQ запускается автоматически из `bspwmrc`.
- **Автоблокировка (xss-lock):** Экран блокируется автоматически через 10 минут бездействия и перед уходом в сон, используя тот же `i3lock-fancy -p`, что и `Super+Alt+L`. **Второго экрана блокировки нет.**
- **Сон при закрытии крышки:** Закрытие крышки ноутбука отправляет систему в сон (ядро гасит панель), а `xss-lock --transfer-sleep-lock` блокирует экран перед сном — после пробуждения видно `i3lock-fancy`, второго экрана блокировки нет.
- **Polkit-агент (lxpolkit):** Графические запросы пароля для `gparted`, `synaptic` и обновлений системы — без терминала.
- **Унифицированное питание (PPD):** power-profiles-daemon — единственный провайдер, и на ноутбуках, и на ПК. TLP удаляется автоматически в `install.sh` во избежание конфликтов.
- **Продвинутая поддержка мониторов:** Настраиваемый блок в `bspwmrc` для ПК с двумя экранами: 144 Гц, смещение, портретный режим и разные обои.
- **История уведомлений (Rofi):** `Super+Alt+H` открывает Rofi-меню с последними 20 уведомлениями из `dunstctl history`. При выборе тело уведомления копируется в буфер обмена.

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
│   │       ├── brightness.sh       # Скрипт яркости
│   │       └── power-profile.sh    # Профиль питания через PPD
│   └── sxhkd/
│       ├── sxhkdrc         # Горячие клавиши
│       └── scripts/        # cheatsheet, notify-history, powermenu, volume, wifi
├── home/                   # Симлинки в ~/*
├── system/                 # Копируется в /etc
├── scripts/                # install.sh, link.sh, unlink.sh
├── TODO.md                 # Планы (темы, прозрачность)
├── screenshots/
└── wallpapers/
```

> Примечание: `copyq`, `xss-lock` и `lxpolkit` устанавливаются как пакеты Debian и настраиваются через `bspwmrc` — в репозиторий они не входят.

## 📋 Требования

- **ОС:** Debian 13 Trixie (или совместимый дистрибутив).
- **Базовые утилиты:** `git`, `sudo`, интернет.
- **Nerd Font** (устанавливается автоматически).
- **Права sudo** для установки пакетов и копирования файлов в `/etc`.
- **Аудио-бэкенд:** Конфигурация оптимизирована под **PipeWire**. Скрипт `volume.sh` использует `wpctl` и работает только с PipeWire. Если вы используете чистый PulseAudio, скрипт не будет работать. Установщик автоматически добавляет `pipewire-pulse` для совместимости с модулем PulseAudio в Polybar.

## 🛠 Установка

**Способ 1: Через Git (Рекомендуемый)**
```bash
git clone https://github.com/machineslego-wq/BSPWM-machineslego ~/BSPWM-machineslego
cd ~/BSPWM-machineslego
chmod +x scripts/*.sh
./scripts/install.sh
```

**Способ 2: Через ZIP-архив**
GitHub распакует архив в папку `BSPWM-machineslego-X.X.X`. 
⚠️ **Важно:** Переименуйте папку в `BSPWM-machineslego` и переместите в `~/`.
```bash
mv ~/Downloads/BSPWM-machineslego* ~/BSPWM-machineslego
cd ~/BSPWM-machineslego
chmod +x scripts/*.sh
./scripts/install.sh
```

**Если не нужно трогать `/etc`:** используйте `./scripts/link.sh`.
**Откат:** `./scripts/unlink.sh`.
**Запуск:** `startx` (или через LightDM).

### ⚙️ Кастомизация

**Настройка мониторов (ПК)**
Настройте их в `~/.config/bspwm/bspwmrc`. Найдите блок `--- НАСТРОЙКА МОНИТОРОВ ---`.
1. Замените `"lamer-deb"` на ваш `hostname`.
2. Настройте `xrandr` (порты, `--rate 144.00`, поворот, позицию).
3. Установите разные обои через `feh --output`.

**Wi-Fi и Хотспот (Требуется ручная настройка)**
Скрипт `wifi.sh` предварительно настроен под мои устройства (например, `wlo1`, `wlp3s0`). **Вы должны вручную добавить имя интерфейса вашего устройства** в блок `if/elif`. 
Узнать имя можно командой `ip a` или `nmcli device`. На некоторых машинах это `wlan0`, а на других (например, ПК с PCIe-картой) это может быть `wlp7s0`.
Также не забудьте задать свой `HOTSPOT_SSID` и `HOTSPOT_PASSWORD` в начале `~/.config/sxhkd/scripts/wifi.sh`.

**Таймаут автоблокировки (xss-lock)**
В `~/.config/bspwm/bspwmrc` найдите блок `--- АВТОБЛОКИРОВКА (xss-lock) ---`. По умолчанию 10 минут:
```bash
xset s 600 600                    # 600 сек = 10 минут
xset +dpms dpms 600 600 600       # гасить монитор одновременно
```
Чтобы изменить таймаут — поменяйте все значения `600` (например, `300 300` для 5 минут).

**Поведение крышки (ноутбук)**
По умолчанию закрытие крышки **отправляет систему в сон**. `install.sh` создаёт `/etc/systemd/logind.conf.d/10-lid-suspend.conf`:
```bash
[Login]
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=suspend
HandleLidSwitchDocked=ignore
```
Чтобы **блокировать без сна**:
```bash
sudo rm /etc/systemd/logind.conf.d/10-lid-suspend.conf
sudo tee /etc/systemd/logind.conf.d/10-lid-lock.conf > /dev/null <<'EOF'
[Login]
HandleLidSwitch=lock
HandleLidSwitchExternalPower=lock
EOF
sudo systemctl kill -s HUP systemd-logind
```
> ⚠️ На некоторых AMD-ноутбуках «lock» не выключает подсветку — экран продолжает светиться под `i3lock-fancy`. Именно поэтому по умолчанию используется «suspend».

## 🖼️ Обои и тема

Затемнение обоев под палитру Tokyo Night через ImageMagick:
```bash
convert /path/to/original.jpg -fill "#1a1b26" -colorize 50% -modulate 80,80,100 /path/to/tokyo-night-wallpaper.jpg
```

## ⌨️ Горячие клавиши

**Полная шпаргалка:** `Super + /` (Rofi, поиск по скрытым тегам).

| Комбинация | Действие |
|---|---|
| `Super + Return` | Терминал (Alacritty) |
| `Super + Ctrl + V` | История буфера (CopyQ) |
| `Super + /` | Шпаргалка (Rofi) |
| `Super + D` | Лаунчер (Rofi drun) |
| `Super + B` | Браузер (Firefox) |
| `Super + V` | Редактор (VS Code) |
| `Super + E` | Файловый менеджер (Thunar) |
| `Super + Alt + T` | Telegram + Proxy |
| `Super + Alt + H` | История уведомлений (Rofi) |
| `Alt + Tab` | Поиск по открытым окнам (Rofi) |
| `Super + W` | Закрыть окно |
| `Super + 1…0` | Переключение рабочих столов |
| `Super + Shift + 1…0` | Переместить окно на рабочий стол |
| `Super + Shift + Q` | Меню питания (Rofi) |
| `Super + Alt + L` | Блокировка экрана (i3lock-fancy) |
| `Super + F1` | Скриншот всего экрана |
| `Super + F2` | Скриншот активного окна |
| `Super + Shift + S` | Скриншот области |
| `Super + F3` | Скриншот с задержкой 3с |
| `Super + Alt + N` | Wi-Fi менеджер |
| `Super + Alt + P` | Меню профиля питания |
| `Super + Alt + Shift + R` | Перезапуск всей системы |
| `Super + Стрелки` | Фокус на окно |
| `Super + Shift + Стрелки` | Свап тайловых окон |
| `Super + H/J/K/L` | Двигать плавающее окно (Vim-style) |
| `Super + Alt + Стрелки` | Растянуть размер |
| `Super + Alt + Shift + Стрелки` | Сжать размер |

## 🎨 Экосистема

Если вы хотите, чтобы ваши заметки в Obsidian выглядели так же строго, обратите внимание на тему:

**[Tokyo Night Flat Theme для Obsidian](https://github.com/machineslego-wq/tokyo-night-by-machineslego-wq)**

## 🔧 Устранение неполадок

- **Скрипт Wi-Fi не работает / Ошибка в `wifi.sh`** → В скрипте жестко прописаны имена интерфейсов для моих устройств. Вам нужно открыть `~/.config/sxhkd/scripts/wifi.sh` и вручную добавить имя вашего интерфейса в блок `if/elif`. Запустите `ip a`, чтобы узнать его (например, `wlan0`, `wlo1`, `wlp7s0`).
- **Нет иконок в Polybar/Rofi** → Не установлен Nerd Font. Проверьте: `fc-list | grep -i "nerd"`.
- **`startx` не запускается** → Проверьте `exec bspwm` в `~/.xinitrc`.
- **Не работают горячие клавиши** → Перезапустите `sxhkd`: `pkill -USR1 -x sxhkd`.
- **Нет модуля яркости на ПК** → Это намеренно. На ПК используйте кнопки монитора.
- **Polybar не стартует** → Проверьте симлинк `~/.config/polybar` и права на `launch.sh`.
- **Экран не блокируется после бездействия** → Проверьте `pgrep -a xss-lock`. Если пусто — перезапустите BSPWM (`Super+Alt+Shift+R`). Проверьте таймеры: `xset q | grep -A 2 "Screen Saver"`.
- **Крышка блокирует вместо сна** → Удалите `/etc/systemd/logind.conf.d/10-lid-lock.conf`, если он есть, затем `sudo systemctl kill -s HUP systemd-logind`.
- **Крышка не усыпляет систему (или выключает её)** → На AMD Ryzen 7000-й серии ядро может уходить в `s2idle` или нестабильно работать с S3. Принудительно включите `s2idle`, добавив `mem_sleep_default=s2idle` в `GRUB_CMDLINE_LINUX_DEFAULT` в `/etc/default/grub`, затем `sudo update-grub` и перезагрузка. Проверить текущий режим: `cat /sys/power/mem_sleep`.
- **`Super+Ctrl+V` не открывает CopyQ** → Проверьте, что CopyQ запущен: `pgrep -a copyq`. Если нет — запустите `copyq --start-server &`. Проверьте автозапуск в `bspwmrc`.
- **Не появляется диалог пароля Polkit** → Проверьте `pgrep -a lxpolkit`. Перезапустите BSPWM при необходимости.
- **`Super+L` двигает окно, а не блокирует** → Это намеренно. Блокировка переехала на `Super+Alt+L` в v1.3.0, а `Super+L` теперь vim-right для плавающих окон.
- **TLP удалился после обновления** → Намеренно. PPD — единственный провайдер питания. Если нужен TLP обратно — ставьте вручную, но конфликты с PPD вернутся.

## 📄 Лицензия

- Конфигурации и скрипты — **MIT**.
- Шрифты (JetBrains Mono Nerd Font) — **SIL Open Font License 1.1**.