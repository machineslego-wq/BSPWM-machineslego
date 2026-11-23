pragma Singleton

// ==========================================================
// Раскладка и Caps Lock для панели.
// В Quickshell нет сервиса ввода, а libevdev ради
// keyboard-state тянуть не хочется: раскладку отдаёт
// `swaymsg -t get_inputs`, Caps Lock — светодиод клавиатуры
// в /sys/class/leds. Оба ответа приходят одной командой,
// опрос раз в 2 с.
// ==========================================================

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: svc

    property string layout: "US"
    property bool caps: false

    function parse(text) {
        const split = text.split("---LEDS---")
        if (split.length < 2)
            return

        try {
            const inputs = JSON.parse(split[0].trim())
            for (let i = 0; i < inputs.length; i++) {
                const input = inputs[i]
                if (!input.xkb_active_layout_name)
                    continue
                svc.layout = shortLayout(input.xkb_active_layout_name, input.xkb_layout_names)
                break
            }
        } catch (e) {
            // swaymsg мог не ответить в момент reload — оставляем прошлое значение
        }

        svc.caps = split[1].replace(/\s/g, "").indexOf("1") !== -1
    }

    function shortLayout(active, names) {
        const match = active.match(/\(([A-Za-z]{2,3})\)/)
        if (match)
            return match[1].toUpperCase()
        const known = {
            "russian": "RU", "english": "US", "german": "DE",
            "french": "FR", "ukrainian": "UA", "polish": "PL"
        }
        const lower = active.toLowerCase()
        for (const key in known) {
            if (lower.indexOf(key) === 0)
                return known[key]
        }
        const list = names || []
        const index = list.indexOf(active)
        return index >= 0 && list[index].length >= 2
            ? list[index].substring(0, 2).toUpperCase()
            : active.substring(0, 2).toUpperCase()
    }

    Process {
        id: probe
        command: ["sh", "-c",
            "swaymsg -t get_inputs --raw; printf '\\n---LEDS---\\n'; " +
            "cat /sys/class/leds/input*::capslock/brightness 2>/dev/null"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: svc.parse(this.text)
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: if (!probe.running) probe.running = true
    }
}
