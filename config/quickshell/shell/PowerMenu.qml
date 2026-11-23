import QtQuick
import QtQuick.Layouts
import Quickshell

// Меню питания по кнопке в правом островке панели.
// Действия выполняются сразу, без подтверждения — как
// в local/bin/powermenu.
Item {
    id: root

    width: 210
    height: column.implicitHeight + 16

    focus: true
    Keys.onEscapePressed: ShellState.hide()

    // Клик по фону панели не должен закрывать оверлей:
    // перехватываем его до общего MouseArea в Overlay.
    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    function run(command) {
        ShellState.hide()
        Quickshell.execDetached(command)
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.popupRadius
        color: Theme.bg
        border.width: 1
        border.color: Theme.surfaceHigh

        focus: true
        Keys.onEscapePressed: ShellState.hide()

        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.margins: 8
            spacing: 2

            Repeater {
                model: [
                    { icon: "󰌾", label: "Блокировка", action: ["swaylock", "-f"] },
                    { icon: "󰒲", label: "Сон", action: ["systemctl", "suspend"] },
                    { icon: "󰍃", label: "Выход", action: ["swaymsg", "exit"] },
                    { icon: "󰜉", label: "Перезагрузка", action: ["systemctl", "reboot"] },
                    { icon: "󰐥", label: "Выключить", action: ["systemctl", "poweroff"] }
                ]

                delegate: Rectangle {
                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: 30
                    radius: 4
                    color: rowHover.hovered ? Theme.surfaceHigh : "transparent"

                    HoverHandler { id: rowHover }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        text: modelData.icon
                        font.family: Theme.font
                        font.pixelSize: 14
                        color: modelData.label === "Выключить" ? Theme.error : Theme.fg
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 32
                        text: modelData.label
                        font.family: Theme.font
                        font.pixelSize: 12
                        color: modelData.label === "Выключить" ? Theme.error : Theme.fg
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.run(modelData.action)
                    }
                }
            }
        }
    }
}
