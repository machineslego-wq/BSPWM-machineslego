// ==========================================================
// machineslego — общая тема (палитра + шрифт) для всех модулей
// ==========================================================
// Синглтон: цвет/шрифт берутся отсюда и в control center, и в
// будущих модулях (панель как waybar, лаунчер как wofi).
// Имена цветов те же, что в @define-color в waybar/style.css
// и в config/polybar/config.ini.
// ==========================================================
pragma Singleton
import QtQuick

QtObject {
    // --- Tokyo Night palette ---
    readonly property color bg: "#1a1b26"
    readonly property color surface: "#24283b"
    readonly property color fg: "#a9b1d6"
    readonly property color accent: "#7aa2f7"
    readonly property color error: "#f7768e"
    readonly property color success: "#9ece6a"
    readonly property color muted: "#565f89"

    // --- Шрифт ---
    readonly property string mono: "JetBrainsMono Nerd Font"
}
