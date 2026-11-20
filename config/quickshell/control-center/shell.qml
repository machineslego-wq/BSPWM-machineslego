// ==========================================================
// machineslego — Control Center (Quickshell)
// ==========================================================
// Один файл, только нативные сервисы Quickshell:
//   Quickshell.Networking  — Wi-Fi
//   Quickshell.Bluetooth   — Bluetooth
//   Quickshell.Services.UPower — батарея и профиль питания
// Яркость в Quickshell 0.3.0 своего сервиса не имеет, поэтому
// используется brightnessctl через Quickshell.Io (не bash-скрипт).
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

PanelWindow {
    id: root

    // --- Tokyo Night palette ---
    readonly property color bg: "#1a1b26"
    readonly property color surface: "#24283b"
    readonly property color fg: "#a9b1d6"
    readonly property color accent: "#7aa2f7"
    readonly property color error: "#f7768e"
    readonly property color success: "#9ece6a"
    readonly property color muted: "#565f89"
    readonly property string mono: "JetBrainsMono Nerd Font"

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
    // панель-попап: стартует скрытой и вызывается с логотипа Debian в
    // waybar или по $mod+Ctrl+C (IPC toggle), а не висит на рабочем столе
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
    // Компоненты
    // ======================================================

    component Txt: Text {
        font.family: root.mono
        font.pixelSize: 13
        color: root.fg
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    component Card: Rectangle {
        id: card
        Layout.fillWidth: true
        implicitHeight: content.implicitHeight + 20
        radius: 2
        color: root.surface

        default property alias content: content.data

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8
        }
    }

    component FlatButton: Rectangle {
        id: button

        property string text: ""
        property bool active: false
        property bool danger: false
        property bool small: false

        signal clicked()

        implicitWidth: label.implicitWidth + (small ? 16 : 22)
        implicitHeight: small ? 22 : 30
        radius: 2
        color: active ? root.accent
            : danger ? root.bg
            : mouse.containsMouse ? root.surface
            : root.bg
        border.width: danger ? 1 : 0
        border.color: root.error
        opacity: enabled ? 1 : 0.45

        Txt {
            id: label
            anchors.centerIn: parent
            text: button.text
            font.pixelSize: button.small ? 11 : 12
            color: button.active ? root.bg
                : button.danger ? root.error
                : root.fg
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: button.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }

    component Toggle: Rectangle {
        id: toggle

        property bool on: false

        signal toggled()

        implicitWidth: 38
        implicitHeight: 20
        radius: 3
        color: on ? root.accent : root.bg
        border.width: 1
        border.color: on ? root.accent : root.muted

        Rectangle {
            width: 14
            height: 14
            radius: 2
            y: 2
            x: toggle.on ? toggle.width - 16 : 2
            color: toggle.on ? root.bg : root.muted
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: toggle.toggled()
        }
    }

    // ======================================================
    // Окно
    // ======================================================

    Rectangle {
        anchors.fill: parent
        color: root.bg

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
                        color: root.accent
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
                        color: root.muted
                    }

                    Txt {
                        visible: Networking.wifiEnabled && !root.wifiDevice
                        text: "Адаптер не найден"
                        color: root.muted
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
                                color: rowMouse.containsMouse ? root.bg : "transparent"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 6
                                    anchors.rightMargin: 6
                                    spacing: 6

                                    Txt {
                                        text: root.signalIcon(modelData.signalStrength)
                                        font.pixelSize: 14
                                        color: modelData.connected ? root.accent : root.fg
                                    }
                                    Txt {
                                        Layout.fillWidth: true
                                        text: modelData.name
                                        color: modelData.connected ? root.accent : root.fg
                                    }
                                    Txt {
                                        visible: modelData.security !== WifiSecurityType.Open
                                            && modelData.security !== WifiSecurityType.Owe
                                        text: "󰌾"
                                        color: root.muted
                                    }
                                    Txt {
                                        visible: modelData.connected
                                        text: "󰄬"
                                        color: root.success
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
                        color: root.muted
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
                        color: root.muted
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
                                        color: modelData.connected ? root.accent : root.fg
                                    }
                                    Txt {
                                        visible: modelData.batteryAvailable
                                        text: Math.round(modelData.battery) + "%"
                                        color: root.muted
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
                        color: root.muted
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
                        color: root.bg

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
                        color: root.muted
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
                            color: root.fg
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
                            color: root.bg

                            Rectangle {
                                width: parent.width * brightnessSlider.visualPosition
                                height: parent.height
                                radius: 2
                                color: root.accent
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
                            color: root.accent
                        }
                    }

                    Txt {
                        visible: !root.brightnessAvailable
                        text: "Нет устройства подсветки"
                        color: root.muted
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
            color: root.bg
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
                    color: root.accent
                }
                Txt {
                    Layout.fillWidth: true
                    text: root.pendingNetwork ? root.pendingNetwork.name : ""
                    color: root.muted
                }

                TextField {
                    id: passwordField
                    Layout.fillWidth: true
                    placeholderText: "Пароль"
                    echoMode: TextInput.Password
                    color: root.fg
                    placeholderTextColor: root.muted
                    font.family: root.mono
                    font.pixelSize: 13
                    background: Rectangle {
                        color: root.bg
                        radius: 2
                        border.width: 1
                        border.color: passwordField.activeFocus
                            ? root.accent : root.surface
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
        if (!battery || !battery.isPresent) return root.muted
        if (batteryLevel <= 15) return root.error
        if (battery.state === UPowerDeviceState.Charging
                || battery.state === UPowerDeviceState.FullyCharged)
            return root.success
        return root.accent
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
