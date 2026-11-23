# Устройства

Внутренний справочник (как `AGENTS.md`, не для README): три основные машины,
их экраны, ОС и то, какая ветка конфигов за что отвечает. Нужен, чтобы при
правке конфигов не переспрашивать владельца.

Подробности по ПК — в заметках `Характеристики ПК.md` (сборка и цены) и
`Планы по переустановке ОС и реорганизации рабочего процесса.md` (разметка
дисков). Обе лежат в корне и в git не входят.

## Контекст (если файл читает ИИ)

Это самодостаточный справочник по трём машинам для дотфайлов
**BSPWM-machineslego**: Debian 13, BSPWM/X11 — рабочая и запасная сессия,
Sway/Wayland — направление переезда, тема Tokyo Night. Конфиги лежат в
`config/`, команды — в `local/bin/`, установщик — в `scripts/`; полная карта
репозитория и правила — в `AGENTS.md`. Для понимания железа, мониторов и
веток по hostname достаточно этого файла — его можно дать ИИ в новом чате.

## Сводка

| Устройство | Hostname | Модель | Роль | ОС | Экраны |
|---|---|---|---|---|---|
| ПК | `lamer-deb` | самосбор (i5-11600K, RX 7700 XT) | основная машина | Debian 13 GNOME (план — KDE) + Windows 11 Pro | 2: KTC AF24H1 (DP, 1920×1080@144) + ViewSonic VA2445 (HDMI, 1920×1080, повёрнут) |
| Ноутбук | `lx15pro-deb` | NIPOGI LX15 Pro (Ryzen 5 7430U) | мобильная работа | Debian 13 GNOME + backports; Windows 11 | 1: 15.6" IPS, 1920×1080 |
| Нетбук | не зафиксирован (`hostname` на месте) | Acer TravelMate B3, по признакам TMB311-31 | первая rice-машина, запасная | Debian 13 + backports (ставился без DE) | 1: 11.6" TN, 1366×768 |

Пользователь на всех трёх — `nikita`, домашний каталог `/home/nikita`.
Правило: всё, что специфично для ПК, живёт в ветке `lamer-deb`; остальные
хосты попадают в ветку по умолчанию (один экран, все столы на нём).

## Общее по всем машинам

- **Debian 13 везде.** Windows 11 — только на ПК и ноутбуке.
- **Backports:** включены на ноутбуке (`lx15pro-deb`) и нетбуке (TravelMate).
  На ПК (`lamer-deb`) их нет: там Docker и требование железобетонной
  стабильности, новые пакеты не нужны.
- **История rice:** началось с нетбука — чистый Debian без оболочки, поверх
  поставлен BSPWM/Sway и эти дотфайлы. Потом ноутбук с GNOME + rice, потом ПК
  с GNOME (планируется переход на KDE Plasma). Поэтому конфиги рассчитаны на
  самостоятельный WM, а не на интеграцию с конкретным DE.
- **Пользователь и пути одинаковые** на всех машинах, поэтому `~` и
  `/home/nikita` в конфигах переносимы; различаются только hostname,
  мониторы и набор пакетов.

## ПК — `lamer-deb`

### Железо

| Компонент | Модель |
|---|---|
| CPU | Intel Core i5-11600K (6C/12T, 3.9–4.9 ГГц, LGA1200, 125 Вт, UHD 750) |
| Плата | MSI MAG B560M Mortar Wi-Fi (mATX, 2×M.2, Wi-Fi 6, BT 5.2) |
| RAM | Adata XPG Spectrix D50 ARGB, 32 ГБ (2×16), DDR4-3600 CL18 |
| GPU | Sapphire Pulse RX 7700 XT 12 ГБ (2×HDMI, 2×DP, ~245 Вт) |
| SSD Windows | Samsung 980 1 ТБ, NVMe PCIe 3.0 ×4 |
| SSD Debian | Samsung 980 500 ГБ, NVMe PCIe 3.0 ×4 |
| HDD | 2× WD Blue 1 ТБ, 7200 об/мин, SATA (NTFS, файлы) |
| Кулер / корпус / БП | Thermalright Peerless Assassin 140 / Cougar Airface Eco ARGB / Deepcool PQ750M |

### Мониторы

| Монитор | Идентификатор EDID (Sway) | X11 (xrandr) | Sway (wlroots) | Геометрия | Роль |
|---|---|---|---|---|---|
| KTC AF24H1 | `Shenzhen KTC Technology Group AF24H1 000000000000` | `DisplayPort-1` | `DP-2` | 1920×1080@144, позиция `1080 250` | основной, справа |
| ViewSonic VA2445 SERIES | `ViewSonic Corporation VA2445 SERIES TSQ163341039` | `HDMI-A-3` | `HDMI-A-4` | 1920×1080, `transform 90`, позиция `0 0` | слева, вертикально (1080×1920) |

- Общий фреймбуфер 3000×1920; HDMI-монитор занимает 1080 px по X.
- У KTC серийник в EDID нулевой (`000000000000`) — идентификатор не уникален,
  для привязки столов надёжнее имя выхода (`DP-2`), а не EDID.
- Имена в X11 и Sway не совпадают: `DisplayPort-1` ≠ `DP-2`,
  `HDMI-A-3` ≠ `HDMI-A-4`. Не копировать между сессиями.
- Обои: landscape на `DP-2`, portrait на `HDMI-A-4`.

### Раскладка мониторов и отступы

Координаты одинаковы в Sway и X11: начало `(0,0)` — левый верхний угол,
X растёт вправо, Y — вниз. `position` / `--pos` задаёт левый верхний угол
монитора. Значения взяты из `local/bin/sway-display` и
`config/bspwm/bspwmrc`.

| Монитор | Размер на столе | Левый верхний угол | Правый нижний угол | Как стоит |
|---|---|---|---|---|
| ViewSonic VA2445 (`HDMI-A-4` / `HDMI-A-3`) | 1080×1920 (физически 1920×1080, `transform 90`) | `0 0` | `1080 1920` | слева, во всю высоту, вертикально |
| KTC AF24H1 (`DP-2` / `DisplayPort-1`) | 1920×1080 | `1080 250` | `3000 1330` | справа, сдвинут вниз на 250 px |

- Общая область — 3000×1920: 1080 (HDMI) + 1920 (DP) по X, 1920 по Y.
- DP сдвинут от верхнего края на 250 px; ниже него остаётся пустая область
  высотой 590 px (1920 − 1330). То есть он стоит ближе к верху, а не по
  центру: 250 px сверху против 590 px снизу.
- Пустая область (1920×590) — мёртвая зона рабочего стола: окна туда не
  попадают.

```text
x=0            x=1080                      x=3000
y=0     ┌──────────┐
        │          │
y=250   │          │┌──────────────────────────┐
        │          ││  KTC AF24H1 (DP-2)       │
        │ HDMI-A-4 ││  1920×1080, 144 Гц       │
        │ 1080×1920││                          │
        │ (поворот ││                          │
        │  90°)    ││                          │
        │          │└──────────────────────────┘ y=1330
        │          │
        │          │  пусто 1920×590
        │          │
y=1920  └──────────┘
```

Точные команды:

```bash
# Sway (local/bin/sway-display)
swaymsg 'output DP-2 mode 1920x1080@144Hz position 1080 250'
swaymsg 'output HDMI-A-4 transform 90 position 0 0'

# X11 (config/bspwm/bspwmrc)
xrandr --fb 3000x1920 \
       --output HDMI-A-3 --auto --rotate right --pos 0x0 \
       --output DisplayPort-1 --primary --mode 1920x1080 --rate 144.00 --pos 1080x250
```

В Sway координаты позиции пишутся через пробел (`1080 250`), в X11 —
через `x` (`1080x250`). Схема выше схематичная, не в масштабе: важны
координаты и взаимное расположение.

### Столы

- BSPWM: `I–IX` на `DisplayPort-1`, `X` на `HDMI-A-3` (`config/bspwm/bspwmrc`).
- Sway: 1–7 → `DP-2`, 8–10 → `HDMI-A-4`; карта генерируется в
  `~/.cache/sway/workspaces.conf` из `local/bin/sway-session`.
- Стартовый фокус — стол 1 (`exec swaymsg workspace number 1` в конфиге Sway).

### Диски и ОС

- **Debian 13 GNOME** — Samsung 980 500 ГБ: `/boot/efi` 1 ГБ, `/boot` 1 ГБ,
  swap 8 ГБ, LVM: `/var` 100 ГБ, `/` 50 ГБ, `/home` 266 ГБ, неразмеченные 40 ГБ.
  Текущий DE — GNOME, планируется переезд на KDE Plasma. Backports не
  подключены: Docker и ставка на стабильность.
- **Windows 11 Pro** — Samsung 980 1 ТБ: `C:` ~180 ГБ, `S:` ~510 ГБ (софт/игры),
  `F:` ~200 ГБ (пользовательские файлы), ~41 ГБ over-provisioning.
- HDD — только данные NTFS; на Linux в основном чтение/сортировка.

## Ноутбук — NIPOGI LX15 Pro

Один и тот же аппарат (OEM — CYX, Shenzhen Chuangyingxin) продаётся под
брендами **NIPOGI** (этот экземпляр), **ACEMAGIC LX 15 Pro** и CYX LX 15 Pro.
Официальная страница модели — у ACEMAGIC:
<https://acemagic.com/products/acemagic-lx15-pro-laptop>. Параметры ниже —
с OEM-страницы, ACEMAGIC/AMD; фактическая конфигурация — со слов владельца.

### Характеристики

| Параметр | Значение |
|---|---|
| CPU | AMD Ryzen 5 7430U: Zen 3 (Barcelo-R), 6C/12T, 2.3–4.3 ГГц, L3 16 МБ, 7 нм, 15 Вт |
| iGPU | Radeon RX Vega 7 (встроенная, без дискретной) |
| RAM | 16+4 ГБ (фактическая конфигурация); OEM: 2× SO-DIMM DDR4, до 64 ГБ |
| SSD | 240 ГБ NVMe (Debian 13) + 512 ГБ NVMe (Windows 11) |
| Слоты | OEM: M.2 2280 NVMe ×1 + M.2 2280 NVMe/NGFF (SATA) ×1 |
| Экран | 15.6" IPS, 1920×1080, 16:9, ~280 нит, eDP |
| Корпус | 362×251.4×18.5 мм, ~1.65 кг, PC+ABS, петля 180° |
| Клавиатура | полная, без подсветки |
| Батарея | 11.4 В / 4800 мА·ч, 54.72 Вт·ч; БП 19 В / 2.1 А (~40 Вт), DC 3.5×1.35 мм |
| Сеть | Wi-Fi 6, Bluetooth 5.2 |
| Камера | 1 Мп 1280×800, два DMIC, физическая шторка |
| Порты | 3× USB-A 3.0 (5 Гбит/с), 2× USB-C (один full-function: данные/DP/зарядка), HDMI (OEM: 2.0 до 4K60; в листингах встречается 1.4), TF-картридер, 3.5 мм combo, DC |

> Варианты LX 15 Pro отличаются: часть листингов пишет распаянную LPDDR4,
> часть — два SO-DIMM. У этого экземпляра смотреть `sudo dmidecode -t memory`
> и `sudo dmidecode -t baseboard`, а не верить листингу.

### Конфигурация и место в конфигах

- Hostname `lx15pro-deb`. Один встроенный экран; внешнего монитора сейчас нет.
  В Sway имя внутреннего выхода почти наверняка `eDP-1` (AMD), проверить
  `swaymsg -t get_outputs`.
- Поэтому в `sway-session` для него пустая карта столов, а в `sway-display` —
  ветка по умолчанию (`output * bg`), без геометрии ПК.
- Debian 13 GNOME + rice, включены backports. Windows 11 — на 512 ГБ NVMe.
- Диски: Debian 13 на 240 ГБ NVMe, Windows 11 на 512 ГБ NVMe; оба M.2 заняты.
- Потенциал для второго экрана: HDMI + full-function USB-C (DP Alt Mode).
  Если появится внешний монитор — добавить ветку по hostname в `sway-session`
  (карта) и `sway-display` (геометрия/обои), имена выходов взять с устройства.
- Запас по RAM: вторая планка 4 ГБ; при апгрейде — DDR4-3200 SO-DIMM,
  до 64 ГБ (две планки).

## Нетбук — Acer TravelMate B3 (Celeron N4120)

Модель по признакам — TravelMate B3 (TMB311-31 / B311-31): 11.6", N4120,
4 ГБ, 64 ГБ eMMC. Точную модель смотреть `sudo dmidecode -t system` на месте.

| Параметр | Значение |
|---|---|
| Hostname | не зафиксирован — `hostname` на месте |
| Модель | Acer TravelMate B3 (по признакам TMB311-31 / B311-31) |
| CPU | Intel Celeron N4120: Gemini Lake Refresh, 4C/4T, 1.1–2.6 ГГц, кэш 4 МБ, 14 нм, 6 Вт, BGA1090 |
| iGPU | Intel UHD Graphics 600 |
| RAM | 4 ГБ DDR4-2400 (1×4 ГБ; платформа поддерживает до 8 ГБ) |
| Экран | 11.6" TN, 1366×768, 60 Гц |
| Накопители | 64 ГБ eMMC + добавленный SATA SSD 120 ГБ |
| Сеть | Wi-Fi 5, Gigabit Ethernet |
| Корпус | ~1.4 кг, петля 180° |
| ОС | Debian 13 + backports; ставился без DE, rice на чистой основе |

- Один экран и слабый CPU/GPU: тяжёлые эффекты и композиторы не для него.
  Текущие настройки (pixel-бордюры, без gaps, без прозрачности, `em`-размеры
  в rofi/wofi) подходят; 1366×768 не хардкодить в конфигах.
- Судя по README/TODO (Polybar и ограничение PPD `performance` на Celeron),
  основная сессия здесь — BSPWM/X11; Sway-конфиги общие. Проверить
  `echo $XDG_SESSION_TYPE` на месте.
- Ветки те же, что у ноутбука: пустая карта столов, `output * bg`,
  все столы на одном экране.
- Внутренний выход может называться `eDP-1` или `LVDS-1` — смотреть на месте.
- Это первая машина, на которой появился rice: чистый Debian без оболочки,
  затем BSPWM/Sway и эти дотфайлы.

## Что где ветвится

| Что | ПК (`lamer-deb`) | Ноутбук (`lx15pro-deb`) / нетбук (TravelMate) |
|---|---|---|
| Hostname / ветка | отдельная ветка `lamer-deb` | общая ветка по умолчанию |
| `config/bspwm/bspwmrc` | `xrandr`: `DisplayPort-1` + повёрнутый `HDMI-A-3`; столы I–IX / X | else: 10 столов на одном мониторе, landscape-обои |
| `local/bin/sway-session` | карта 1–7 → `DP-2`, 8–10 → `HDMI-A-4` | пустой `~/.cache/sway/workspaces.conf` |
| `local/bin/sway-display` | режим 144 Гц, поворот и позиции, два фона | `output * bg` на каждый выход |
| `config/sway/config` | общий, hostname-условий нет; `exec swaymsg workspace number 1` | то же |
| Backports | выключены (Docker, стабильность) | включены |
| Размеры меню | `em` в `config/rofi`, px только в wofi для Sway | те же; при 1366×768 проверить, что меню влезает |

## Если данных не хватает — снять с устройства, не спрашивать

```bash
hostname
cat /etc/os-release
sudo dmidecode -t system | grep -E 'Manufacturer|Product'
grep -rh backports /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null
swaymsg -t get_outputs -r | jq -r '.[] | [.name, .make, .model, .serial,
    .rect.x, .rect.y, .rect.width, .rect.height] | @tsv'
xrandr --query
lspci | grep -Ei 'vga|3d|display'
free -h
sudo dmidecode -t memory | grep -E 'Size|Speed|Type|Manufacturer'
lsblk -o NAME,SIZE,MODEL,TRAN,MOUNTPOINTS
```

Этого достаточно, чтобы дописать новую ветку по hostname и не переспрашивать.

## Источники характеристик

- Официальная страница модели (ACEMAGIC): <https://acemagic.com/products/acemagic-lx15-pro-laptop>
- OEM (CYX LX 15 Pro): <https://en.cyxtech.com/lx-15-pro-high-performance-laptop-product/>
- AMD Ryzen 5 7430U: <https://www.amd.com/en/products/processors/laptop/ryzen/7000-series/amd-ryzen-5-7430u.html>
- Intel Celeron N4120: <https://www.intel.com/content/www/us/en/products/sku/197309/intel-celeron-processor-n4120-4m-cache-up-to-2-60-ghz/specifications.html>
