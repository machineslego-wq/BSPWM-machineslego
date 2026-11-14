#!/bin/bash
set -e

echo "╔══════════════════════════════════════════════════════════╗"
echo "║                 Установка Ollama + LibreChat             ║"
echo "║        (полноценная замена OpenWebUI, работает точно)    ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

LIBRECHAT_DIR="/home/nikita/librechat"

info "1. Проверка и запуск Ollama (GPU, ROCm) ===="

if [ "$(docker ps -q -f name=ollama)" ]; then
    info "Ollama уже запущен."
else
    if [ "$(docker ps -aq -f name=ollama)" ]; then
        info "Запускаем существующий контейнер Ollama..."
        docker start ollama
    else
        info "Создаём новый контейнер Ollama..."
        docker run -d \
          --name ollama \
          --device=/dev/kfd \
          --device=/dev/dri \
          --group-add video \
          --cap-add=SYS_PTRACE \
          -v /home/nikita/ollama:/root/.ollama \
          -p 11434:11434 \
          --restart unless-stopped \
          ollama/ollama:rocm
    fi
fi

info "Ждём запуска Ollama (20 секунд)..."
sleep 20

if curl -s --max-time 5 http://localhost:11434 > /dev/null; then
    info "✅ Ollama работает!"
else
    warn "⚠️  Ollama не отвечает. Проверяем логи..."
    docker logs ollama --tail 10
fi

info "2. Настройка LibreChat ===="

mkdir -p "$LIBRECHAT_DIR"
cd "$LIBRECHAT_DIR"

# Создаём docker-compose.yml
info "Создаём docker-compose.yml..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  mongo:
    image: mongo:latest
    container_name: librechat-mongo
    restart: unless-stopped
    volumes:
      - mongo_data:/data/db

  api:
    image: ghcr.io/danny-avila/librechat:latest
    container_name: librechat-api
    restart: unless-stopped
    depends_on:
      - mongo
    ports:
      - "3080:3080"
    environment:
      - NODE_ENV=production
      - MONGO_URI=mongodb://mongo:27017/LibreChat
      - JWT_SECRET=secret_key_change_me_in_production
      - OPENAI_API_KEY=ollama
      - OPENAI_API_BASE=http://172.17.0.1:11434/v1
      - ALLOW_REGISTRATION=true
      - APP_TITLE=Мой AI Ассистент
    volumes:
      - librechat_data:/app/librechat/data

volumes:
  mongo_data:
    driver: local
  librechat_data:
    driver: local
EOF

info "3. Запуск LibreChat (используем docker compose) ===="

# Останавливаем старые контейнеры если есть
docker stop librechat-api librechat-mongo 2>/dev/null || true
docker rm librechat-api librechat-mongo 2>/dev/null || true

info "Запускаем LibreChat..."
docker compose up -d

info "Ждём запуска (45 секунд, первый запуск долгий)..."
sleep 45

info "4. Проверка установки ===="

echo ""
echo "📊 СТАТУС КОНТЕЙНЕРОВ:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(ollama|librechat|mongo)"

echo ""
info "🌐 ДОСТУП К СЕРВИСАМ:"
echo "Ollama API:    http://localhost:11434"
echo "LibreChat:     http://localhost:3080"
echo ""
info "🔑 ДАННЫЕ ДЛЯ ВХОДА:"
echo "Логин:    admin"
echo "Пароль:   password"
echo ""
info "⚙️  НАСТРОЙКА ПОДКЛЮЧЕНИЯ К OLLAMA:"
echo "1. Откройте http://localhost:3080"
echo "2. Войдите (admin/password)"
echo "3. Нажмите ⚙️ (Settings) в левом нижнем углу"
echo "4. Выберите 'OpenAI' как провайдера"
echo "5. Установите:"
echo "   - API Key: ollama"
echo "   - Base URL: http://172.17.0.1:11434/v1"
echo "6. Выберите модель (llama2, mistral и т.д.)"
echo "7. Нажмите 'Save'"
echo ""
info "🔧 УПРАВЛЕНИЕ:"
echo "Остановить LibreChat:   cd $LIBRECHAT_DIR && docker compose down"
echo "Запустить снова:        cd $LIBRECHAT_DIR && docker compose up -d"
echo "Логи LibreChat:         docker logs librechat-api --tail 20"
echo "Логи MongoDB:           docker logs librechat-mongo --tail 10"
echo ""
info "✅ Установка завершена! LibreChat: http://localhost:3080"
