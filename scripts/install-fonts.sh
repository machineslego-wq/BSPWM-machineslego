#!/bin/bash
# ==========================================================
# install-fonts.sh — Интерактивная установка Nerd Fonts
# ==========================================================

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

echo "=== Установка Nerd Fonts ==="
echo "Выберите шрифт, который хотите установить:"
echo "  1) JetBrainsMono Nerd Font"
echo "  2) RobotoMono Nerd Font"
echo "  3) FiraCode Nerd Font"
echo "  4) FiraMono Nerd Font"
echo "  5) DroidSansMono Nerd Font"
echo "  6) Cousine Nerd Font"
echo "  7) Выход"
read -p "Введите номер (1-7): " FONT_CHOICE

case "$FONT_CHOICE" in
    1)
        FONT_NAME="JetBrainsMono"
        FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/JetBrainsMono.zip"
        ;;
    2)
        FONT_NAME="RobotoMono"
        FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/RobotoMono.zip"
        ;;
    3)
        FONT_NAME="FiraCode"
        FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/FiraCode.zip"
        ;;
    4)
        FONT_NAME="FiraMono"
        FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/FiraMono.zip"
        ;;
    5)
        FONT_NAME="DroidSansMono"
        FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/DroidSansMono.zip"
        ;;
    6)
        FONT_NAME="Cousine"
        FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/Cousine.zip"
        ;;
    7)
        echo "Выход."
        exit 0
        ;;
    *)
        echo "Неверный выбор. Выход."
        exit 1
        ;;
esac

# Проверка зависимостей
if ! command -v wget &>/dev/null || ! command -v unzip &>/dev/null; then
    echo "Устанавливаем wget и unzip..."
    sudo apt install -y wget unzip
fi

# Проверка, установлен ли уже шрифт
if fc-list | grep -qi "${FONT_NAME} Nerd Font"; then
    echo "Шрифт ${FONT_NAME} Nerd Font уже установлен!"
    SKIP_DOWNLOAD=1
else
    SKIP_DOWNLOAD=0
    TMP_ZIP="/tmp/${FONT_NAME}.zip"
    echo "Скачиваем ${FONT_NAME} Nerd Font..."
    wget -q --show-progress "$FONT_URL" -O "$TMP_ZIP"
    
    if [ $? -ne 0 ]; then
        echo "Ошибка скачивания. Проверьте интернет."
        exit 1
    fi
    
    echo "Распаковываем..."
    unzip -q "$TMP_ZIP" -d "$FONT_DIR"
    rm "$TMP_ZIP"
    
    echo "Обновляем кэш шрифтов..."
    fc-cache -f "$FONT_DIR" > /dev/null
    echo "Готово!"
fi

# Вывод инструкции
echo ""
echo "=========================================================="
echo " КАК ИСПОЛЬЗОВАТЬ ШРИФТ ${FONT_NAME}:"
echo "=========================================================="
echo ""
echo "1. Откройте конфиг Polybar:"
echo "   nano ~/.config/polybar/config.ini"
echo "   Найдите строку font-0 и замените её на:"
echo "   font-0 = ${FONT_NAME} Nerd Font;2"
echo ""
echo "2. Откройте конфиг Fastfetch:"
echo "   nano ~/.config/fastfetch/config.jsonc"
echo "   Найдите все секции \"family\" и замените на:"
echo "   \"family\": \"${FONT_NAME} Nerd Font\""
echo ""
echo "3. Перезапустите Polybar:"
echo "   pkill -x polybar && ~/.config/polybar/launch.sh"
echo ""
echo "4. Проверьте, что шрифт виден системе:"
echo "   fc-list | grep -i \"${FONT_NAME}\""
echo "=========================================================="