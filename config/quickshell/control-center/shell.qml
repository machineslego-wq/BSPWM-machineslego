// ==========================================================
// machineslego — Quickshell: точка входа
// ==========================================================
// Один процесс qs -c control-center держит все поверхности
// (модули). Сейчас это только Control Center; сюда же в будущем:
//
//   ControlCenter {}  — панель Wi-Fi/BT/батарея/яркость/питание
//   Panel {}          — панель, аналог waybar
//   Launcher {}       — лаунчер, аналог wofi
//
// Общие виджеты и тема — в components/ (Theme — синглтон).
// Каждый модуль — PanelWindow/ShellWindow со своим IPC-таргетом
// (у Control Center это `control-center`: toggle/open/close).
// ==========================================================

import Quickshell
import "modules"

ShellRoot {
    ControlCenter {}
}
