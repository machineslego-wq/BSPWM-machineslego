#!/bin/bash
# Универсальный скрипт замера температур (CPU, GPU, Hotspot, VRAM, NVMe)

SENSORS_OUT=$(sensors 2>/dev/null)
OUT=""

# 1. Определяем температуру CPU (AMD или Intel)
CPU_TEMP=$(echo "$SENSORS_OUT" | grep -E 'Tctl|Tdie|Package id 0' | awk '{print $2}' | head -n 1)
[ -n "$CPU_TEMP" ] && OUT+="󰻠  CPU:        $CPU_TEMP\n"

# 2. Определяем температуру GPU (Nvidia или AMD/Intel)
if command -v nvidia-smi &>/dev/null; then
    # === NVIDIA ===
    # Запрашиваем температуру чипа и памяти
    NVIDIA_INFO=$(nvidia-smi --query-gpu=temperature.gpu,temperature.memory --format=csv,noheader,nounits 2>/dev/null)
    if [ -n "$NVIDIA_INFO" ]; then
        GPU_TEMP=$(echo "$NVIDIA_INFO" | awk -F', ' '{print $1"°C"}')
        VRAM_TEMP=$(echo "$NVIDIA_INFO" | awk -F', ' '{print $2"°C"}')
        
        OUT+="󰢮  GPU:        $GPU_TEMP\n"
        # Проверяем, есть ли датчик памяти (у некоторых старых карт его нет, выдает [N/A])
        if [[ "$VRAM_TEMP" != *"N/A"* ]]; then
            OUT+="󰍛  VRAM:       $VRAM_TEMP\n"
        fi
    fi
else
    # === AMD / INTEL ===
    # Ищем блок amdgpu в выводе sensors
    if echo "$SENSORS_OUT" | grep -q "amdgpu"; then
        # Используем awk, чтобы вытащить значения именно из блока amdgpu
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
    else
        # Встроенная графика (Intel или AMD APU)
        INTEL_TEMP=$(echo "$SENSORS_OUT" | grep -E 'temp1' | awk '{print $2}' | head -n 1)
        [ -n "$INTEL_TEMP" ] && OUT+="󰢮  GPU:        $INTEL_TEMP\n"
    fi
fi

# 3. Определяем температуру NVMe (может быть несколько)
NVME_INFO=$(echo "$SENSORS_OUT" | awk '
    /^nvme/ { name=$1 }
    /Composite/ { print "  " name " : " $2 }
')
if [ -n "$NVME_INFO" ]; then
    OUT+="󰋊  NVMe:\n$NVME_INFO"
else
    OUT+="󰋊  NVMe:       N/A\n"
fi

# Защита от пустого вывода
if [ -z "$OUT" ]; then
    OUT="Нет доступных датчиков."
fi

# Выводим в Rofi
echo -e "$OUT" | rofi -dmenu -p "󰔏 Температуры" -theme-str 'window {width: 32%;} listview {lines: 7;}'