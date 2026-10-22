#!/bin/bash
# ==========================================================
# volume.sh — Управление громкостью с OSD (Dunst)
# ==========================================================

ACTION="$1"

if pgrep -x pipewire >/dev/null; then
    # --- PipeWire ---
    case "$ACTION" in
        up)   wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ ;;
        down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
        mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    esac
    
    # Берем 2-ю колонку (0.50), убираем точку (050), убираем ведущие нули (50)
    VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | cut -d' ' -f2 | tr -d '.' | sed 's/^0*//')
    # Если громкость 0.00, то получится пустая строка. Приравниваем к 0.
    [ -z "$VOL" ] && VOL=0
    MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o "MUTED")
else
    # --- PulseAudio ---
    case "$ACTION" in
        up)   pactl set-sink-volume @DEFAULT_SINK@ +5% ;;
        down) pactl set-sink-volume @DEFAULT_SINK@ -5% ;;
        mute) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
    esac
    
    # Просто ищем первое число перед знаком % (работает везде)
    VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -n 1)
    MUTED=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -o "yes")
fi

# --- Отправка уведомления в Dunst ---
if [ -n "$MUTED" ]; then
    notify-send -h string:x-canonical-private-synchronous:volume \
                -a "Volume" -i audio-volume-muted -t 1500 \
                "Звук выключен"
else
    notify-send -h string:x-canonical-private-synchronous:volume \
                -h int:value:"${VOL}" \
                -a "Volume" -i audio-volume-high -t 1500 \
                "Громкость: ${VOL}%"
fi