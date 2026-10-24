#!/bin/bash
# ==========================================================
# cheatsheet.sh — Статичная шпаргалка горячих клавиш
# ==========================================================
# Скрипт выводит красиво отформатированный список клавиш в Rofi.
# 
# Особенности:
# - Иконки Nerd Font для каждого раздела.
# - Скрытые теги в конце строк (написаны тем же цветом,
#   что и фон, поэтому не видны, но работают в поиске Rofi).
# ==========================================================

cat <<EOF | rofi -dmenu -i -markup-rows -p "󰌌 Горячие клавиши" -theme-str 'window {width: 50%; height: 70%;} listview {lines: 20; scrollbar: true;}'
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

<b>󰐥 ПИТАНИЕ И БЛОКИРОВКА</b>
󰤆 Super + Shift + Q                Меню питания (Rofi)            <span foreground="#1a1b26">[poweroff, reboot, logout, питание]</span>
󰓅 Super + Alt + P                  Выбор режима питания           <span foreground="#1a1b26">[питание, tlp, энергосбережение, батарея]</span>
󰌾 Super + L                        Заблокировать экран            <span foreground="#1a1b26">[lock, блокировка, пароль]</span>

<b>󰄄 СКРИНШОТЫ (В БУФЕР)</b>
󰹑 Super + F1                       Весь экран                     <span foreground="#1a1b26">[скриншот, screenshot, снять, экран, capture]</span>
󰖲 Super + F2                       Активное окно                  <span foreground="#1a1b26">[скриншот, screenshot, окно, window]</span>
󰩭 Super + Shift + S                Выделенная область             <span foreground="#1a1b26">[скриншот, screenshot, регион, зона]</span>
󰔛 Super + F3                       Экран (задержка 3с)            <span foreground="#1a1b26">[скриншот, screenshot, таймер, delay]</span>

<b>󰖯 УПРАВЛЕНИЕ ОКНАМИ</b>
󰁔 Super + Стрелки                  Смена фокуса                   <span foreground="#1a1b26">[окно, window, фокус, focus]</span>
 Super + Shift + Стрелки          Поменять окна местами          <span foreground="#1a1b26">[окно, window, свап, swap]</span>
󰩨 Super + H/J/U/K                  Двигать плавающее окно         <span foreground="#1a1b26">[окно, window, move, двигать, floating]</span>
󰩨 Super + Alt + Стрелки            Изменить размер (растянуть)    <span foreground="#1a1b26">[окно, window, ресайз, resize]</span>
󰩨 Super + Alt + Shift + Стрелки    Сжать размер                   <span foreground="#1a1b26">[окно, window, ресайз, resize]</span>
󰍹 Super + 1..9, 0                  Переключить стол               <span foreground="#1a1b26">[стол, workspace, десктоп]</span>
󰧨 Super + Shift + 1..9, 0          Перенести окно на стол         <span foreground="#1a1b26">[окно, window, стол, workspace]</span>
󰓾 Super + Tab                      Предыдущее окно                <span foreground="#1a1b26">[окно, window, назад, alt-tab]</span>
󰖯 Alt + Tab                        Поиск по открытым окнам        <span foreground="#1a1b26">[окно, window, поиск, switch, rofi, alt-tab]</span>
󰅖 Super + W                        Закрыть окно                   <span foreground="#1a1b26">[окно, window, close, quit, выход]</span>
󰅚 Super + Shift + W                Убить процесс                  <span foreground="#1a1b26">[окно, window, kill, force, зависло]</span>
󰕰 Super + M                        Режим Monocle (стопка)         <span foreground="#1a1b26">[окно, window, layout, стопка]</span>

<b>󰕰 РЕЖИМЫ И PRESELECT</b>
󰕰 Super + T                        Тайловый режим                 <span foreground="#1a1b26">[окно, window, тайлинг, tile, layout]</span>
󰕰 Super + Shift + T                Псевдо-тайловый                <span foreground="#1a1b26">[окно, window, тайлинг, pseudo]</span>
󰖲 Super + S                        Плавающий режим                <span foreground="#1a1b26">[окно, window, floating, плавающее]</span>
󰊓 Super + F                        На весь экран                  <span foreground="#1a1b26">[окно, window, full, развернуть]</span>
󰆉 Super + Ctrl + Стрелки           Preselect (направление)        <span foreground="#1a1b26">[окно, window, направление, preselect]</span>
󰅖 Super + Ctrl + Space             Отменить Preselect             <span foreground="#1a1b26">[окно, window, отмена, cancel]</span>
EOF