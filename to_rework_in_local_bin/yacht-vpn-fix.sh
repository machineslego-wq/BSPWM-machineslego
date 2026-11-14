#!/bin/bash

# Скрипт для запуска Yacht с исправленной сетевой конфигурацией для работы с VPN
# Автор: скрипт автоматической настройки
# Версия: 1.0

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Конфигурация
YACHT_NAME="yacht"
YACHT_PORT="8000"
YACHT_IMAGE="selfhostedpro/yacht:latest"
DOCKER_SOCKET="/var/run/docker.sock"
CONFIG_VOLUME="yacht_config"
NETWORK_NAME="yacht_network"
NETWORK_SUBNET="172.20.0.0/16"

# Функция вывода сообщений
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Функция проверки прав
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Этот скрипт должен запускаться с правами root"
        echo "Используйте: sudo $0"
        exit 1
    fi
}

# Функция проверки Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker не установлен"
        exit 1
    fi
    
    if ! systemctl is-active --quiet docker; then
        log_warn "Docker не запущен. Пытаюсь запустить..."
        systemctl start docker
        sleep 3
    fi
}

# Функция создания сети
create_network() {
    if ! docker network ls | grep -q "$NETWORK_NAME"; then
        log_info "Создаю сеть $NETWORK_NAME..."
        docker network create \
            --driver bridge \
            --subnet="$NETWORK_SUBNET" \
            --opt "com.docker.network.bridge.name"="br-yacht" \
            "$NETWORK_NAME"
        log_info "Сеть $NETWORK_NAME создана"
    else
        log_info "Сеть $NETWORK_NAME уже существует"
    fi
}

# Функция остановки и удаления старого контейнера
cleanup_old_container() {
    if docker ps -a | grep -q "$YACHT_NAME"; then
        log_warn "Найден существующий контейнер $YACHT_NAME"
        
        if docker ps | grep -q "$YACHT_NAME"; then
            log_info "Останавливаю контейнер $YACHT_NAME..."
            docker stop "$YACHT_NAME"
            sleep 2
        fi
        
        log_info "Удаляю контейнер $YACHT_NAME..."
        docker rm "$YACHT_NAME"
    fi
}

# Функция запуска Yacht
start_yacht() {
    log_info "Запускаю Yacht с исправленной сетевой конфигурацией..."
    
    docker run -d \
        --name "$YACHT_NAME" \
        --restart unless-stopped \
        --network "$NETWORK_NAME" \
        -p "$YACHT_PORT":8000 \
        -v "$DOCKER_SOCKET":/var/run/docker.sock \
        -v "$CONFIG_VOLUME":/config \
	-e DISABLE_AUTH=true \
        -e "DOCKER_HOST=unix:///var/run/docker.sock" \
        --label "com.centurylinklabs.watchtower.enable=true" \
        "$YACHT_IMAGE"
    
    # Альтернативный вариант с host network (раскомментировать если нужно)
    # docker run -d \
    #     --name "$YACHT_NAME" \
    #     --restart unless-stopped \
    #     --network host \
    #     -v "$DOCKER_SOCKET":/var/run/docker.sock \
    #     -v "$CONFIG_VOLUME":/config \
    #     "$YACHT_IMAGE"
}

# Функция проверки статуса
check_status() {
    log_info "Проверяю статус контейнера..."
    sleep 5
    
    if docker ps | grep -q "$YACHT_NAME"; then
        CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$YACHT_NAME" 2>/dev/null || echo "host network")
        
        log_info "${GREEN}=============================================${NC}"
        log_info "${GREEN}Yacht успешно запущен!${NC}"
        log_info "Имя контейнера: $YACHT_NAME"
        log_info "Сеть: $NETWORK_NAME"
        log_info "IP адрес: $CONTAINER_IP"
        log_info "Порт: $YACHT_PORT"
        log_info "Доступ по адресу: http://localhost:$YACHT_PORT"
        log_info "Или: http://$(hostname -I | awk '{print $1}'):$YACHT_PORT"
        log_info "Пароль по умолчанию: pass"
        log_info "${GREEN}=============================================${NC}"
        
        # Проверка доступности
        if curl -s -o /dev/null -w "%{http_code}" http://localhost:$YACHT_PORT | grep -q "200\|401\|302"; then
            log_info "Сервис отвечает на порту $YACHT_PORT"
        else
            log_warn "Сервис не отвечает на порту $YACHT_PORT. Возможно, нужно подождать..."
        fi
        
        # Показать логи
        log_info "Последние 5 строк логов:"
        docker logs --tail 5 "$YACHT_NAME"
        
    else
        log_error "Контейнер не запущен. Просмотр логов..."
        docker logs "$YACHT_NAME" 2>/dev/null | tail -20
        exit 1
    fi
}

# Функция управления
case "$1" in
    "start")
        check_root
        check_docker
        create_network
        cleanup_old_container
        start_yacht
        check_status
        ;;
    "stop")
        check_root
        log_info "Останавливаю Yacht..."
        docker stop "$YACHT_NAME" 2>/dev/null && log_info "Yacht остановлен" || log_warn "Контейнер не найден"
        ;;
    "restart")
        check_root
        $0 stop
        sleep 2
        $0 start
        ;;
    "status")
        if docker ps | grep -q "$YACHT_NAME"; then
            CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$YACHT_NAME")
            log_info "Yacht запущен"
            log_info "IP: $CONTAINER_IP"
            log_info "Порт: $YACHT_PORT"
            log_info "Статус: $(docker inspect -f '{{.State.Status}}' "$YACHT_NAME")"
        else
            log_info "Yacht не запущен"
        fi
        ;;
    "logs")
        docker logs -f "$YACHT_NAME"
        ;;
    "update")
        check_root
        log_info "Обновляю образ Yacht..."
        docker pull "$YACHT_IMAGE"
        $0 restart
        ;;
    "reset")
        check_root
        log_warn "Полный сброс Yacht (остановка, удаление, очистка)"
        docker stop "$YACHT_NAME" 2>/dev/null || true
        docker rm "$YACHT_NAME" 2>/dev/null || true
        docker volume rm "$CONFIG_VOLUME" 2>/dev/null || true
        docker network rm "$NETWORK_NAME" 2>/dev/null || true
        log_info "Yacht полностью удален"
        ;;
    *)
        echo -e "${GREEN}Использование:${NC} $0 {start|stop|restart|status|logs|update|reset}"
        echo "  start   - запустить Yacht с исправленной сетью"
        echo "  stop    - остановить Yacht"
        echo "  restart - перезапустить Yacht"
        echo "  status  - показать статус"
        echo "  logs    - показать логи"
        echo "  update  - обновить образ и перезапустить"
        echo "  reset   - полный сброс (удаление всех данных)"
        exit 1
        ;;
esac
