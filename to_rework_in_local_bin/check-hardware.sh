#!/bin/bash
echo "=== Системная диагностика ==="
echo "1. Ядро: $(uname -r)"
echo "2. Mesa: $(apt policy mesa-vulkan-drivers 2>/dev/null | grep Установлен | awk '{print $2}')"
echo "3. CPU: $(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2)"
echo "4. GPU: $(lspci | grep -i "vga\|display" | cut -d: -f3-)"
echo "5. AMD драйвер: $(modinfo amdgpu 2>/dev/null | grep "version:" | head -1)"
echo "6. Загрузка: $(ls -la /boot/vmlinuz-* | tail -1)"
