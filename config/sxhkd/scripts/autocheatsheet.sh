#!/bin/bash
# Статичная шпаргалка с иконками, цветами и скрытыми тегами

cat <<EOF | rofi -dmenu -i -markup-rows -p "󰌌 Горячие клавиши" -theme-str 'window {width: 50%; height: 80%;} listview {lines: 20; scrollbar: true;}'
<b>󰒓 СИСТЕМА И ЗАПУСК</b>
󰌌 Super + /                    Шпаргалка <span foreground="#1a1b26">[помощь, хелп, help, клавиши]</span>
󰆍 Super + Return               Терминал (Alacritty) <span foreground="#1a1b26">[консоль, cmd, shell, terminal]</span>
󰀻 Super + D                    Лаунчер (Rofi) <span foreground="#1a1b26">[меню, пуск, запуск, search]</span>
󰕾 Super + A                    Микшер звука <span foreground="#1a1b26">[звук, громкость, audio, наушники]</span>
󰔏 Super + X                    Температуры <span foreground="#1a1b26">[датчики, сенсоры, нагрев, sensors]</span>
󰑓 Super + Escape               Перезагрузить SXHKD <span foreground="#1a1b26">[рестарт, конфиг, reload]</span>
󰜉 Super + Alt + Shift + R      Перезапуск BSPWM <span foreground="#1a1b26">[рестарт, окна, wm]</span>

<b>󰐥 ПИТАНИЕ И БЛОКИРОВКА</b>
󰐥 Super + Shift + P            Выключить компьютер <span foreground="#1a1b26">[poweroff, shutdown, выкл, питание]</span>
󰜉 Super + Shift + R            Перезагрузить компьютер <span foreground="#1a1b26">[reboot, restart, перезагр]</span>
󰍃 Super + Shift + L            Выйти из аккаунта <span foreground="#1a1b26">[logout, выход, сессия]</span>
󰓅 Super + Alt + P              Выбор режима питания <span foreground="#1a1b26">[питание, tlp, энергосбережение, баттарея]</span>
󰌾 Super + L                    Заблокировать экран <span foreground="#1a1b26">[lock, блокировка, пароль]</span>

<b>󰄄 СКРИНШОТЫ (В БУФЕР)</b>
󰹑 Print                       Весь экран <span foreground="#1a1b26">[скриншот, screenshot, снять, экран, capture]</span>
󰖲 Shift + Print               Активное окно <span foreground="#1a1b26">[скриншот, screenshot, окно, window]</span>
󰩭 Super + Shift + S           Выделенная область <span foreground="#1a1b26">[скриншот, screenshot, регион, зона]</span>
󰔛 Super + Print               Экран (задержка 3с) <span foreground="#1a1b26">[скриншот, screenshot, таймер, delay]</span>

<b>󰖯 УПРАВЛЕНИЕ ОКНАМИ</b>
󰁔 Super + Стрелки              Смена фокуса <span foreground="#1a1b26">[окно, window, фокус, focus]</span>
 Super + Shift + Стрелки      Поменять окна местами <span foreground="#1a1b26">[окно, window, свап, swap]</span>
󰩨 Super + Alt + Стрелки        Изменить размер (растянуть) <span foreground="#1a1b26">[окно, window, ресайз, resize]</span>
󰩨 Super + Alt + Shift + Стрелки Сжать размер <span foreground="#1a1b26">[окно, window, ресайз, resize]</span>
󰍹 Super + 1..7                 Переключить стол <span foreground="#1a1b26">[стол, workspace, десктоп]</span>
󰧨 Super + Shift + 1..7         Перенести окно на стол <span foreground="#1a1b26">[окно, window, стол, workspace]</span>
󰓾 Super + Tab                  Предыдущее окно <span foreground="#1a1b26">[окно, window, назад, alt-tab]</span>
󰅖 Super + W                    Закрыть окно <span foreground="#1a1b26">[окно, window, close, quit, выход]</span>
󰅚 Super + Shift + W            Убить процесс <span foreground="#1a1b26">[окно, window, kill, force, зависло]</span>
󰕰 Super + M                    Режим Monocle (стопка) <span foreground="#1a1b26">[окно, window, layout, стопка]</span>

<b>󰕰 РЕЖИМЫ И PRESELECT</b>
󰕰 Super + T                    Тайловый режим <span foreground="#1a1b26">[окно, window, тайлинг, tile, layout]</span>
󰕰 Super + Shift + T            Псевдо-тайловый <span foreground="#1a1b26">[окно, window, тайлинг, pseudo]</span>
󰖲 Super + S                    Плавающий режим <span foreground="#1a1b26">[окно, window, floating, плавающее]</span>
󰊓 Super + F                    На весь экран <span foreground="#1a1b26">[окно, window, full, развернуть]</span>
󰆉 Super + Ctrl + Стрелки       Preselect (направление) <span foreground="#1a1b26">[окно, window, направление, preselect]</span>
󰅖 Super + Ctrl + Space         Отменить Preselect <span foreground="#1a1b26">[окно, window, отмена, cancel]</span>
EOF