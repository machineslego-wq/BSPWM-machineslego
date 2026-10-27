#!/bin/bash
# ==========================================================
# cheatsheet.sh — Статичная шпаргалка горячих клавиш
# ==========================================================
# Скрипт выводит красиво отформатированный список клавиш в Rofi.
# -scroll-method 1 = плавная прокрутка (по одной строке)
# -scroll-method 0 = постраничная прокрутка (PageDown перескакивает на 20 строк)
# Особенности:
# - Иконки Nerd Font для каждого раздела.
# - Скрытые теги в конце строк (написаны тем же цветом,
#   что и фон, поэтому не видны, но работают в поиске Rofi).
# ==========================================================

cat <<EOF | rofi -dmenu -i -markup-rows -scroll-method 1 -p "󰌌 Горячие клавиши" -theme-str 'window {width: 50%; height: 70%;} listview {lines: 20; scrollbar: true;}'
<b>󰒓 СИСТЕМА И ЗАПУСК</b>
󰌌 Super + /                        Шпаргалка                      <span foreground="#1a1b26">[помощь, хелп, help, клавиши]</span>
󰆍 Super + Return                   Терминал (Alacritty)           <span foreground="#1a1b26">[консоль, cmd, shell, terminal]</span>
󰀻 Super + D                        Лаунчер (Rofi)                 <span foreground="#1a1b26">[меню, пуск, запуск, search]</span>
󰈹 Super + B                        Браузер (Firefox)              <span foreground="#1a1b26">[браузер, интернет, web, firefox]</span>
󰨞 Super + V                        Редактор (VS Code)             <span foreground="#1a1b26">[код, редактор, vscode, ide]</span>
󰉋 Super + E                        Файлы (Thunar)                 <span foreground="#1a1b26">[файлы, проводник, папки, explorer]</span>
󰕾 Super + A                        Микшер звука                   <span foreground="#1a1b26">[звук, громкость, audio, наушники]</span>
󰖩 Super + Alt + N                  Управление Wi-Fi               <span foreground="#1a1b26">[сеть, wifi, интернет, хотспот, nmcli]</span>
 Super + Alt + T                  Telegram (flatpak) + Proxy     <span foreground="#1a1b26">[телеграм, чат, messenger, прокси, proxy]</span>
󰔏 Super + X                        Датчики (терминал)             <span foreground="#1a1b26">[датчики, сенсоры, нагрев, sensors, watch]</span>
󰑓 Super + Escape                   Перезагрузить SXHKD            <span foreground="#1a1b26">[рестарт, конфиг, reload]</span>
󰜉 Super + Alt + Shift + R          Перезапуск всего (Reload)      <span foreground="#1a1b26">[рестарт, окна, wm, polybar, dunst]</span>
󰅌 Super + Ctrl + V                 История буфера (CopyQ)         <span foreground="#1a1b26">[буфер, clipboard, вставка, copy, paste, история]</span>
󰂚 Super + Alt + H                  История уведомлений            <span foreground="#1a1b26">[уведомления, notifications, dunst, история]</span>

<b>󰐥 ПИТАНИЕ И БЛОКИРОВКА</b>
󰤆 Super + Shift + Q                Меню питания (Rofi)            <span foreground="#1a1b26">[poweroff, reboot, logout, lock, питание]</span>
󰓅 Super + Alt + P                  Выбор режима питания           <span foreground="#1a1b26">[питание, ppd, энергосбережение, батарея]</span>
󰌾 Super + Alt + L                  Заблокировать экран            <span foreground="#1a1b26">[lock, блокировка, пароль]</span>
󰜉 Super + Alt + Q                  Выход из BSPWM                 <span foreground="#1a1b26">[выход, quit, exit, logout]</span>
󰜉 Super + Alt + R                  Перезапуск BSPWM               <span foreground="#1a1b26">[рестарт, wm, reload, bspwm]</span>

<b>󰄄 СКРИНШОТЫ (В БУФЕР)</b>
󰹑 Super + F1                       Весь экран                     <span foreground="#1a1b26">[скриншот, screenshot, снять, экран, capture]</span>
󰖲 Super + F2                       Активное окно                  <span foreground="#1a1b26">[скриншот, screenshot, окно, window]</span>
󰩭 Super + Shift + S                Выделенная область             <span foreground="#1a1b26">[скриншот, screenshot, регион, зона]</span>
󰔛 Super + F3                       Экран (задержка 3с)            <span foreground="#1a1b26">[скриншот, screenshot, таймер, delay]</span>

<b>󰖯 УПРАВЛЕНИЕ ОКНАМИ</b>
󰁔 Super + Стрелки                  Смена фокуса                   <span foreground="#1a1b26">[окно, window, фокус, focus]</span>
󰩨 Super + Shift + Стрелки          Свап с соседом (тайлы)         <span foreground="#1a1b26">[окно, window, свап, swap, tiled]</span>
󰩨 Super + H / J / K / L            Двигать флоат (Vim)            <span foreground="#1a1b26">[окно, window, move, floating, vim]</span>
󰩨 Super + Alt + Стрелки            Изменить размер (растянуть)    <span foreground="#1a1b26">[окно, window, ресайз, resize]</span>
󰩨 Super + Alt + Shift + Стрелки    Сжать размер                   <span foreground="#1a1b26">[окно, window, ресайз, resize]</span>
󰍹 Super + 1..9, 0                  Переключить стол               <span foreground="#1a1b26">[стол, workspace, десктоп]</span>
󰧨 Super + Shift + 1..9, 0          Перенести окно на стол         <span foreground="#1a1b26">[окно, window, стол, workspace]</span>
󰁔 Super + [                        Предыдущий стол                <span foreground="#1a1b26">[стол, workspace, prev]</span>
󰁔 Super + ]                        Следующий стол                 <span foreground="#1a1b26">[стол, workspace, next]</span>
󰓾 Super + Tab                      Предыдущее окно/стол           <span foreground="#1a1b26">[окно, window, назад, alt-tab]</span>
󰖯 Alt + Tab                        Поиск по открытым окнам        <span foreground="#1a1b26">[окно, window, поиск, switch, rofi, alt-tab]</span>
󰒆 Super + C                        Следующее окно                 <span foreground="#1a1b26">[окно, window, next, cycle]</span>
󰒆 Super + Shift + C                Предыдущее окно                <span foreground="#1a1b26">[окно, window, prev, cycle]</span>
󰒆 Super + O / I                    История фокуса (назад/вперёд)  <span foreground="#1a1b26">[окно, window, focus, history]</span>
󰒆 Super + P / B / , / .            Переход по дереву              <span foreground="#1a1b26">[дерево, tree, parent, brother]</span>
󰅖 Super + W                        Закрыть окно                   <span foreground="#1a1b26">[окно, window, close, quit, выход]</span>
󰅚 Super + Shift + W                Убить процесс                  <span foreground="#1a1b26">[окно, window, kill, force, зависло]</span>
󰕰 Super + M                        Режим Monocle (стопка)         <span foreground="#1a1b26">[окно, window, layout, стопка]</span>

<b>󰕰 РЕЖИМЫ И ПРЕСЕЛЕКТ</b>
󰕰 Super + T                        Тайловый режим                 <span foreground="#1a1b26">[окно, window, тайлинг, tile, layout]</span>
󰕰 Super + Shift + T                Псевдо-тайловый                <span foreground="#1a1b26">[окно, window, тайлинг, pseudo]</span>
󰖲 Super + S                        Плавающий режим                <span foreground="#1a1b26">[окно, window, floating, плавающее]</span>
󰊓 Super + F                        На весь экран                  <span foreground="#1a1b26">[окно, window, full, развернуть]</span>
󰕰 Super + G                        Свап с самым большим окном     <span foreground="#1a1b26">[окно, window, biggest, swap]</span>
󰕰 Super + Y                        Отправить помеченное в preselect<span foreground="#1a1b26">[окно, window, marked, preselect]</span>
󰆉 Super + Ctrl + Стрелки           Preselect (направление)        <span foreground="#1a1b26">[окно, window, направление, preselect]</span>
󰆉 Super + Ctrl + 1..9              Preselect (пропорция)          <span foreground="#1a1b26">[окно, window, пропорция, preselect, ratio]</span>
󰅖 Super + Ctrl + Space             Отменить Preselect (окно)      <span foreground="#1a1b26">[окно, window, отмена, cancel]</span>
󰅖 Super + Ctrl + Shift + Space     Отменить Preselect (стол)      <span foreground="#1a1b26">[окно, window, отмена, cancel, стол]</span>

<b>󰒆 ФЛАГИ ОКОН (повторное нажатие снимает флаг)</b>
󰒆 Super + Ctrl + M                 Пометить окно (для Super+Y)    <span foreground="#1a1b26">[окно, window, marked, пометка, preselect]</span>
󰒆 Super + Ctrl + X                 Защитить от закрытия           <span foreground="#1a1b26">[окно, window, locked, защита, от случайного закрытия]</span>
󰒆 Super + Ctrl + Y                 Показывать на всех столах      <span foreground="#1a1b26">[окно, window, sticky, везде, на всех столах]</span>
󰒆 Super + Ctrl + Z                 Спрятать с других столов       <span foreground="#1a1b26">[окно, window, private, скрыть, только свой стол]</span>
EOF