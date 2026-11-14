#!/bin/bash
set -e

COMFYUI_DIR="/home/nikita/comfyui"
CONTAINER_NAME="comfyui"
IMAGE="rocm/pytorch:rocm7.1_ubuntu22.04_py3.10_pytorch_release_2.8.0"
MANAGER_DIR="$COMFYUI_DIR/custom_nodes/comfyui-manager"
MANAGER_REPO="https://github.com/ltdrdata/ComfyUI-Manager"
MANAGER_IN_CONTAINER="/workspace/comfyui/custom_nodes/comfyui-manager"

# -------- helper: y/n --------
confirm() {
    local prompt="$1"
    local answer
    read -r -p "$prompt [y/N]: " answer
    case "$answer" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

# -------- helper: run only after confirm --------
run_if_confirmed() {
    local prompt="$1"; shift
    if confirm "$prompt"; then
        echo ">>> Выполняю: $*"
        "$@"
    else
        echo ">>> Пропущено: $*"
    fi
}

# -------- 1. ComfyUI --------
mkdir -p "$COMFYUI_DIR"

if [ -z "$(ls -A "$COMFYUI_DIR" 2>/dev/null)" ]; then
    echo "Папка ComfyUI пуста."
    if confirm "Скачать ComfyUI ($COMFYUI_DIR)?"; then
        git clone https://github.com/comfyanonymous/ComfyUI.git "$COMFYUI_DIR"
    else
        echo "Без ComfyUI дальше нет смысла. Выход."
        exit 1
    fi
else
    echo "ComfyUI уже существует, пропускаем загрузку."
fi

# -------- 2. Контейнер --------
CONTAINER_EXISTS=false
if [ "$(docker ps -aq -f name=^/${CONTAINER_NAME}$)" ]; then
    CONTAINER_EXISTS=true
    echo "Контейнер $CONTAINER_NAME уже существует."
    if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
        echo "Контейнер уже запущен."
    else
        echo "Запускаем контейнер $CONTAINER_NAME..."
        docker start "$CONTAINER_NAME"
    fi
else
    echo "Создаём новый контейнер $CONTAINER_NAME..."
    docker run -d --name "$CONTAINER_NAME" \
        --device=/dev/kfd \
        --device=/dev/dri \
        --group-add video \
        -v "$COMFYUI_DIR":/workspace/comfyui \
        -p 8188:8188 \
        "$IMAGE" \
        tail -f /dev/null

    echo "Устанавливаем базовые зависимости ComfyUI..."
    docker exec "$CONTAINER_NAME" bash -c "
        cd /workspace/comfyui && \
        python3 -m pip install --upgrade pip && \
        pip install -r requirements.txt safetensors
    "
fi

# -------- 3. ComfyUI-Manager: наличие --------
echo
echo "===== Проверка ComfyUI-Manager ====="

if [ ! -d "$MANAGER_DIR" ]; then
    echo "Папка менеджера отсутствует: $MANAGER_DIR"
    if confirm "Склонировать ComfyUI-Manager в custom_nodes?"; then
        git clone "$MANAGER_REPO" "$MANAGER_DIR"
    else
        echo "Пропускаем установку менеджера."
    fi
else
    echo "Папка менеджера найдена: $MANAGER_DIR"
fi

# -------- 4. ComfyUI-Manager: целостность --------
if [ -d "$MANAGER_DIR" ]; then
    echo
    echo "--- Проверка целостности ---"

    # .git
    if [ ! -d "$MANAGER_DIR/.git" ]; then
        echo "ВНИМАНИЕ: нет папки .git — менеджер не сможет обновляться и ставить ноды."
        if confirm "Переклонировать менеджер начисто?"; then
            rm -rf "$MANAGER_DIR"
            git clone "$MANAGER_REPO" "$MANAGER_DIR"
        fi
    else
        echo ".git — OK"
    fi

    # __init__.py
    if [ ! -f "$MANAGER_DIR/__init__.py" ]; then
        echo "ВНИМАНИЕ: нет __init__.py — ComfyUI не увидит менеджер."
        if confirm "Переклонировать менеджер начисто?"; then
            rm -rf "$MANAGER_DIR"
            git clone "$MANAGER_REPO" "$MANAGER_DIR"
        fi
    else
        echo "__init__.py — OK"
    fi

    # requirements.txt
    if [ -f "$MANAGER_DIR/requirements.txt" ]; then
        echo "requirements.txt — найден"
        if confirm "Установить зависимости менеджера из requirements.txt?"; then
            docker exec "$CONTAINER_NAME" pip install -r "$MANAGER_IN_CONTAINER/requirements.txt"
        fi
    else
        echo "requirements.txt — отсутствует (это нормально для новых версий менеджера)"
    fi

    # GitPython — обязательная зависимость в любом случае
    if confirm "Установить/обновить GitPython в контейнере?"; then
        docker exec "$CONTAINER_NAME" pip install --upgrade GitPython
    fi
fi

# -------- 5. Проверка флага --enable-manager --------
echo
echo "--- Проверка поддержки флага --enable-manager ---"
ENABLE_MANAGER_FLAG=""
if docker exec "$CONTAINER_NAME" bash -c "cd /workspace/comfyui && python3 main.py --help 2>&1 | grep -q -- '--enable-manager'"; then
    echo "Флаг --enable-manager поддерживается — добавляю в запуск."
    ENABLE_MANAGER_FLAG="--enable-manager"
else
    echo "Флаг --enable-manager НЕ поддерживается этой версией ComfyUI — запускаю без него."
fi

# -------- 6. Запуск ComfyUI --------
echo
if confirm "Запустить ComfyUI сейчас?"; then
    # Останавливаем возможный старый процесс внутри контейнера
    docker exec "$CONTAINER_NAME" bash -c "pkill -f 'python3 main.py' || true" || true
    sleep 1

    echo "Запуск ComfyUI ${ENABLE_MANAGER_FLAG:+с флагом --enable-manager}..."
    docker exec -d "$CONTAINER_NAME" bash -c "cd /workspace/comfyui && python3 main.py --listen 0.0.0.0 $ENABLE_MANAGER_FLAG"
    sleep 3

    echo
    echo "ComfyUI должен быть доступен по адресу: http://localhost:8188"
    echo
    echo "Последние логи, связанные с менеджером:"
    docker logs --tail 200 "$CONTAINER_NAME" 2>&1 | grep -i -E "manager|error|traceback" | tail -20 || true
else
    echo "Запуск отменён."
fi

echo "Готово."
