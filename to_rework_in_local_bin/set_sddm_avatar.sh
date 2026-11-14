#!/bin/bash

# Путь к исходной картинке (обязательно в кавычках из-за пробела)
SRC="$HOME/Изображения/adult neptune.jpeg"

# Имя пользователя
USER="$(whoami)"

# Папка для SDDM аватарок
DEST_DIR="/usr/share/sddm/faces"
DEST_FILE="$DEST_DIR/$USER.face.icon"

# Создаём папку, если не существует
sudo mkdir -p "$DEST_DIR"

# Копируем картинку в faces с правильными правами
if [ -f "$SRC" ]; then
    sudo cp "$SRC" "$DEST_FILE"
    sudo chown root:root "$DEST_FILE"
    sudo chmod 644 "$DEST_FILE"
    echo "Аватар успешно установлен: $DEST_FILE"
else
    echo "Ошибка: файл источника не найден: $SRC"
    exit 1
fi

# Перезапускаем SDDM
sudo systemctl restart sddm
