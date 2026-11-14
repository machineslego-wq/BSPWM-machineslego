#!/bin/bash

# Скрипт для исправления ошибки OpenRGB "I2C or SMBus interfaces failed to initialize"
# Процессор: Intel i5-11600K (требует модули i2c-dev и i2c-i801)

set -e  # Останавливаем скрипт при любой ошибке

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    echo "Пожалуйста, запустите с sudo: sudo $0"
    exit 1
fi

echo "=== Настройка I2C для OpenRGB ==="

# 1. Загружаем модули ядра
echo "Загружаем модули i2c-dev и i2c-i801..."
modprobe i2c-dev
modprobe i2c-i801

# 2. Добавляем модули в автозагрузку (через /etc/modules-load.d)
CONF_FILE="/etc/modules-load.d/openrgb-i2c.conf"
echo "Добавляем модули в автозагрузку ($CONF_FILE)..."
cat > "$CONF_FILE" << EOF
# Загружается для OpenRGB (Intel i5-11600K)
i2c-dev
i2c-i801
EOF

# 3. Настраиваем права доступа для пользователя (группа i2c)
echo "Настраиваем права доступа к I2C устройствам..."
if ! getent group i2c > /dev/null; then
    groupadd i2c
fi

# Добавляем текущего пользователя (из SUDO_USER) в группу i2c
if [ -n "$SUDO_USER" ]; then
    usermod -a -G i2c "$SUDO_USER"
    echo "Пользователь $SUDO_USER добавлен в группу i2c."
else
    echo "Предупреждение: не удалось определить пользователя. Добавьте себя в группу i2c вручную:"
    echo "  sudo usermod -a -G i2c \$USER"
fi

# Создаём правило udev для изменения прав на /dev/i2c-*
UDEV_RULE="/etc/udev/rules.d/99-i2c-permissions.rules"
echo "Создаём правило udev ($UDEV_RULE)..."
cat > "$UDEV_RULE" << EOF
# Предоставляем доступ к I2C устройствам для группы i2c
KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
EOF

# Перезагружаем udev
udevadm control --reload-rules
udevadm trigger

echo ""
echo "=== Готово! ==="
echo "Что сделано:"
echo "  ✅ Загружены модули i2c-dev и i2c-i801 (работают сейчас)"
echo "  ✅ Модули добавлены в автозагрузку"
echo "  ✅ Пользователь $SUDO_USER добавлен в группу i2c"
echo "  ✅ Настроены права udev для доступа к /dev/i2c-*"
echo ""
echo "ВАЖНО: Чтобы изменения прав доступа вступили в силу, необходимо:"
echo "  1. Выйти из системы и зайти заново (или перезагрузить компьютер)."
echo "  2. После перезагрузки запустить OpenRGB обычным пользователем (без sudo)."
echo ""
echo "Если ошибка останется, проверьте, загружен ли драйвер i2c-i801:"
echo "  lsmod | grep i2c"
echo "А также убедитесь, что чипсет материнской платы поддерживает SMBus."
