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
    
    # Заставляем awk использовать точку (C-локаль), чтобы 0.50 не превращалось в 0
    VOL=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | LC_ALL=C awk '{print int($2 * 100)}')
    [ -z "$VOL" ] && VOL=0
    
    MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o "MUTED")
else
    # --- PulseAudio (фолбэк) ---
    case "$ACTION" in
        up)   pactl set-sink-volume @DEFAULT_SINK@ +5% ;;
        down) pactl set-sink-volume @DEFAULT_SINK@ -5% ;;
        mute) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
    esac
    
    VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | head -n 1 | tr -d '%')
    [ -z "$VOL" ] && VOL=0
    MUTED=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
fi

# --- Выбор цвета и текста в зависимости от громкости ---
if [ -n "$MUTED" ]; then
    FRAME_COLOR="#565f89"
    HIGHLIGHT_COLOR="#565f89"
    MSG="Звук выключен"
    ICON="audio-volume-muted"
elif [ "$VOL" -gt 100 ]; then
    FRAME_COLOR="#ff0000"
    HIGHLIGHT_COLOR="#ff0000"
    MSG="Громкость: ${VOL}% (Максимум!)"
    ICON="audio-volume-high"
elif [ "$VOL" -gt 80 ]; then
    FRAME_COLOR="#f7768e"
    HIGHLIGHT_COLOR="#f7768e"
    MSG="Громкость: ${VOL}%"
    ICON="audio-volume-high"
elif [ "$VOL" -gt 50 ]; then
    FRAME_COLOR="#e0af68"
    HIGHLIGHT_COLOR="#e0af68"
    MSG="Громкость: ${VOL}%"
    ICON="audio-volume-medium"
else
    FRAME_COLOR="#7aa2f7"
    HIGHLIGHT_COLOR="#7aa2f7"
    MSG="Громкость: ${VOL}%"
    ICON="audio-volume-low"
fi

# --- Отправка уведомления ---
notify-send -h string:x-canonical-private-synchronous:volume \
            -h int:value:"${VOL}" \
            -h string:frcolor:"${FRAME_COLOR}" \
            -h string:hlcolor:"${HIGHLIGHT_COLOR}" \
            -a "Volume" -i "$ICON" -t 1500 \
            "$MSG"