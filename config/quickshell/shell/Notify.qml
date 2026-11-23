pragma Singleton

// ==========================================================
// Уведомления: сервер, всплывающие карточки и история.
// На этой ветке mako не запускается — org.freedesktop.Notifications
// держит Quickshell, поэтому notify-send (и wpctl-volume) приходят
// сюда. OSD громкости (x-canonical-private-synchronous: volume)
// показывается карточкой с полоской и в историю не пишется.
// ==========================================================

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: svc

    readonly property int maxActive: 4
    readonly property int maxHistory: 50

    property var active: []
    property var history: []
    property bool dnd: false

    // modelData в Repeater — обёртка над JS-объектом, сравнение
    // по ссылке не срабатывает: элементы ищем по uid.
    property int nextUid: 1

    NotificationServer {
        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: (notification) => svc.push(notification)
    }

    function push(notification) {
        const hints = notification.hints || {}
        const isOsd = hints["x-canonical-private-synchronous"] === "volume"
        const value = hints.value === undefined
            ? -1
            : Math.max(0, Math.min(100, Number(hints.value)))

        let timeout = 5000
        if (isOsd)
            timeout = 1600
        else if (notification.urgency >= 2)
            timeout = 0
        else if (notification.expireTimeout > 0)
            timeout = notification.expireTimeout

        if (!isOsd) {
            const entry = {
                uid: svc.nextUid++,
                summary: notification.summary || "",
                body: notification.body || "",
                appName: notification.appName || "",
                appIcon: notification.appIcon || "",
                urgency: notification.urgency,
                time: new Date()
            }
            svc.history = [entry].concat(svc.history).slice(0, svc.maxHistory)
        }

        if (svc.dnd && !isOsd) {
            notification.dismiss()
            return
        }

        svc.addActive(notification, isOsd, value, timeout)
    }

    function addActive(notification, isOsd, value, timeout) {
        const item = {
            uid: svc.nextUid++,
            notification: notification,
            summary: notification.summary || "",
            body: notification.body || "",
            appName: notification.appName || "",
            appIcon: notification.appIcon || "",
            urgency: notification.urgency,
            isOsd: isOsd,
            value: value,
            actions: notification.actions || [],
            expiresAt: timeout > 0 ? Date.now() + timeout : 0
        }

        svc.active = svc.active.concat([item])

        while (svc.active.length > svc.maxActive)
            svc.dismiss(svc.active[0])
    }

    function dismiss(item) {
        if (!item)
            return
        try {
            if (item.notification)
                item.notification.dismiss()
        } catch (e) {
            // уведомление уже закрыто приложением
        }
        svc.active = svc.active.filter(entry => entry.uid !== item.uid)
    }

    function dismissAll() {
        const list = svc.active
        for (let i = 0; i < list.length; i++) {
            try {
                if (list[i].notification)
                    list[i].notification.dismiss()
            } catch (e) {
            }
        }
        svc.active = []
    }

    function invoke(item, action) {
        if (!item || !action)
            return
        try {
            action.invoke()
        } catch (e) {
        }
        svc.dismiss(item)
    }

    function clearHistory() {
        svc.history = []
    }

    function removeHistory(entry) {
        svc.history = svc.history.filter(item => item.uid !== entry.uid)
    }

    function toggleDnd() {
        svc.dnd = !svc.dnd
    }

    // Истечение срока: один таймер на все карточки.
    Timer {
        interval: 500
        repeat: true
        running: true
        onTriggered: {
            if (svc.active.length === 0)
                return

            const now = Date.now()
            const keep = []
            let changed = false
            for (let i = 0; i < svc.active.length; i++) {
                const item = svc.active[i]
                if (item.expiresAt > 0 && now >= item.expiresAt) {
                    try {
                        if (item.notification)
                            item.notification.dismiss()
                    } catch (e) {
                    }
                    changed = true
                } else {
                    keep.push(item)
                }
            }
            if (changed)
                svc.active = keep
        }
    }
}
