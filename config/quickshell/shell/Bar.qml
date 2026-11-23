import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.I3
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower

// ==========================================================
// Панель Sway (замена waybar): островки слева, в центре и
// справа. Слева — лаунчер и столы, в центре — часы и батарея,
// справа — трей, раскладка, профиль питания, звук, яркость,
// Bluetooth, сеть и меню питания.
// ==========================================================
PanelWindow {
    id: bar

    required property var modelData
    screen: modelData

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: Theme.barHeight
    color: Theme.bg
    exclusiveZone: Theme.barHeight

    Component.onCompleted: ShellState.register(bar)
    Component.onDestruction: ShellState.unregister(bar)

    // --- Рабочие столы этого монитора ---
    readonly property var workspaces: {
        const list = I3.workspaces.values
        const screenName = bar.screen ? bar.screen.name : ""
        const out = []
        for (let i = 0; i < list.length; i++) {
            const ws = list[i]
            let monitor = null
            try {
                monitor = ws.monitor
            } catch (e) {
                monitor = null
            }
            if (!monitor || !screenName || monitor.name === screenName)
                out.push(ws)
        }
        out.sort((a, b) => a.number - b.number)
        return out
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

    readonly property var wifiNetwork: {
        if (!bar.wifiDevice)
            return null
        const networks = bar.wifiDevice.networks.values
        for (let i = 0; i < networks.length; i++) {
            if (networks[i].connected)
                return networks[i]
        }
        return null
    }

    readonly property bool wiredConnected: {
        const devices = Networking.devices.values
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].type === DeviceType.Wired && devices[i].connected)
                return true
        }
        return false
    }

    // --- Bluetooth ---
    readonly property var btAdapter: Bluetooth.defaultAdapter
    readonly property int btConnections: {
        let count = 0
        const devices = Bluetooth.devices.values
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].connected)
                count++
        }
        return count
    }

    // --- Батарея ---
    readonly property var battery: UPower.displayDevice
    readonly property bool batteryPresent: battery !== null && battery.isPresent
    readonly property int batteryPercent: {
        if (!bar.batteryPresent)
            return 0
        const p = bar.battery.percentage
        return Math.round(Math.max(0, Math.min(100, p <= 1 ? p * 100 : p)))
    }
    readonly property bool batteryCharging: bar.batteryPresent
        && (bar.battery.state === UPowerDeviceState.Charging
            || bar.battery.state === UPowerDeviceState.FullyCharged)

    // --- Часы ---
    property date now: new Date()

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: bar.now = new Date()
    }

    // Клик по пустому месту панели закрывает всплывающие окна.
    MouseArea {
        anchors.fill: parent
        onClicked: ShellState.hide()
    }

    // ======================================================
    // Левый островок: лаунчер и столы
    // ======================================================
    Rectangle {
        id: leftIsland

        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        height: 24
        width: leftRow.implicitWidth + 8
        radius: Theme.radius
        color: Theme.surface

        MouseArea {
            anchors.fill: parent
            onWheel: (wheel) => I3.dispatch(wheel.angleDelta.y > 0
                ? "workspace prev_on_output"
                : "workspace next_on_output")
        }

        RowLayout {
            id: leftRow
            anchors.centerIn: parent
            spacing: 1

            BarButton {
                text: "\uf306"
                pixelSize: 16
                horizontalPadding: 5
                onClicked: ShellState.show("launcher", bar)
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 14
                color: Theme.muted
                opacity: 0.4
            }

            Repeater {
                model: bar.workspaces

                delegate: BarButton {
                    required property var modelData

                    text: modelData.name
                    active: modelData.focused
                    dimmed: !modelData.focused && !modelData.active
                    pixelSize: Theme.fontSize
                    horizontalPadding: 7
                    onClicked: I3.dispatch("workspace " + bar.quoteWorkspace(modelData.name))
                }
            }
        }
    }

    // ======================================================
    // Центр: часы и батарея
    // ======================================================
    Rectangle {
        id: centerIsland

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        height: 24
        width: centerRow.implicitWidth + 10
        radius: Theme.radius
        color: Theme.surface

        RowLayout {
            id: centerRow
            anchors.centerIn: parent
            spacing: 2

            BarButton {
                text: Util.timeText(bar.now)
                bold: true
                pixelSize: 13
                horizontalPadding: 6
                onClicked: ShellState.show("calendar", bar)
            }

            BarButton {
                text: "󰃭 " + Util.dateText(bar.now)
                normalColor: Theme.fgDim
                pixelSize: 12
                horizontalPadding: 6
                onClicked: ShellState.show("calendar", bar)
            }

            Rectangle {
                visible: bar.batteryPresent
                Layout.preferredWidth: 1
                Layout.preferredHeight: 14
                color: Theme.muted
                opacity: 0.4
            }

            StatusItem {
                visible: bar.batteryPresent
                text: Util.batteryIcon(bar.batteryPercent, bar.batteryCharging)
                    + " " + bar.batteryPercent + "%"
                color: bar.batteryPercent <= 15 ? Theme.error
                    : bar.batteryCharging ? Theme.success
                    : Theme.fg
                onClicked: ShellState.show("cc", bar)
            }
        }
    }

    // ======================================================
    // Правый островок
    // ======================================================
    Rectangle {
        id: rightIsland

        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        height: 24
        width: rightRow.implicitWidth + 8
        radius: Theme.radius
        color: Theme.surface

        RowLayout {
            id: rightRow
            anchors.centerIn: parent
            spacing: 1

            // Системный трей
            Repeater {
                model: SystemTray.items

                delegate: Item {
                    required property var modelData

                    implicitWidth: 22
                    implicitHeight: 22

                    Image {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        source: Util.iconSource(modelData.icon)
                        sourceSize.width: 16
                        sourceSize.height: 16
                        fillMode: Image.PreserveAspectFit
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: modelData.activate()
                    }
                }
            }

            StatusItem {
                text: InputState.layout
                pixelSize: 12
                onClicked: ShellState.show("cc", bar)
            }

            StatusItem {
                visible: InputState.caps
                text: "󰘲"
                color: Theme.warning
                pixelSize: 13
                onClicked: ShellState.show("cc", bar)
            }

            // Профиль питания: клик переключает по кругу.
            StatusItem {
                text: PowerProfiles.profile === PowerProfile.Performance ? "PERF"
                    : PowerProfiles.profile === PowerProfile.PowerSaver ? "ECO"
                    : "BAL"
                color: PowerProfiles.profile === PowerProfile.Performance ? Theme.error
                    : PowerProfiles.profile === PowerProfile.PowerSaver ? Theme.success
                    : Theme.fg
                onClicked: bar.cycleProfile()
                onRightClicked: ShellState.show("cc", bar)
            }

            StatusItem {
                text: Util.volumeIcon(Volume.percent, Volume.muted)
                    + (Volume.available
                        ? (Volume.muted ? " MUTE" : " " + Volume.percent + "%")
                        : "")
                color: Volume.muted ? Theme.muted : Theme.fg
                onClicked: ShellState.show("cc", bar)
                onRightClicked: Quickshell.execDetached(["pavucontrol-qt"])
                onWheeled: (delta) => Volume.step(delta > 0 ? 5 : -5)
            }

            StatusItem {
                text: Util.brightnessIcon(Brightness.percent) + " " + Brightness.percent + "%"
                visible: Brightness.available
                onClicked: ShellState.show("cc", bar)
                onWheeled: (delta) => Brightness.step(delta > 0 ? 5 : -5)
            }

            StatusItem {
                text: Util.bluetoothIcon(bar.btAdapter !== null
                    && bar.btAdapter.enabled, bar.btConnections)
                    + (bar.btAdapter !== null && bar.btAdapter.enabled
                        ? (bar.btConnections > 0 ? " " + bar.btConnections : " ON")
                        : " OFF")
                color: bar.btAdapter !== null && bar.btAdapter.enabled ? Theme.fg : Theme.muted
                onClicked: ShellState.show("cc", bar)
            }

            StatusItem {
                text: bar.wiredConnected && !(bar.wifiNetwork)
                    ? "󰈀"
                    : (Networking.wifiEnabled
                        ? Util.wifiIcon(bar.wifiNetwork ? bar.wifiNetwork.signalStrength : 0)
                        : "󰤮")
                color: bar.wifiNetwork || bar.wiredConnected ? Theme.fg : Theme.muted
                onClicked: ShellState.show("cc", bar)
            }

            StatusItem {
                text: "󰐥"
                pixelSize: 15
                color: Theme.accent
                onClicked: ShellState.show("power", bar)
            }
        }
    }

    // ======================================================
    // Всплывающие панели
    // ======================================================
    Overlay {
        bar: bar
    }

    // Имена столов в конфиге числовые, но dispatch требует кавычек,
    // если в имени есть пробел.
    function quoteWorkspace(name) {
        return String(name).indexOf(" ") === -1 ? name : "'" + name + "'"
    }

    function cycleProfile() {
        if (PowerProfiles.profile === PowerProfile.Balanced)
            PowerProfiles.profile = PowerProfiles.hasPerformanceProfile
                ? PowerProfile.Performance
                : PowerProfile.PowerSaver
        else if (PowerProfiles.profile === PowerProfile.Performance)
            PowerProfiles.profile = PowerProfile.PowerSaver
        else
            PowerProfiles.profile = PowerProfile.Balanced
    }
}
