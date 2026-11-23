pragma Singleton

// ==========================================================
// Форматирование и иконки Nerd Font.
// Русские месяцы/дни захардкожены: JavaScript-локаль в QML
// зависит от окружения, а панель должна выглядеть одинаково
// на всех трёх машинах.
// ==========================================================

import QtQuick
import Quickshell

Singleton {
    readonly property var monthsFull: [
        "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь",
        "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"
    ]
    readonly property var monthsShort: [
        "янв", "фев", "мар", "апр", "мая", "июн",
        "июл", "авг", "сен", "окт", "ноя", "дек"
    ]
    // Индекс — как у Date.getDay(): 0 — воскресенье.
    readonly property var weekdaysShort: ["вс", "пн", "вт", "ср", "чт", "пт", "сб"]
    readonly property var weekdaysFull: [
        "Воскресенье", "Понедельник", "Вторник", "Среда",
        "Четверг", "Пятница", "Суббота"
    ]
    // Заголовок сетки календаря: неделя с понедельника.
    readonly property var weekdaysGrid: ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]

    function pad2(n) {
        return n < 10 ? "0" + n : "" + n
    }

    function timeText(d) {
        return pad2(d.getHours()) + ":" + pad2(d.getMinutes())
    }

    function dateText(d) {
        return weekdaysShort[d.getDay()] + ", " + pad2(d.getDate()) + " " + monthsShort[d.getMonth()]
    }

    function monthText(d) {
        return monthsFull[d.getMonth()] + " " + d.getFullYear()
    }

    function volumeIcon(percent, muted) {
        if (muted) return "󰝟"
        if (percent < 34) return "󰕿"
        if (percent < 67) return "󰖀"
        return "󰕾"
    }

    function brightnessIcon(percent) {
        if (percent < 34) return "󰃞"
        if (percent < 67) return "󰃟"
        return "󰃠"
    }

    function batteryIcon(percent, charging) {
        if (charging) return "󰂄"
        if (percent >= 95) return "󰁹"
        if (percent >= 85) return "󰂂"
        if (percent >= 75) return "󰂁"
        if (percent >= 65) return "󰂀"
        if (percent >= 55) return "󰁿"
        if (percent >= 45) return "󰁾"
        if (percent >= 35) return "󰁽"
        if (percent >= 25) return "󰁼"
        if (percent >= 15) return "󰁻"
        if (percent >= 5) return "󰁺"
        return "󰂃"
    }

    function wifiIcon(strength) {
        if (strength >= 0.75) return "󰤨"
        if (strength >= 0.5) return "󰤥"
        if (strength >= 0.25) return "󰤢"
        if (strength > 0) return "󰤟"
        return "󰤯"
    }

    function bluetoothIcon(enabled, connections) {
        if (!enabled) return "󰂲"
        return connections > 0 ? "󰂱" : "󰂯"
    }

    // SystemTrayItem.icon приходит либо именем иконки, либо путём.
    function iconSource(icon) {
        if (!icon) return Quickshell.iconPath("application-x-executable")
        if (icon.startsWith("image://") || icon.startsWith("/") || icon.startsWith("file:"))
            return icon
        return Quickshell.iconPath(Quickshell.hasThemeIcon(icon) ? icon : "application-x-executable")
    }
}
