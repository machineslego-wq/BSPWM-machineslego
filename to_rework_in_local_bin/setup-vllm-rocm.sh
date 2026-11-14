#!/bin/bash
set -e

echo "=== Настройка vLLM с ROCm для RX 7700 XT ==="

# Генерация безопасного API ключа (если не задан)
VLLM_API_KEY="${VLLM_API_KEY:-$(openssl rand -hex 16)}"
echo "Сгенерирован API ключ для vLLM (сохраните его!)"
echo "VLLM_API_KEY=$VLLM_API_KEY"
echo ""

# Проверка GPU
echo "Проверка GPU:"
ls -la /dev/kfd /dev/dri/render* 2>/dev/null | head -5 || {
  echo "ОШИБКА: GPU не найден или нет доступа к /dev/kfd и /dev/dri"
  exit 1
}
echo ""

# Добавление в группу render (если не добавлен)
if ! id -nG | grep -q render; then
  echo "Добавление пользователя в группу render..."
  sudo usermod -aG render "$USER"
  echo "Вам потребуется перелогиниться для применения изменений."
  echo ""
fi

# Скачивание образа
echo "Скачивание образа vllm/vllm-openai-rocm:latest..."
docker pull vllm/vllm-openai-rocm:latest
echo ""

# Создание директории для моделей
MODELS_DIR="${HOME}/vllm-models"
mkdir -p "$MODELS_DIR"
echo "Создана директория для моделей: $MODELS_DIR"
echo ""

# Проверка наличия контейнера
if docker ps -a --format '{{.Names}}' | grep -qx vllm-backend; then
  echo "Остановка старого контейнера vllm-backend..."
  docker stop vllm-backend 2>/dev/null || true
  docker rm vllm-backend 2>/dev/null || true
fi

# Запуск контейнера
echo "Запуск vLLM контейнера..."
docker run -d --name vllm-backend \
  --device=/dev/kfd \
  --device=/dev/dri \
  --group-add=video \
  --ipc=host \
  --cap-add=SYS_PTRACE \
  --security-opt seccomp=unconfined \
  -p 8000:8000 \
  -v "$MODELS_DIR":/models \
  -e HSA_OVERRIDE_GFX_VERSION=11.0.0 \
  -e VLLM_ALLOW_LONG_MAX_MODEL_LEN=1 \
  vllm/vllm-openai-rocm:latest \
  --model /models/Qwen2.5-7B-Instruct-AWQ \
  --quantization awq \
  --max-model-len 32768 \
  --api-key "$VLLM_API_KEY"

echo ""
echo "Ожидание старта контейнера..."
sleep 5

# Проверка логов
echo "Логи контейнера (первые строки):"
docker logs vllm-backend 2>&1 | tail -20
echo ""

# Проверка API
echo "Проверка API vLLM..."
if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8000/v1/models -H "Authorization: Bearer $VLLM_API_KEY" | grep -q "200"; then
  echo "✓ vLLM API доступен"
  echo "Доступные модели:"
  curl -s http://127.0.0.1:8000/v1/models -H "Authorization: Bearer $VLLM_API_KEY" | python3 -c "import sys,json; d=json.load(sys.stdin); [print(f'  - {m.get(\"id\",\"unknown\")}') for m in d.get('data',[])]"
else
  echo "⚠ Проверьте логи: docker logs vllm-backend"
fi
echo ""

# Сохранение ключа в переменные окружения сессии
echo "Export key for this session:"
echo "export VLLM_API_KEY=\"$VLLM_API_KEY\""
echo ""

echo "=== Готово! ==="
echo "Ключ API сохраните. Добавьте в ~/.bashrc или ~/.zshrc для постоянства:"
echo "  export VLLM_API_KEY=\"$VLLM_API_KEY\""
echo ""
echo "Для настройки OpenCode CLI используйте этот ключ в opencode.json."
