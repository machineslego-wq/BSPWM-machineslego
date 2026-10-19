#!/bin/bash
# ==========================================================
# volume.sh — Управление громкостью
# ==========================================================
# Принимает аргумент: up, down, mute.
# Автоматически определяет звуковой сервер (PipeWire или 
# PulseAudio) и использует соответствующую команду.
#
# Пример вызова:
#   volume.sh up
#   volume.sh down
#   volume.sh mute
# ==========================================================

ACTION="$1"

if pgrep -x pipewire >/dev/null; then
    # Если запущен PipeWire
    case "$ACTION" in
        up)   wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ ;;
        down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
        mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    esac
else
    # Если запущен PulseAudio
    case "$ACTION" in
        up)   pactl set-sink-volume @DEFAULT_SINK@ +5% ;;
        down) pactl set-sink-volume @DEFAULT_SINK@ -5% ;;
        mute) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
    esac
fi