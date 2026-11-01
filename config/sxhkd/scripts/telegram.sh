#!/bin/bash
# ==========================================================
# telegram.sh — Запуск TG WS Proxy + Telegram (flatpak)
# ==========================================================

set -u

tg-ws-proxy &
sleep 1
exec flatpak run org.telegram.desktop