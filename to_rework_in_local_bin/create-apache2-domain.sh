#!/bin/bash

# Скрипт для создания виртуальных хостов в Apache2
# и добавления записей в /etc/hosts
# Требует права root для выполнения

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для вывода сообщений
print_message() {
    echo -e "${2}${1}${NC}"
}

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    print_message "Этот скрипт требует права root. Используйте sudo." "$RED"
    exit 1
fi

# Ввод названия домена
read -p "Введите название домена (например: mydomain.local): " domain_name

# Проверка ввода
if [ -z "$domain_name" ]; then
    print_message "Ошибка: название домена не может быть пустым." "$RED"
    exit 1
fi

# Проверка формата домена
if ! [[ $domain_name =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    print_message "Ошибка: неверный формат доменного имени." "$RED"
    exit 1
fi

# Пути к файлам
hosts_file="/etc/hosts"
sites_available_dir="/etc/apache2/sites-available"
sites_enabled_dir="/etc/apache2/sites-enabled"
document_root="/var/www/html/$domain_name"

print_message "Начинаем настройку домена: $domain_name" "$YELLOW"

# 1. Добавление в /etc/hosts
print_message "1. Добавляем запись в /etc/hosts..." "$YELLOW"

if grep -q "$domain_name" "$hosts_file"; then
    print_message "Запись для $domain_name уже существует в /etc/hosts" "$YELLOW"
else
    echo "127.0.0.1    $domain_name" >> "$hosts_file"
    print_message "Запись 127.0.0.1 $domain_name добавлена в $hosts_file" "$GREEN"
fi

# 2. Создание директории для сайта
print_message "2. Создаем директорию для сайта..." "$YELLOW"

if [ ! -d "$document_root" ]; then
    mkdir -p "$document_root"
    # Создаем стандартного владельца www-data (пользователь Apache)
    chown -R www-data:www-data "$document_root"
    print_message "Директория $document_root создана" "$GREEN"
else
    print_message "Директория $document_root уже существует" "$YELLOW"
fi

# 3. Создание тестового index.html
print_message "3. Создаем тестовую страницу..." "$YELLOW"

cat > "$document_root/index.html" << EOF
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Welcome to $domain_name</title>
</head>
<body>
    <h1>Добро пожаловать на $domain_name!</h1>
    <p>Это тестовая страница для виртуального хоста.</p>
    <p>Сайт работает корректно!</p>
    <p>Время создания: $(date)</p>
</body>
</html>
EOF

chown www-data:www-data "$document_root/index.html"
print_message "Тестовая страница создана" "$GREEN"

# 4. Создание конфигурации виртуального хоста
print_message "4. Создаем конфигурацию виртуального хоста..." "$YELLOW"

vhost_file="$sites_available_dir/$domain_name.conf"

cat > "$vhost_file" << EOF
<VirtualHost *:80>
    ServerName $domain_name
    ServerAlias www.$domain_name
    DocumentRoot $document_root
    
    # Логи
    ErrorLog \${APACHE_LOG_DIR}/${domain_name}_error.log
    CustomLog \${APACHE_LOG_DIR}/${domain_name}_access.log combined
    
    # Настройки директории
    <Directory $document_root>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

print_message "Конфигурация виртуального хоста создана: $vhost_file" "$GREEN"

# 5. Активация сайта
print_message "5. Активируем сайт..." "$YELLOW"

a2ensite "$domain_name.conf" > /dev/null 2>&1

# 6. Проверка конфигурации Apache
print_message "6. Проверяем конфигурацию Apache..." "$YELLOW"

if apache2ctl configtest; then
    print_message "Конфигурация Apache корректна" "$GREEN"
    
    # 7. Перезагрузка Apache
    print_message "7. Перезагружаем Apache..." "$YELLOW"
    systemctl reload apache2
    print_message "Apache перезагружен" "$GREEN"
else
    print_message "Ошибка в конфигурации Apache! Проверьте настройки." "$RED"
    # Отключаем сайт при ошибке
    a2dissite "$domain_name.conf" > /dev/null 2>&1
    exit 1
fi

# Вывод информации
print_message "
=== Настройка завершена успешно! ===

Домен: $domain_name
Документ рут: $document_root
URL: http://$domain_name

Для отключения сайта выполните:
sudo a2dissite $domain_name.conf
sudo systemctl reload apache2

Для удаления сайта выполните:
sudo rm $sites_available_dir/$domain_name.conf
sudo rm -rf $document_root
sudo sed -i '/$domain_name/d' $hosts_file
" "$GREEN"
