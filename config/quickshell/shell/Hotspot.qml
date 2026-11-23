pragma Singleton

// ==========================================================
// Точка доступа NetworkManager.
// Профиль "Hotspot" создаёт local/bin/wifi (nmcli device wifi
// hotspot), здесь — только включение/выключение готового профиля,
// а если его нет, создаём тем же SSID и паролем, что и скрипт.
// Включение AP на большинстве карт отключает текущий Wi-Fi:
// в интерфейсе об этом есть предупреждение.
// ==========================================================

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: svc

    readonly property string ssid: "BSPWM-Hotspot"
    readonly property string password: "i-use-debian-btw"

    property bool active: false
    property bool busy: false
    property bool watching: false
    property string lastError: ""

    function refresh() {
        if (!state.running)
            state.running = true
    }

    function toggle() {
        if (busy)
            return

        busy = true
        lastError = ""

        if (active) {
            action.command = ["nmcli", "connection", "down", "Hotspot"]
        } else {
            action.command = ["sh", "-c",
                "if nmcli -t -f NAME connection show | grep -qx Hotspot; then "
                + "nmcli connection up Hotspot; else "
                + "nmcli device wifi hotspot ssid '" + svc.ssid + "' password '" + svc.password + "'; fi"]
        }
        action.running = true
    }

    Process {
        id: state
        command: ["sh", "-c",
            "nmcli -t -f NAME,TYPE connection show --active 2>/dev/null "
            + "| grep -qx 'Hotspot:802-11-wireless' && echo on || echo off"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: svc.active = this.text.trim() === "on"
        }
    }

    Process {
        id: action
        command: ["nmcli", "connection", "up", "Hotspot"]
        running: false

        stderr: StdioCollector {
            id: actionError
        }

        onExited: (code) => {
            svc.busy = false
            if (code !== 0)
                svc.lastError = actionError.text.trim()
            svc.refresh()
        }
    }

    // Опрос только пока открыт центр управления: вне его
    // состояние точки доступа нигде не показывается.
    Timer {
        interval: 5000
        repeat: true
        running: svc.watching
        triggeredOnStart: true
        onTriggered: svc.refresh()
    }
}
