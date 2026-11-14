#!/bin/bash
set -e

echo "==== Стартуем Ollama (GPU, ROCm в Docker) ===="

# Если контейнер уже запущен — проверим, что в нём актуальные env.
# Если нет — пересоздадим (иначе новые переменные не применятся).
if [ "$(docker ps -q -f name=^ollama$)" ]; then
    CURRENT_CTX=$(docker exec ollama printenv OLLAMA_CONTEXT_LENGTH 2>/dev/null || echo "")
    if [ "$CURRENT_CTX" = "4096" ]; then
        echo "Ollama уже запущен с актуальными настройками."
    else
        echo "Ollama запущен, но без нужных env — пересоздаём..."
        docker rm -f ollama
    fi
fi

# Если контейнер существует, но остановлен — тоже пересоздадим,
# чтобы гарантированно применить env.
if [ -z "$(docker ps -q -f name=^ollama$)" ] && [ "$(docker ps -aq -f name=^ollama$)" ]; then
    echo "Старый контейнер Ollama существует, но без нужных env — пересоздаём..."
    docker rm -f ollama
fi

if [ -z "$(docker ps -aq -f name=^ollama$)" ]; then
    echo "Создаём и запускаем новый контейнер Ollama..."
    docker run -d \
      --name ollama \
      --device=/dev/kfd \
      --device=/dev/dri \
      --group-add video \
      -v /home/nikita/ollama:/root/.ollama \
      -p 11434:11434 \
      --restart no \
      -e OLLAMA_CONTEXT_LENGTH=20000 \
      -e OLLAMA_NUM_PARALLEL=1 \
      -e OLLAMA_MAX_LOADED_MODELS=1 \
      -e OLLAMA_KEEP_ALIVE=5m \
      ollama/ollama:rocm
fi

echo "==== Стартуем OpenWebUI ===="

if [ "$(docker ps -q -f name=^openwebui$)" ]; then
    echo "OpenWebUI уже запущен."
elif [ "$(docker ps -aq -f name=^openwebui$)" ]; then
    echo "Старый контейнер OpenWebUI существует, запускаем..."
    docker start openwebui
else
    echo "Создаём и запускаем новый контейнер OpenWebUI..."
    docker run -d \
	  --name openwebui \
	  --network host \
	  -v /home/nikita/openwebui/data:/app/backend/data \
	  -e USE_OLLAMA=false \
	  -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
	  -e AIOHTTP_CLIENT_TIMEOUT=1800 \
	  --restart no \
	  openwebui/open-webui:ollama
fi

echo "==== Всё готово ===="
echo "OpenWebUI: http://localhost:8080"
echo "Ollama API: http://localhost:11434"
echo
echo "Проверка после первого запроса к модели:"
echo "  docker exec ollama ollama ps   # должно быть 100% GPU"
