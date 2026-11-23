import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.UPower

// ==========================================================
// Центр управления: сеть, Bluetooth, звук, яркость, профиль
// питания, батарея, календарь и действия питания.
// Это содержимое оверлея, а не отдельное окно: Overlay.qml
// ставит его на экран и закрывает по клику мимо.
// ==========================================================
Item {
    id: root

    property int maxHeight: 900

    width: Theme.popupWidth
    height: Math.min(inner.implicitHeight + 26, maxHeight)

    focus: true
    Keys.onEscapePressed: ShellState.hide()

    // Клик по фону панели не должен закрывать оверлей:
    // перехватываем его до общего MouseArea в Overlay.
    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    // --- Wi-Fi ---
    readonly property var wifiDevice: {
        const devices = Networking.devices.values
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].type === DeviceType.Wifi)
                return devices[i]
        }
        return null
    }

    readonly property var wifiNetworks: {
        if (!root.wifiDevice)
            return []
        const networks = root.wifiDevice.networks.values.filter(n => n.name !== "")
        networks.sort((a, b) => {
            if (a.connected !== b.connected) return a.connected ? -1 : 1
            if (a.known !== b.known) return a.known ? -1 : 1
            return b.signalStrength - a.signalStrength
        })
        return networks.slice(0, 6)
    }

    property var pendingNetwork: null

    // --- Bluetooth ---
    readonly property var btAdapter: Bluetooth.defaultAdapter

    readonly property var btDevices: {
        if (!root.btAdapter)
            return []
        const devices = Bluetooth.devices.values.filter(d =>
            d.paired || d.bonded || (root.btAdapter.discovering && (d.name || d.deviceName)))
        devices.sort((a, b) => {
            if (a.connected !== b.connected) return a.connected ? -1 : 1
            return (a.name || a.deviceName || a.address)
                .localeCompare(b.name || b.deviceName || b.address)
        })
        return devices.slice(0, 8)
    }

    // --- Батарея ---
    readonly property var battery: UPower.displayDevice
    readonly property bool batteryPresent: battery !== null && battery.isPresent
    readonly property int batteryPercent: {
        if (!root.batteryPresent)
            return 0
        const p = root.battery.percentage
        return Math.round(Math.max(0, Math.min(100, p <= 1 ? p * 100 : p)))
    }

    property date now: new Date()

    Timer {
        interval: 1000
        repeat: true
        running: root.visible
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    // ======================================================
    // Вспомогательные компоненты
    // ======================================================

    component Card: Rectangle {
        id: card

        Layout.fillWidth: true
        implicitHeight: inner.implicitHeight + 20
        radius: Theme.radius
        color: Theme.surface

        default property alias contentData: inner.data

        ColumnLayout {
            id: inner
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8
        }
    }

    component CardTitle: Text {
        font.family: Theme.font
        font.pixelSize: 12
        font.bold: true
        color: Theme.fg
    }

    component FlatButton: Rectangle {
        id: button

        property string text: ""
        property bool active: false
        property bool danger: false

        signal clicked()

        Layout.fillWidth: true
        implicitHeight: 28
        radius: 4
        color: active ? Theme.accent
            : mouse.containsMouse ? Theme.surfaceHigh
            : Theme.bgMid
        border.width: danger ? 1 : 0
        border.color: Theme.error

        Text {
            anchors.centerIn: parent
            text: button.text
            font.family: Theme.font
            font.pixelSize: 12
            color: button.active ? Theme.bg
                : button.danger ? Theme.error
                : Theme.fg
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
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
        color: toggle.on ? Theme.accent : Theme.bgMid
        border.width: 1
        border.color: toggle.on ? Theme.accent : Theme.muted

        Rectangle {
            width: 14
            height: 14
            radius: 2
            y: 2
            x: toggle.on ? toggle.width - 16 : 2
            color: toggle.on ? Theme.bg : Theme.muted
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: toggle.toggled()
        }
    }

    // ======================================================
    // Содержимое
    // ======================================================
    Rectangle {
        anchors.fill: parent
        radius: Theme.popupRadius
        color: Theme.bg
        border.width: 1
        border.color: Theme.surfaceHigh

        focus: true
        Keys.onEscapePressed: ShellState.hide()

        Flickable {
            id: flick

            anchors.fill: parent
            anchors.margins: 12
            contentWidth: width
            contentHeight: inner.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: inner

                width: flick.width

                // --- Шапка ---
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    ColumnLayout {
                        spacing: 0

                        Text {
                            text: "Центр управления"
                            font.family: Theme.font
                            font.pixelSize: 14
                            font.bold: true
                            color: Theme.accent
                        }

                        Text {
                            text: Util.weekdaysFull[root.now.getDay()].toLowerCase()
                                + ", " + root.now.getDate() + " "
                                + Util.monthsShort[root.now.getMonth()] + " "
                                + root.now.getFullYear()
                            font.family: Theme.font
                            font.pixelSize: Theme.smallSize
                            color: Theme.muted
                        }
                    }

                    Item { Layout.fillWidth: true }

                    BarButton {
                        text: "󰅖"
                        pixelSize: 15
                        onClicked: ShellState.hide()
                    }
                }

                // --- Звук и яркость ---
                Card {
                    SliderRow {
                        icon: Util.volumeIcon(Volume.percent, Volume.muted)
                        value: Volume.volume
                        valueText: Volume.available
                            ? (Volume.muted ? "MUTE" : Volume.percent + "%")
                            : "—"
                        enabled: Volume.available
                        onMoved: (v) => Volume.setFraction(v)
                        onIconClicked: Volume.toggleMute()
                        onIconWheeled: (delta) => Volume.step(delta > 0 ? 5 : -5)
                    }

                    SliderRow {
                        visible: Brightness.available
                        icon: Util.brightnessIcon(Brightness.percent)
                        value: Brightness.percent / 100
                        valueText: Brightness.percent + "%"
                        enabled: Brightness.available
                        accentColor: Theme.secondary
                        onMoved: (v) => Brightness.setPercent(v * 100)
                        onIconWheeled: (delta) => Brightness.step(delta > 0 ? 5 : -5)
                    }
                }

                // --- Быстрые переключатели ---
                Card {
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        CardTitle {
                            Layout.fillWidth: true
                            text: "󰖩 Wi-Fi"
                        }

                        Toggle {
                            on: Networking.wifiEnabled
                            onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
                        }
                    }

                    Text {
                        visible: !Networking.wifiEnabled
                        Layout.fillWidth: true
                        text: "Wi-Fi выключен"
                        font.family: Theme.font
                        font.pixelSize: Theme.smallSize
                        color: Theme.muted
                    }

                    Text {
                        visible: Networking.wifiEnabled && !root.wifiDevice
                        Layout.fillWidth: true
                        text: "Адаптер не найден"
                        font.family: Theme.font
                        font.pixelSize: Theme.smallSize
                        color: Theme.muted
                    }

                    ColumnLayout {
                        visible: Networking.wifiEnabled && root.wifiDevice
                        Layout.fillWidth: true
                        spacing: 1

                        Repeater {
                            model: root.wifiNetworks

                            delegate: Rectangle {
                                required property var modelData

                                readonly property bool hovered: rowHover.hovered

                                Layout.fillWidth: true
                                implicitHeight: 30
                                radius: 4
                                color: hovered ? Theme.bgMid : "transparent"

                                HoverHandler { id: rowHover }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.connectNetwork(modelData)
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 6
                                    anchors.rightMargin: 6
                                    spacing: 8

                                    Text {
                                        text: Util.wifiIcon(modelData.signalStrength)
                                        font.family: Theme.font
                                        font.pixelSize: 14
                                        color: modelData.connected ? Theme.accent : Theme.fg
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.name
                                        font.family: Theme.font
                                        font.pixelSize: 12
                                        color: modelData.connected ? Theme.accent : Theme.fg
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        visible: modelData.security !== WifiSecurityType.Open
                                            && modelData.security !== WifiSecurityType.Owe
                                        text: "󰌾"
                                        font.family: Theme.font
                                        font.pixelSize: 11
                                        color: Theme.muted
                                    }

                                    Text {
                                        visible: modelData.connected
                                        text: "󰄬"
                                        font.family: Theme.font
                                        font.pixelSize: 12
                                        color: Theme.success
                                    }
                                }
                            }
                        }

                        Text {
                            visible: root.wifiNetworks.length === 0
                            Layout.fillWidth: true
                            text: "Сети не найдены"
                            font.family: Theme.font
                            font.pixelSize: Theme.smallSize
                            color: Theme.muted
                        }
                    }
                }

                // --- Bluetooth ---
                Card {
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        CardTitle {
                            Layout.fillWidth: true
                            text: "󰂯 Bluetooth"
                        }

                        BarButton {
                            visible: root.btAdapter !== null && root.btAdapter.enabled
                            text: root.btAdapter && root.btAdapter.discovering
                                ? "Стоп" : "󰂰 Поиск"
                            pixelSize: Theme.smallSize
                            normalColor: Theme.accent
                            onClicked: {
                                if (root.btAdapter)
                                    root.btAdapter.discovering = !root.btAdapter.discovering
                            }
                        }

                        Toggle {
                            on: root.btAdapter !== null && root.btAdapter.enabled
                            onToggled: {
                                if (root.btAdapter)
                                    root.btAdapter.enabled = !root.btAdapter.enabled
                            }
                        }
                    }

                    Text {
                        visible: root.btAdapter === null
                        Layout.fillWidth: true
                        text: "Адаптер не найден (проверьте rfkill)"
                        font.family: Theme.font
                        font.pixelSize: Theme.smallSize
                        color: Theme.muted
                    }

                    ColumnLayout {
                        visible: root.btAdapter !== null && root.btAdapter.enabled
                        Layout.fillWidth: true
                        spacing: 1

                        Repeater {
                            model: root.btDevices

                            delegate: Rectangle {
                                required property var modelData

                                readonly property bool hovered: deviceHover.hovered

                                Layout.fillWidth: true
                                implicitHeight: 30
                                radius: 4
                                color: hovered ? Theme.bgMid : "transparent"

                                HoverHandler { id: deviceHover }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 6
                                    anchors.rightMargin: 6
                                    spacing: 8

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.name || modelData.deviceName
                                            || modelData.address
                                        font.family: Theme.font
                                        font.pixelSize: 12
                                        color: modelData.connected ? Theme.accent : Theme.fg
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        visible: modelData.batteryAvailable
                                        text: Math.round(modelData.battery) + "%"
                                        font.family: Theme.font
                                        font.pixelSize: Theme.smallSize
                                        color: Theme.muted
                                    }

                                    BarButton {
                                        text: modelData.pairing ? "…"
                                            : modelData.connected ? "Отключить"
                                            : (modelData.paired || modelData.bonded)
                                                ? "Подключить" : "Сопряжение"
                                        pixelSize: Theme.smallSize
                                        enabled: !modelData.pairing
                                        onClicked: {
                                            if (modelData.pairing)
                                                return
                                            if (modelData.connected)
                                                modelData.disconnect()
                                            else if (modelData.paired || modelData.bonded)
                                                modelData.connect()
                                            else
                                                modelData.pair()
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            visible: root.btDevices.length === 0
                            Layout.fillWidth: true
                            text: root.btAdapter && root.btAdapter.discovering
                                ? "Поиск устройств…"
                                : "Нет сопряжённых устройств"
                            font.family: Theme.font
                            font.pixelSize: Theme.smallSize
                            color: Theme.muted
                        }
                    }
                }

                // --- Батарея ---
                Card {
                    visible: root.batteryPresent

                    RowLayout {
                        Layout.fillWidth: true

                        CardTitle {
                            Layout.fillWidth: true
                            text: "󰁹 Батарея"
                        }

                        Text {
                            text: Util.batteryIcon(root.batteryPercent,
                                root.battery.state === UPowerDeviceState.Charging
                                || root.battery.state === UPowerDeviceState.FullyCharged)
                                + " " + root.batteryPercent + "%"
                            font.family: Theme.font
                            font.pixelSize: 13
                            font.bold: true
                            color: root.batteryPercent <= 15 ? Theme.error
                                : root.battery.state === UPowerDeviceState.Charging
                                    || root.battery.state === UPowerDeviceState.FullyCharged
                                    ? Theme.success : Theme.accent
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 6
                        radius: 3
                        color: Theme.bgMid

                        Rectangle {
                            width: parent.width * root.batteryPercent / 100
                            height: parent.height
                            radius: 3
                            color: root.batteryPercent <= 15 ? Theme.error : Theme.accent
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.batteryStateText()
                        font.family: Theme.font
                        font.pixelSize: Theme.smallSize
                        color: Theme.muted
                    }
                }

                // --- Профиль питания ---
                Card {
                    CardTitle {
                        text: "󰓅 Профиль питания"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        FlatButton {
                            text: "PERF"
                            active: PowerProfiles.profile === PowerProfile.Performance
                            enabled: PowerProfiles.hasPerformanceProfile
                            onClicked: PowerProfiles.profile = PowerProfile.Performance
                        }

                        FlatButton {
                            text: "BAL"
                            active: PowerProfiles.profile === PowerProfile.Balanced
                            onClicked: PowerProfiles.profile = PowerProfile.Balanced
                        }

                        FlatButton {
                            text: "ECO"
                            active: PowerProfiles.profile === PowerProfile.PowerSaver
                            onClicked: PowerProfiles.profile = PowerProfile.PowerSaver
                        }
                    }
                }

                // --- Календарь ---
                Card {
                    CardTitle {
                        text: "󰃭 Календарь"
                    }

                    CalendarView {
                        Layout.fillWidth: true
                    }
                }

                // --- Питание ---
                Card {
                    CardTitle {
                        text: "󰐥 Питание"
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 6
                        rowSpacing: 6

                        FlatButton {
                            text: "󰌾 Блокировка"
                            onClicked: {
                                ShellState.hide()
                                Quickshell.execDetached(["swaylock", "-f"])
                            }
                        }

                        FlatButton {
                            text: "󰒲 Сон"
                            onClicked: {
                                ShellState.hide()
                                Quickshell.execDetached(["systemctl", "suspend"])
                            }
                        }

                        FlatButton {
                            text: "󰍃 Выход"
                            onClicked: {
                                ShellState.hide()
                                Quickshell.execDetached(["swaymsg", "exit"])
                            }
                        }

                        FlatButton {
                            text: "󰜉 Перезагрузка"
                            onClicked: {
                                ShellState.hide()
                                Quickshell.execDetached(["systemctl", "reboot"])
                            }
                        }

                        FlatButton {
                            Layout.columnSpan: 2
                            danger: true
                            text: "󰐥 Выключить"
                            onClicked: {
                                ShellState.hide()
                                Quickshell.execDetached(["systemctl", "poweroff"])
                            }
                        }
                    }
                }
            }
        }

        // --- Ввод пароля Wi-Fi ---
        Rectangle {
            id: passwordOverlay

            anchors.fill: parent
            anchors.margins: 1
            radius: Theme.popupRadius
            visible: root.pendingNetwork !== null
            color: Theme.bg
            z: 10

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width - 48
                spacing: 10

                Text {
                    text: "Пароль Wi-Fi"
                    font.family: Theme.font
                    font.pixelSize: 14
                    font.bold: true
                    color: Theme.accent
                }

                Text {
                    Layout.fillWidth: true
                    text: root.pendingNetwork ? root.pendingNetwork.name : ""
                    font.family: Theme.font
                    font.pixelSize: Theme.smallSize
                    color: Theme.muted
                    elide: Text.ElideRight
                }

                TextField {
                    id: passwordField

                    Layout.fillWidth: true
                    implicitHeight: 32
                    placeholderText: "Пароль"
                    echoMode: TextInput.Password
                    color: Theme.fg
                    placeholderTextColor: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: 13
                    background: Rectangle {
                        color: Theme.bgMid
                        radius: 4
                        border.width: 1
                        border.color: passwordField.activeFocus
                            ? Theme.accent : Theme.surfaceHigh
                    }
                    onAccepted: root.submitPassword()
                    Keys.onEscapePressed: root.pendingNetwork = null
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Item { Layout.fillWidth: true }

                    FlatButton {
                        Layout.fillWidth: false
                        implicitWidth: 90
                        text: "Отмена"
                        onClicked: root.pendingNetwork = null
                    }

                    FlatButton {
                        Layout.fillWidth: false
                        implicitWidth: 120
                        active: true
                        text: "Подключить"
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

    onVisibleChanged: {
        if (!visible)
            root.pendingNetwork = null
    }

    // ======================================================
    // Логика Wi-Fi и батареи
    // ======================================================

    function connectNetwork(network) {
        if (!network)
            return

        if (network.connected) {
            network.disconnect()
            return
        }

        // Открытая сеть или уже известная (пароль сохранён в NM).
        if (network.known || network.security === WifiSecurityType.Open
                || network.security === WifiSecurityType.Owe) {
            network.connect()
            return
        }

        root.pendingNetwork = network
    }

    function submitPassword() {
        if (!root.pendingNetwork)
            return
        const network = root.pendingNetwork
        const psk = passwordField.text
        root.pendingNetwork = null
        network.connectWithPsk(psk)
    }

    function batteryStateText() {
        if (!root.batteryPresent)
            return "Батарея не найдена"

        const state = root.battery.state
        let text = "Неизвестно"
        if (state === UPowerDeviceState.Charging)
            text = "Зарядка"
        else if (state === UPowerDeviceState.Discharging)
            text = "Разрядка"
        else if (state === UPowerDeviceState.Empty)
            text = "Разряжена"
        else if (state === UPowerDeviceState.FullyCharged)
            text = "Заряжена"
        else if (state === UPowerDeviceState.PendingCharge)
            text = "Ожидание зарядки"
        else if (state === UPowerDeviceState.PendingDischarge)
            text = "Ожидание разрядки"

        if (state === UPowerDeviceState.Discharging && root.battery.timeToEmpty > 0)
            text += " · " + Math.round(root.battery.timeToEmpty / 60) + " мин"
        else if (state === UPowerDeviceState.Charging && root.battery.timeToFull > 0)
            text += " · " + Math.round(root.battery.timeToFull / 60) + " мин"

        return text
    }
}
