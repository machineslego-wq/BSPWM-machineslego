#!/bin/bash
set -e

echo "==== 1. Запуск Ollama (GPU, ROCm в Docker) ===="

# Удаляем старый контейнер, чтобы применить новые настройки
if [ "$(docker ps -aq -f name=^ollama$)" ]; then
    echo "Удаляем старый контейнер Ollama..."
    docker rm -f ollama > /dev/null
fi

echo "Создаем и запускаем новый контейнер Ollama с оптимизацией для AMD..."
docker run -d \
  --name ollama \
  --device=/dev/kfd \
  --device=/dev/dri \
  --group-add video \
  --security-opt seccomp=unconfined \
  -v /home/nikita/ollama_models:/root/.ollama \
  -p 11434:11434 \
  --restart unless-stopped \
  -e HSA_OVERRIDE_GFX_VERSION=11.0.0 \
  -e OLLAMA_FLASH_ATTENTION=1 \
  -e OLLAMA_CONTEXT_LENGTH=32768 \
  -e OLLAMA_NUM_PARALLEL=1 \
  -e OLLAMA_MAX_LOADED_MODELS=1 \
  -e OLLAMA_KEEP_ALIVE=-1 \
  ollama/ollama:rocm

echo "Ждем инициализации Ollama (5 секунд)..."
sleep 5

echo "==== 2. Скачивание моделей Qwen 3.5 ===="
echo "Скачиваем 9B (основная для кода)..."
docker exec -it ollama ollama pull qwen3.5:9b

echo "Скачиваем 4B (быстрая, для легких задач)..."
docker exec -it ollama ollama pull qwen3.5:4b

echo "==== 3. Запуск OpenWebUI ===="
# Останавливаем и удаляем старый, если есть
if [ "$(docker ps -aq -f name=^openwebui$)" ]; then
    echo "Удаляем старый контейнер OpenWebUI..."
    docker rm -f openwebui > /dev/null
fi

echo "Создаем и запускаем новый контейнер OpenWebUI..."
docker run -d \
  --name openwebui \
  --network host \
  -v /home/nikita/openwebui/data:/app/backend/data \
  -e USE_OLLAMA=false \
  -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
  -e AIOHTTP_CLIENT_TIMEOUT=1800 \
  --restart unless-stopped \
  openwebui/open-webui:latest

echo "==== Всё готово! ===="
echo "OpenWebUI (чат): http://localhost:8080"
echo "Ollama API (для OpenCode): http://localhost:11434/v1"
echo
echo "Проверка загрузки GPU (после первого запроса):"
echo "  docker exec ollama ollama ps"