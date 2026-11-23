import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.I3

// ==========================================================
// Оболочка Sway: панель на каждом мониторе + всплывающие окна.
// Запуск: qs -c shell   (конфиг ~/.config/quickshell/shell)
// Управление снаружи: qs ipc -c shell call shell <функция>
// ==========================================================
ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        delegate: Component {
            Bar {
                screen: modelData
            }
        }
    }

    // Панель фокусного монитора: по ней IPC открывает окна,
    // когда вызов пришёл с хоткея, а не с мыши.
    function barForIpc() {
        const bars = ShellState.bars
        if (bars.length === 0)
            return null

        const focused = I3.focusedMonitor ? I3.focusedMonitor.name : ""
        for (let i = 0; i < bars.length; i++) {
            if (bars[i].screen && bars[i].screen.name === focused)
                return bars[i]
        }
        return bars[0]
    }

    function showPopup(which) {
        const bar = root.barForIpc()
        if (bar)
            ShellState.show(which, bar)
    }

    IpcHandler {
        target: "shell"

        function toggle(): void {
            if (ShellState.open === "cc")
                ShellState.hide()
            else
                root.showPopup("cc")
        }

        function open(): void { root.showPopup("cc") }
        function close(): void { ShellState.hide() }

        function state(): string { return ShellState.open }

        function cc(): void { root.showPopup("cc") }
        function launcher(): void { root.showPopup("launcher") }
        function calendar(): void { root.showPopup("calendar") }
        function power(): void { root.showPopup("power") }

        function volumeUp(): void { Volume.step(5) }
        function volumeDown(): void { Volume.step(-5) }
        function mute(): void { Volume.toggleMute() }

        function brightnessUp(): void { Brightness.step(5) }
        function brightnessDown(): void { Brightness.step(-5) }
    }
}
