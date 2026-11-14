#!/bin/bash

# ============================================
# КОНФИГУРАЦИЯ (настройте под себя!)
# ============================================

SERVER_IP="192.168.3.8"           # IP вашего сервера
BASE_DIR="$HOME/nfs_share"         # Базовая папка для монтирования
MOUNT_TIMEOUT=10                   # Таймаут в секундах (для параметров NFS)

# Пары: серверная_папка  локальное_имя_папки
MOUNT_PAIRS=(
    "/mnt/apps/downloads downloads"
    "/mnt/main/nikita nikita"
)

# ============================================
# НАСТРОЙКИ СКРИПТА (можно не менять)
# ============================================

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# NFS опции с таймаутом 10 секунд
NFS_OPTIONS="vers=4,_netdev,soft,timeo=100,retrans=1,noexec,nosuid"

# ============================================
# ФУНКЦИИ
# ============================================

# Создание папок если их нет
create_dirs() {
    echo -e "${BLUE}Проверяю папки в $BASE_DIR...${NC}"
    
    for pair in "${MOUNT_PAIRS[@]}"; do
        read remote local_name <<< "$pair"
        local_dir="$BASE_DIR/$local_name"
        
        if [ ! -d "$local_dir" ]; then
            echo -e "${YELLOW}Создаю $local_dir...${NC}"
            mkdir -p "$local_dir"
            if [ $? -ne 0 ]; then
                echo -e "${RED}Ошибка: не удалось создать $local_dir${NC}"
                echo -e "${YELLOW}Пробую через sudo...${NC}"
                sudo mkdir -p "$local_dir" && sudo chown $(id -u):$(id -g) "$local_dir"
            fi
        fi
    done
    echo ""
}

# Проверка: смонтировано ли уже
is_mounted() {
    local local_dir="$1"
    mount | grep -q "$local_dir" && return 0
    return 1
}

# Монтирование
do_mount() {
    echo -e "${BLUE}=== МОНТИРОВАНИЕ ===${NC}"
    echo "Сервер: $SERVER_IP"
    echo "Таймаут: ${MOUNT_TIMEOUT}с"
    echo ""

    create_dirs

    mounted_count=0
    total_count=0

    for pair in "${MOUNT_PAIRS[@]}"; do
        read remote local_name <<< "$pair"
        local_dir="$BASE_DIR/$local_name"
        ((total_count++))

        echo -n "• $remote -> $local_dir: "

        # Проверяем, не смонтировано ли уже
        if is_mounted "$local_dir"; then
            echo -e "${YELLOW}уже смонтирован${NC}"
            ((mounted_count++))
            continue
        fi

        # Пробуем монтировать
        sudo mount -t nfs -o $NFS_OPTIONS "${SERVER_IP}:${remote}" "$local_dir" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            # Меняем владельца на текущего пользователя
            sudo chown $(id -u):$(id -g) "$local_dir" 2>/dev/null
            echo -e "${GREEN}ОК${NC}"
            ((mounted_count++))
        else
            echo -e "${RED}ОШИБКА (сервер недоступен?)${NC}"
        fi
    done

    echo ""
    echo -e "${BLUE}Итог:${NC} $mounted_count из $total_count смонтированы"
    echo ""
    show_status
}

# Размонтирование
do_umount() {
    echo -e "${BLUE}=== РАЗМОНТИРОВАНИЕ ===${NC}"

    unmounted_count=0
    total_count=0

    for pair in "${MOUNT_PAIRS[@]}"; do
        read remote local_name <<< "$pair"
        local_dir="$BASE_DIR/$local_name"
        ((total_count++))

        echo -n "• $local_dir: "

        # Проверяем, смонтировано ли
        if is_mounted "$local_dir"; then
            sudo umount "$local_dir" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}размонтирован${NC}"
                ((unmounted_count++))
            else
                echo -e "${RED}ошибка размонтирования${NC}"
                echo -e "${YELLOW}Пробую 'ленивое' размонтирование...${NC}"
                sudo umount -l "$local_dir" 2>/dev/null && echo -e "${GREEN}размонтирован (lazy)${NC}"
            fi
        else
            echo -e "${YELLOW}не был смонтирован${NC}"
            ((unmounted_count++))
        fi
    done

    echo ""
    echo -e "${BLUE}Итог:${NC} $unmounted_count из $total_count размонтированы"
}

# Показать статус
show_status() {
    echo -e "${BLUE}=== ТЕКУЩИЙ СТАТУС ===${NC}"
    
    for pair in "${MOUNT_PAIRS[@]}"; do
        read remote local_name <<< "$pair"
        local_dir="$BASE_DIR/$local_name"
        
        echo -n "• $local_dir: "
        
        if is_mounted "$local_dir"; then
            # Получаем детальную информацию о монтировании
            mount_info=$(mount | grep "$local_dir")
            nfs_version=$(echo "$mount_info" | grep -o "vers=[0-9.]*" || echo "vers=?")
            echo -e "${GREEN}СМОНТИРОВАН${NC} ($nfs_version)"
        else
            if [ -d "$local_dir" ]; then
                echo -e "${YELLOW}папка есть, не смонтирован${NC}"
            else
                echo -e "${RED}папка отсутствует${NC}"
            fi
        fi
    done
    echo ""
}

# Показать справку
show_help() {
    echo -e "${BLUE}Использование:${NC}"
    echo "  $0 mount     - смонтировать все NFS-шары"
    echo "  $0 umount    - размонтировать все NFS-шары"
    echo "  $0 status    - показать статус"
    echo "  $0 help      - эта справка"
    echo ""
    echo -e "${BLUE}Конфигурация:${NC}"
    echo "  Сервер: $SERVER_IP"
    echo "  Локальная папка: $BASE_DIR"
    echo "  Шары:"
    for pair in "${MOUNT_PAIRS[@]}"; do
        read remote local_name <<< "$pair"
        echo "    - $remote -> $BASE_DIR/$local_name"
    done
    echo ""
}

# ============================================
# ОСНОВНАЯ ЛОГИКА
# ============================================

# Проверяем, что скрипт запущен не от root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Не запускайте этот скрипт от root!${NC}"
    echo -e "Запускайте от своего пользователя, скрипт сам запросит sudo при необходимости."
    exit 1
fi

# Обработка команд
case "$1" in
    "mount")
        do_mount
        ;;
    "umount"|"unmount")
        do_umount
        ;;
    "status")
        show_status
        ;;
    "help"|"--help"|"-h"|"")
        show_help
        ;;
    *)
        echo -e "${RED}Неизвестная команда: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
