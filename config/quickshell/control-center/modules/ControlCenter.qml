// ==========================================================
// machineslego — Control Center (модуль Quickshell)
// ==========================================================
// Панель-попап: Wi-Fi, Bluetooth, батарея, яркость, профиль
// питания и меню питания. Инстанцируется из shell.qml, живёт в
// одном процессе qs с будущими модулями (панель, лаунчер).
//
// Нативные сервисы Quickshell:
//   Quickshell.Networking          — Wi-Fi
//   Quickshell.Bluetooth           — Bluetooth
//   Quickshell.Services.UPower     — батарея и профиль питания
// Яркость в Quickshell 0.3.0 своего сервиса не имеет, поэтому
// используется brightnessctl через Quickshell.Io (не bash-скрипт).
//
// Цвета и шрифт — из синглтона Theme (components/), виджеты Txt /
// Card / FlatButton / Toggle — оттуда же.
// ==========================================================

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.UPower
import Quickshell.Wayland
import "../components"

PanelWindow {
    id: root

    // --- Wi-Fi ---
    readonly property var wifiDevice: {
        const devs = Networking.devices.values
        for (let i = 0; i < devs.length; i++)
            if (devs[i].type === DeviceType.Wifi) return devs[i]
        return null
    }

    readonly property var wifiNetworks: {
        if (!wifiDevice) return []
        const nets = wifiDevice.networks.values.filter(n => n.name !== "")
        nets.sort((a, b) => {
            if (a.connected !== b.connected) return a.connected ? -1 : 1
            if (a.known !== b.known) return a.known ? -1 : 1
            return b.signalStrength - a.signalStrength
        })
        return nets.slice(0, 6)
    }

    property var pendingNetwork: null

    // --- Bluetooth ---
    readonly property var btAdapter: Bluetooth.defaultAdapter

    readonly property var btDevices: {
        const devs = Bluetooth.devices.values.filter(d => d.paired || d.bonded)
        devs.sort((a, b) => {
            if (a.connected !== b.connected) return a.connected ? -1 : 1
            return (a.name || a.deviceName || a.address)
                .localeCompare(b.name || b.deviceName || b.address)
        })
        return devs.slice(0, 4)
    }

    // --- Battery ---
    readonly property var battery: UPower.displayDevice
    readonly property real batteryLevel: {
        if (!battery || !battery.isPresent) return 0
        const p = battery.percentage
        return Math.max(0, Math.min(100, p <= 1 ? p * 100 : p))
    }

    // --- Brightness ---
    property int brightness: 0
    property bool brightnessAvailable: true

    // --- Power menu ---
    property bool powerOpen: false

    // --- Window ---
    anchors {
        top: true
        right: true
    }
    margins {
        top: 40
        right: 8
    }
    implicitWidth: 360
    implicitHeight: Math.min(body.implicitHeight + 24,
        (root.screen ? root.screen.height : 1080) - 48)
    // панель-попап: стартует скрытой и вызывается кнопкой control-center
    // в waybar или по $mod+Ctrl+C (IPC toggle), а не висит на рабочем столе
    visible: false
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    focusable: true
    // без диалога панель не забирает клавиатуру (по клику — забирает),
    // а на время ввода пароля Wi-Fi фокус эксклюзивный
    WlrLayershell.keyboardFocus: root.pendingNetwork !== null
        ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand

    // ======================================================
    // Окно
    // ======================================================

    Rectangle {
        anchors.fill: parent
        color: Theme.bg

        Flickable {
            id: flick
            anchors.fill: parent
            anchors.margins: 12
            contentWidth: width
            contentHeight: body.implicitHeight
            clip: true

            ColumnLayout {
                id: body
                width: flick.width
                spacing: 10

                // --- HEADER ---
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Txt {
                        text: "Control Center"
                        font.pixelSize: 14
                        font.bold: true
                        color: Theme.accent
                    }
                    Item { Layout.fillWidth: true }
                    FlatButton {
                        text: "✕"
                        small: true
                        onClicked: root.visible = false
                    }
                }

                // --- WI-FI ---
                Card {
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Txt { text: "󰖩  Wi-Fi"; font.bold: true }
                        Item { Layout.fillWidth: true }
                        Toggle {
                            on: Networking.wifiEnabled
                            onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
                        }
                    }

                    Txt {
                        visible: !Networking.wifiEnabled
                        text: "Wi-Fi выключен"
                        color: Theme.muted
                    }

                    Txt {
                        visible: Networking.wifiEnabled && !root.wifiDevice
                        text: "Адаптер не найден"
                        color: Theme.muted
                    }

                    ColumnLayout {
                        visible: Networking.wifiEnabled && root.wifiDevice
                        Layout.fillWidth: true
                        spacing: 2

                        Repeater {
                            model: root.wifiNetworks

                            delegate: Rectangle {
                                required property var modelData

                                Layout.fillWidth: true
                                implicitHeight: 30
                                radius: 2
                                color: rowMouse.containsMouse ? Theme.bg : "transparent"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 6
                                    anchors.rightMargin: 6
                                    spacing: 6

                                    Txt {
                                        text: root.signalIcon(modelData.signalStrength)
                                        font.pixelSize: 14
                                        color: modelData.connected ? Theme.accent : Theme.fg
                                    }
                                    Txt {
                                        Layout.fillWidth: true
                                        text: modelData.name
                                        color: modelData.connected ? Theme.accent : Theme.fg
                                    }
                                    Txt {
                                        visible: modelData.security !== WifiSecurityType.Open
                                            && modelData.security !== WifiSecurityType.Owe
                                        text: "󰌾"
                                        color: Theme.muted
                                    }
                                    Txt {
                                        visible: modelData.connected
                                        text: "󰄬"
                                        color: Theme.success
                                    }
                                }

                                MouseArea {
                                    id: rowMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.connectNetwork(modelData)
                                }
                            }
                        }
                    }

                    Txt {
                        visible: Networking.wifiEnabled && root.wifiDevice
                            && root.wifiNetworks.length === 0
                        text: "Сети не найдены"
                        color: Theme.muted
                    }
                }

                // --- BLUETOOTH ---
                Card {
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Txt { text: "󰂯  Bluetooth"; font.bold: true }
                        Item { Layout.fillWidth: true }
                        Toggle {
                            on: root.btAdapter ? root.btAdapter.enabled : false
                            onToggled: {
                                if (root.btAdapter)
                                    root.btAdapter.enabled = !root.btAdapter.enabled
                            }
                        }
                    }

                    Txt {
                        visible: !root.btAdapter
                        text: "Адаптер не найден"
                        color: Theme.muted
                    }

                    ColumnLayout {
                        visible: root.btAdapter && root.btAdapter.enabled
                        Layout.fillWidth: true
                        spacing: 2

                        Repeater {
                            model: root.btDevices

                            delegate: Rectangle {
                                required property var modelData

                                Layout.fillWidth: true
                                implicitHeight: 30
                                radius: 2
                                color: "transparent"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 6
                                    anchors.rightMargin: 6
                                    spacing: 6

                                    Txt {
                                        Layout.fillWidth: true
                                        text: modelData.name || modelData.deviceName
                                            || modelData.address
                                        color: modelData.connected ? Theme.accent : Theme.fg
                                    }
                                    Txt {
                                        visible: modelData.batteryAvailable
                                        text: Math.round(modelData.battery) + "%"
                                        color: Theme.muted
                                    }
                                    FlatButton {
                                        small: true
                                        text: modelData.connected ? "Отключить" : "Подключить"
                                        onClicked: modelData.connected
                                            ? modelData.disconnect()
                                            : modelData.connect()
                                    }
                                }
                            }
                        }
                    }

                    Txt {
                        visible: root.btAdapter && root.btAdapter.enabled
                            && root.btDevices.length === 0
                        text: "Нет сопряжённых устройств"
                        color: Theme.muted
                    }
                }

                // --- BATTERY ---
                Card {
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Txt { text: "󰁹  Батарея"; font.bold: true }
                        Item { Layout.fillWidth: true }
                        Txt {
                            text: root.battery && root.battery.isPresent
                                ? Math.round(root.batteryLevel) + "%" : "—"
                            font.bold: true
                            color: root.batteryColor()
                        }
                    }

                    Rectangle {
                        visible: root.battery && root.battery.isPresent
                        Layout.fillWidth: true
                        implicitHeight: 6
                        radius: 3
                        color: Theme.bg

                        Rectangle {
                            width: parent.width * root.batteryLevel / 100
                            height: parent.height
                            radius: 3
                            color: root.batteryColor()
                        }
                    }

                    Txt {
                        text: root.battery && root.battery.isPresent
                            ? root.batteryStateText(root.battery.state)
                            : "Батарея не найдена"
                        color: Theme.muted
                    }
                }

                // --- BRIGHTNESS ---
                Card {
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Txt { text: "󰃠  Яркость"; font.bold: true }
                        Item { Layout.fillWidth: true }
                        Txt {
                            text: root.brightnessAvailable
                                ? root.brightness + "%" : "—"
                            color: Theme.fg
                        }
                    }

                    Slider {
                        id: brightnessSlider
                        visible: root.brightnessAvailable
                        Layout.fillWidth: true
                        // без явной высоты у Slider не остаётся области клика:
                        // implicitHeight выводится из background/handle
                        Layout.preferredHeight: 22
                        from: 0
                        to: 100
                        stepSize: 1
                        value: root.brightness

                        // ловим любое изменение значения (клик, протяжка,
                        // стрелки), но не эхо от опроса brightnessctl
                        onValueChanged: {
                            if (root.brightness !== Math.round(value)) {
                                root.brightness = Math.round(value)
                                brightnessDebounce.restart()
                            }
                        }
                        // после перетаскивания возвращаем биндинг, иначе
                        // ползунок перестанет следить за brightnessctl
                        onPressedChanged: if (!pressed)
                            value = Qt.binding(() => root.brightness)

                        background: Rectangle {
                            x: brightnessSlider.leftPadding
                            y: brightnessSlider.topPadding
                                + (brightnessSlider.availableHeight - height) / 2
                            width: brightnessSlider.availableWidth
                            height: 4
                            radius: 2
                            color: Theme.bg

                            Rectangle {
                                width: parent.width * brightnessSlider.visualPosition
                                height: parent.height
                                radius: 2
                                color: Theme.accent
                            }
                        }

                        handle: Rectangle {
                            x: brightnessSlider.leftPadding
                                + brightnessSlider.visualPosition
                                * (brightnessSlider.availableWidth - width)
                            y: brightnessSlider.topPadding
                                + (brightnessSlider.availableHeight - height) / 2
                            width: 12
                            height: 12
                            radius: 2
                            color: Theme.accent
                        }
                    }

                    Txt {
                        visible: !root.brightnessAvailable
                        text: "Нет устройства подсветки"
                        color: Theme.muted
                    }
                }

                // --- POWER PROFILE ---
                Card {
                    Txt { text: "󰓅  Профиль питания"; font.bold: true }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        FlatButton {
                            Layout.fillWidth: true
                            small: true
                            text: "Performance"
                            active: PowerProfiles.profile === PowerProfile.Performance
                            enabled: PowerProfiles.hasPerformanceProfile
                            onClicked: PowerProfiles.profile = PowerProfile.Performance
                        }
                        FlatButton {
                            Layout.fillWidth: true
                            small: true
                            text: "Balanced"
                            active: PowerProfiles.profile === PowerProfile.Balanced
                            onClicked: PowerProfiles.profile = PowerProfile.Balanced
                        }
                        FlatButton {
                            Layout.fillWidth: true
                            small: true
                            text: "Power Saver"
                            active: PowerProfiles.profile === PowerProfile.PowerSaver
                            onClicked: PowerProfiles.profile = PowerProfile.PowerSaver
                        }
                    }
                }

                // --- POWER MENU ---
                Card {
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Txt { text: "󰐥  Питание"; font.bold: true }
                        Item { Layout.fillWidth: true }
                        FlatButton {
                            small: true
                            text: root.powerOpen ? "Скрыть" : "Действия"
                            onClicked: root.powerOpen = !root.powerOpen
                        }
                    }

                    GridLayout {
                        visible: root.powerOpen
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 6
                        rowSpacing: 6

                        FlatButton {
                            Layout.fillWidth: true
                            small: true
                            text: "󰌾  Блокировка"
                            onClicked: Quickshell.execDetached(["swaylock", "-f"])
                        }
                        FlatButton {
                            Layout.fillWidth: true
                            small: true
                            text: "󰍃  Выход"
                            onClicked: Quickshell.execDetached(["swaymsg", "exit"])
                        }
                        FlatButton {
                            Layout.fillWidth: true
                            small: true
                            text: "󰜉  Перезагрузка"
                            onClicked: Quickshell.execDetached(["systemctl", "reboot"])
                        }
                        FlatButton {
                            Layout.fillWidth: true
                            small: true
                            danger: true
                            text: "󰐥  Выключить"
                            onClicked: Quickshell.execDetached(["systemctl", "poweroff"])
                        }
                    }
                }
            }
        }

        // --- WI-FI PASSWORD DIALOG ---
        Rectangle {
            id: passwordOverlay
            anchors.fill: parent
            visible: root.pendingNetwork !== null
            color: Theme.bg
            z: 10

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width - 32
                spacing: 10

                Txt {
                    text: "Пароль Wi-Fi"
                    font.pixelSize: 14
                    font.bold: true
                    color: Theme.accent
                }
                Txt {
                    Layout.fillWidth: true
                    text: root.pendingNetwork ? root.pendingNetwork.name : ""
                    color: Theme.muted
                }

                TextField {
                    id: passwordField
                    Layout.fillWidth: true
                    placeholderText: "Пароль"
                    echoMode: TextInput.Password
                    color: Theme.fg
                    placeholderTextColor: Theme.muted
                    font.family: Theme.mono
                    font.pixelSize: 13
                    background: Rectangle {
                        color: Theme.bg
                        radius: 2
                        border.width: 1
                        border.color: passwordField.activeFocus
                            ? Theme.accent : Theme.surface
                    }
                    onAccepted: root.submitPassword()
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Item { Layout.fillWidth: true }
                    FlatButton {
                        text: "Отмена"
                        onClicked: root.pendingNetwork = null
                    }
                    FlatButton {
                        text: "Подключить"
                        active: true
                        onClicked: root.submitPassword()
                    }
                }
            }

            onVisibleChanged: {
                if (visible) {
                    passwordField.text = ""
                    passwordField.forceActiveFocus()
                }
            }
        }
    }

    // ======================================================
    // Логика
    // ======================================================

    function signalIcon(strength) {
        if (strength >= 0.75) return "󰤨"
        if (strength >= 0.50) return "󰤥"
        if (strength >= 0.25) return "󰤢"
        return "󰤟"
    }

    function connectNetwork(net) {
        if (!net) return

        if (net.connected) {
            net.disconnect()
            return
        }
        // открытая сеть или уже известная (пароль сохранён в NM) —
        // подключаемся без диалога
        if (net.known || net.security === WifiSecurityType.Open
                || net.security === WifiSecurityType.Owe) {
            net.connect()
            return
        }
        pendingNetwork = net
    }

    function submitPassword() {
        if (!pendingNetwork) return
        const net = pendingNetwork
        const psk = passwordField.text
        pendingNetwork = null
        net.connectWithPsk(psk)
    }

    function batteryStateText(state) {
        switch (state) {
        case UPowerDeviceState.Charging: return "Зарядка"
        case UPowerDeviceState.Discharging: return "Разрядка"
        case UPowerDeviceState.Empty: return "Разряжена"
        case UPowerDeviceState.FullyCharged: return "Заряжена"
        case UPowerDeviceState.PendingCharge: return "Ожидание зарядки"
        case UPowerDeviceState.PendingDischarge: return "Ожидание разрядки"
        default: return "Неизвестно"
        }
    }

    function batteryColor() {
        if (!battery || !battery.isPresent) return Theme.muted
        if (batteryLevel <= 15) return Theme.error
        if (battery.state === UPowerDeviceState.Charging
                || battery.state === UPowerDeviceState.FullyCharged)
            return Theme.success
        return Theme.accent
    }

    function setBrightness(percent) {
        const value = Math.round(Math.max(0, Math.min(100, percent)))
        root.brightness = value
        brightnessSet.exec(["brightnessctl", "set", value + "%"])
    }

    Process {
        id: brightnessRead
        command: ["brightnessctl", "-m"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                // brightnessctl -m: device,class,current,percent,max
                const parts = this.text.trim().split(",")
                const current = Number(parts[2])
                const max = Number(parts[4])
                if (parts.length >= 5 && max > 0 && !isNaN(current)) {
                    root.brightness = Math.round(current * 100 / max)
                    root.brightnessAvailable = true
                }
            }
        }

        onExited: (code) => {
            if (code !== 0) root.brightnessAvailable = false
        }
    }

    Timer {
        id: brightnessDebounce
        interval: 120
        repeat: false
        onTriggered: root.setBrightness(root.brightness)
    }

    Process {
        id: brightnessSet
        command: ["brightnessctl", "set", "50%"]
        running: false
    }

    Timer {
        interval: 10000
        repeat: true
        running: root.visible
        triggeredOnStart: true
        onTriggered: brightnessRead.running = true
    }

    // Сканирование Wi-Fi, пока включено радио
    Binding {
        target: root.wifiDevice
        property: "scannerEnabled"
        value: Networking.wifiEnabled
        when: root.wifiDevice !== null
    }

    // ======================================================
    // IPC: qs ipc call control-center toggle
    // ======================================================

    IpcHandler {
        target: "control-center"

        function toggle(): void { root.visible = !root.visible }
        function open(): void { root.visible = true }
        function close(): void { root.visible = false }
    }
}
