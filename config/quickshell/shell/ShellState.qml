pragma Singleton

// ==========================================================
// Какое всплывающее окно открыто и к какой панели оно привязано.
// Всплывающие окна живут внутри каждой панели, поэтому
// ссылка на панель нужна, чтобы открылось только одно — на том
// мониторе, где был клик.
//
// bars — все живые панели (по одной на монитор): по ним IPC
// выбирает панель фокусного монитора, когда окно открывают
// не мышью, а хоткеем.
// ==========================================================

import QtQuick
import Quickshell

Singleton {
    // "", "cc", "launcher", "power", "calendar"
    property string open: ""
    property var bar: null
    property var bars: []

    function show(which, barRef) {
        if (open === which && bar === barRef) {
            hide()
            return
        }
        bar = barRef
        open = which
    }

    function hide() {
        if (open === "")
            return
        open = ""
        bar = null
    }

    function register(barRef) {
        if (bars.indexOf(barRef) === -1)
            bars = bars.concat([barRef])
    }

    function unregister(barRef) {
        bars = bars.filter(item => item !== barRef)
    }
}
