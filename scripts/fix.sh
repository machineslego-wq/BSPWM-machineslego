#!/bin/bash
# ==========================================================
# fix.sh — Хотфикс для раскладки клавиатуры
# ==========================================================

echo "=== Применение фикса раскладки (CapsLock) ==="

# Запрашиваем пароль sudo один раз
sudo -v || { echo "Ошибка: требуются права sudo."; exit 1; }

echo "-> Настройка системной раскладки (CapsLock для смены языка)..."
sudo mkdir -p /etc/X11/xorg.conf.d/
sudo tee /etc/X11/xorg.conf.d/00-keyboard.conf > /dev/null <<EOF
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "us,ru"
    Option "XkbModel" "pc105"
    Option "XkbOptions" "grp:caps_toggle"
EndSection
EOF

echo "   Готово. Конфиг записан в /etc/X11/xorg.conf.d/00-keyboard.conf"
echo ""
echo "=== Фикс применён! ==="
echo "Пожалуйста, перезагрузите систему (или перезайдите в сессию), чтобы CapsLock заработал как переключатель языка."