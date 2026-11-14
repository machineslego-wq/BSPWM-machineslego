#!/bin/bash

# Скрипт для удаления виртуальных хостов Apache2
# и удаления записей из /etc/hosts

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_message() {
    echo -e "${2}${1}${NC}"
}

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    print_message "Этот скрипт требует права root. Используйте sudo." "$RED"
    exit 1
fi

read -p "Введите название домена для удаления (например: mydomain.local): " domain_name

if [ -z "$domain_name" ]; then
    print_message "Ошибка: название домена не может быть пустым." "$RED"
    exit 1
fi

# Пути к файлам
hosts_file="/etc/hosts"
sites_available_dir="/etc/apache2/sites-available"
sites_enabled_dir="/etc/apache2/sites-enabled"
document_root="/var/www/html/$domain_name"

print_message "Начинаем удаление домена: $domain_name" "$YELLOW"

# 1. Отключение сайта
print_message "1. Отключаем сайт..." "$YELLOW"
if [ -f "$sites_available_dir/$domain_name.conf" ]; then
    a2dissite "$domain_name.conf" > /dev/null 2>&1
    print_message "Сайт отключен" "$GREEN"
else
    print_message "Файл конфигурации не найден" "$YELLOW"
fi

# 2. Удаление конфигурации
print_message "2. Удаляем конфигурацию..." "$YELLOW"
if [ -f "$sites_available_dir/$domain_name.conf" ]; then
    rm "$sites_available_dir/$domain_name.conf"
    print_message "Конфигурация удалена" "$GREEN"
fi

# 3. Удаление из /etc/hosts
print_message "3. Удаляем запись из /etc/hosts..." "$YELLOW"
if grep -q "$domain_name" "$hosts_file"; then
    sed -i "/$domain_name/d" "$hosts_file"
    print_message "Запись удалена из /etc/hosts" "$GREEN"
else
    print_message "Запись не найдена в /etc/hosts" "$YELLOW"
fi

# 4. Удаление директории (опционально)
read -p "Удалить директорию сайта ($document_root)? [y/N]: " delete_dir
if [[ $delete_dir =~ ^[Yy]$ ]]; then
    if [ -d "$document_root" ]; then
        rm -rf "$document_root"
        print_message "Директория сайта удалена" "$GREEN"
    else
        print_message "Директория сайта не найдена" "$YELLOW"
    fi
fi

# 5. Перезагрузка Apache
print_message "5. Перезагружаем Apache..." "$YELLOW"
systemctl reload apache2
print_message "Apache перезагружен" "$GREEN"

print_message "Домен $domain_name успешно удален!" "$GREEN"
