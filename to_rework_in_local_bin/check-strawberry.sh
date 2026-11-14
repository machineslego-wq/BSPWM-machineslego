#!/bin/bash
echo "========================================"
echo "Диагностика иконок для Strawberry/Qt"
echo "Дата: $(date)"
echo "Хост: $(hostname)"
echo "========================================"

echo "1. Тема иконок в GNOME:"
gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null || echo "Не удалось получить"

echo -e "\n2. Наследование Papirus:"
grep -E "^Inherits=" /usr/share/icons/Papirus-Dark/index.theme 2>/dev/null || echo "Файл не найден"

echo -e "\n3. Установленные пакеты иконок:"
dpkg -l | grep -E "papirus-icon-theme|breeze-icon-theme|kf6-breeze-icon-theme|qt6-gtk-platformtheme" | awk '{print $1,$2,$3}'

echo -e "\n4. Переменные окружения:"
env | grep -E "QT_|XDG_DATA_DIRS" | sort

echo -e "\n5. Структура каталогов Papirus (16x16):"
ls -la /usr/share/icons/Papirus-Dark/16x16/ 2>/dev/null | grep -E "apps|actions" || echo "Нет доступа или папка отсутствует"

echo -e "\n6. Проверка наличия иконок:"
for icon in document-open-folder media-playback-start; do
  echo -n "  $icon (actions): "
  find /usr/share/icons/Papirus-Dark -name "${icon}*" -path "*/actions/*" | head -1 | xargs -r ls -l 2>/dev/null || echo "Нет"
  echo -n "  $icon (apps): "
  find /usr/share/icons/Papirus-Dark -name "${icon}*" -path "*/apps/*" | head -1 | xargs -r ls -l 2>/dev/null || echo "Нет"
done

echo -e "\n7. Содержимое apps (первые 5 файлов):"
ls /usr/share/icons/Papirus-Dark/16x16/apps/ 2>/dev/null | head -5 || echo "Папка apps отсутствует"

echo -e "\n8. Платформа Qt (какой плагин используется по умолчанию):"
echo "QT_QPA_PLATFORM: $QT_QPA_PLATFORM"
echo "QT_QPA_PLATFORMTHEME: $QT_QPA_PLATFORMTHEME"

echo -e "\n9. Версия Strawberry (если установлен):"
strawberry --version 2>/dev/null || echo "Не найден"

echo -e "\n10. Проверка работы через gtk3 (быстрый тест):"
echo "Запуск strawberry с QT_QPA_PLATFORMTHEME=gtk3 QT_ICON_THEME=Papirus-Dark и логом иконок..."
timeout 5s env QT_QPA_PLATFORMTHEME=gtk3 QT_ICON_THEME=Papirus-Dark QT_LOGGING_RULES="*.debug=true" strawberry 2>&1 | grep -E "Searched icon themes|Theme key" | head -5 || echo "Тест не удался (возможно, strawberry не запускается)"

echo -e "\n11. Проверка наличия breeze-dark (родительская тема):"
ls -ld /usr/share/icons/breeze-dark 2>/dev/null || echo "breeze-dark отсутствует"

echo "========================================"
echo "Диагностика завершена."
