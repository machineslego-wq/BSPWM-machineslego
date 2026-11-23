pragma Singleton

// ==========================================================
// Яркость: в Quickshell 0.3 своего сервиса нет, поэтому
// brightnessctl через Quickshell.Io (не bash-скрипт).
// -m печатает "device,class,current,percent,max".
// ==========================================================

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: svc

    property bool available: false
    property string device: ""
    property int percent: 0

    function refresh() {
        if (!read.running)
            read.running = true
    }

    function setPercent(p) {
        if (!available)
            return
        const value = Math.max(1, Math.min(100, Math.round(p)))
        percent = value
        setter.command = ["brightnessctl", "set", value + "%"]
        setter.running = true
    }

    function step(delta) {
        setPercent(percent + delta)
    }

    Process {
        id: read
        command: ["brightnessctl", "-m"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(",")
                const current = Number(parts[2])
                const max = Number(parts[4])
                if (parts.length >= 5 && max > 0 && !isNaN(current)) {
                    svc.device = parts[0]
                    svc.percent = Math.round(current * 100 / max)
                    svc.available = true
                } else {
                    svc.available = false
                }
            }
        }

        onExited: (code) => {
            if (code !== 0)
                svc.available = false
        }
    }

    Process {
        id: setter
        command: ["brightnessctl", "set", "50%"]
        running: false

        onExited: (code) => {
            if (code === 0)
                svc.refresh()
        }
    }

    // Опрос раз в 5 с: hotkey или другой процесс могут изменить
    // яркость мимо панели.
    Timer {
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: svc.refresh()
    }
}
