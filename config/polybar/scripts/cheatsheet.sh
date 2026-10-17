#!/bin/bash
# Шпаргалка по горячим клавишам

cat <<EOF | rofi -dmenu -i -p "󰌌 Горячие клавиши" -theme-str 'window {width: 35%;} listview {lines: 20;}'
󰘳 ОСНОВНОЕ
  Super + Enter         Терминал (Alacritty)
  Super + D             Лаунчер (Rofi)
  Super + L             Заблокировать экран
  Super + Escape        Перезагрузить конфиг SXHKD
  Super + Alt + Shift + R  Перезапустить BSPWM + SXHKD

󰖲 ПИТАНИЕ
  Super + Shift + P     Выключение
  Super + Shift + R     Перезагрузка
  Super + Shift + L     Выйти из аккаунта
  Super + Alt + Q       Аварийный выход из BSPWM

󰖯 НАВИГАЦИЯ
  Super + Стрелки        Фокус между окнами
  Super + Shift + Стрелки  Поменять окна местами
  Super + 1..9, 0        Переключить рабочий стол
  Super + Shift + 1..9, 0  Переместить окно на стол
  Super + Tab            Предыдущее окно / стол
  Super + Bracket Left/Right  Предыдущий/следующий стол

󰕴 УПРАВЛЕНИЕ ОКНАМИ
  Super + Q             Закрыть окно (аккуратно)
  Super + W             Закрыть окно (убить процесс)
  Super + T             Тайловый режим
  Super + Shift + T     Плавающий режим (центр)
  Super + S             Плавающий режим (свободный)
  Super + F             На весь экран
  Super + M             Режим Monocle (стопка)

󰩨 РАЗМЕРЫ И РАСКЛАДКА
  Super + Alt + Стрелки  Изменить размер окна
  Super + Alt + Shift + Стрелки  Сжать окно
  Super + Ctrl + Стрелки  Выбрать направление (Preselect)
  Super + Ctrl + 1..9    Задать пропорцию (Preselect)
  Super + Ctrl + Space   Отменить Preselect

󰄄 СКРИНШОТЫ И МЕДИА
  Print                 Весь экран
  Shift + Print         Активное окно
  Super + Shift + S     Выделенная область
  Fn + Яркость          Яркость (+/-)
  Fn + Громкость        Громкость (+/-)
  Fn + Mute             Выключить звук
EOF