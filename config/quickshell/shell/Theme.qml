pragma Singleton

// ==========================================================
// Палитра и метрики — Tokyo Night.
// Значения те же, что в config/waybar/style.css и
// config/polybar/config.ini, чтобы панель не выбивалась из темы.
// ==========================================================

import QtQuick
import Quickshell

Singleton {
    readonly property color bg: "#1a1b26"
    readonly property color bgMid: "#16161e"
    readonly property color surface: "#292e42"
    readonly property color surfaceHigh: "#3b4261"
    readonly property color fg: "#c0caf5"
    readonly property color fgDim: "#a9b1d6"
    readonly property color muted: "#565f89"
    readonly property color accent: "#7aa2f7"
    readonly property color secondary: "#bb9af7"
    readonly property color success: "#9ece6a"
    readonly property color warning: "#e0af68"
    readonly property color error: "#f7768e"

    readonly property string font: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property int smallSize: 11
    readonly property int barHeight: 32
    readonly property int radius: 5
    readonly property int popupRadius: 6
    readonly property int popupWidth: 400
}
