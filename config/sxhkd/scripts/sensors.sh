#!/bin/bash
# ==========================================================
# sensors.sh — Умный замер температур
# ==========================================================
# Собирает данные с датчиков (sensors, nvidia-smi) и выводит 
# их в Rofi. Отсутствующие датчики скрываются, чтобы не 
# показывать пустые строки (актуально для ПК и разных ноутов).
# ==========================================================

SENSORS_OUT=$(sensors 2>/dev/null)
OUT=""

# ---------------------------------------------------------
# 1. Процессор (Intel или AMD)
# ---------------------------------------------------------
# Ищем строку с пакетом/ядром, затем вытаскиваем первое 
# совпадение вида "+45.0°C" через grep -oE.
CPU_TEMP=$(echo "$SENSORS_OUT" | grep -E 'Package id 0|Tctl|Tdie|Core 0' | grep -oE '\+[0-9.]+°C' | head -n 1)

# Если не нашли (например, виртуалка или старый ПК), ищем acpitz
if [ -z "$CPU_TEMP" ]; then
    CPU_TEMP=$(echo "$SENSORS_OUT" | grep -A 1 'acpitz' | grep -oE '\+[0-9.]+°C' | head -n 1)
fi

if [ -n "$CPU_TEMP" ]; then
    OUT+="󰻠  CPU:        $CPU_TEMP\n"
fi

# ---------------------------------------------------------
# 2. Видеокарта (Nvidia, AMD или Intel)
# ---------------------------------------------------------
if command -v nvidia-smi &>/dev/null; then
    # --- Nvidia ---
    # Запрашиваем температуру чипа и памяти в формате CSV без заголовков.
    NVIDIA_INFO=$(nvidia-smi --query-gpu=temperature.gpu,temperature.memory --format=csv,noheader,nounits 2>/dev/null)
    if [ -n "$NVIDIA_INFO" ]; then
        GPU_TEMP=$(echo "$NVIDIA_INFO" | awk -F', ' '{print $1"°C"}')
        VRAM_TEMP=$(echo "$NVIDIA_INFO" | awk -F', ' '{print $2"°C"}')
        OUT+="󰢮  GPU:        $GPU_TEMP\n"
        # Память может быть недоступна (N/A) на некоторых картах
        if [[ "$VRAM_TEMP" != *"N/A"* ]]; then
            OUT+="󰍛  VRAM:       $VRAM_TEMP\n"
        fi
    fi
else
    # --- AMD или Intel (через sensors) ---
    if echo "$SENSORS_OUT" | grep -q "amdgpu"; then
        # Дискретная AMD: парсим блок amdgpu через awk, 
        # вытаскивая edge (чип), junction (hotspot) и mem (память).
        AMD_DATA=$(echo "$SENSORS_OUT" | awk '
            /^amdgpu/ { in_gpu=1 }
            /^$/ { in_gpu=0 }
            in_gpu && /edge/ { print "edge:" $2 }
            in_gpu && /junction/ { print "junction:" $2 }
            in_gpu && /mem/ { print "mem:" $2 }
        ')
        AMD_EDGE=$(echo "$AMD_DATA" | grep "edge:" | cut -d: -f2)
        AMD_JUNC=$(echo "$AMD_DATA" | grep "junction:" | cut -d: -f2)
        AMD_MEM=$(echo "$AMD_DATA" | grep "mem:" | cut -d: -f2)

        [ -n "$AMD_EDGE" ] && OUT+="󰢮  GPU:        $AMD_EDGE\n"
        [ -n "$AMD_JUNC" ] && OUT+="󰔏  Hotspot:    $AMD_JUNC\n"
        [ -n "$AMD_MEM" ] && OUT+="󰍛  VRAM:       $AMD_MEM\n"
    fi
    # Для Intel iGPU НЕ выводим строку, так как у него нет 
    # отдельного датчика в sensors (он показывает температуру CPU).
fi

# ---------------------------------------------------------
# 3. Диски (NVMe или SATA с модулем drivetemp)
# ---------------------------------------------------------
# NVMe: ищем блок nvme и забираем строку Composite.
NVME_INFO=$(echo "$SENSORS_OUT" | awk '
    /^nvme/ { name=$1 }
    /Composite/ { print "  " name " : " $2 }
')
# SATA: ищем блок drivetemp и забираем temp1.
SATA_INFO=$(echo "$SENSORS_OUT" | awk '
    /^drivetemp/ { name=$1 }
    /temp1/ { print "  " name " : " $2 }
')

if [ -n "$NVME_INFO" ] || [ -n "$SATA_INFO" ]; then
    OUT+="󰋊  Диски:\n"
    [ -n "$NVME_INFO" ] && OUT+="$NVME_INFO"
    [ -n "$SATA_INFO" ] && OUT+="$SATA_INFO"
fi

# ---------------------------------------------------------
# 4. Фолбэк (если вообще ничего не нашли)
# ---------------------------------------------------------
if [ -z "$OUT" ]; then
    OUT="Нет доступных датчиков.\nПопробуйте: sudo sensors-detect"
fi

# ---------------------------------------------------------
# 5. Вывод в Rofi
# ---------------------------------------------------------
echo -e "$OUT" | rofi -dmenu -p "󰔏 Температуры" -theme-str 'window {width: 28%;} listview {lines: 6;}'