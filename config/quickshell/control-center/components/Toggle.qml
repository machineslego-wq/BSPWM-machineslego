import QtQuick

Rectangle {
    id: toggle

    property bool on: false

    signal toggled()

    implicitWidth: 38
    implicitHeight: 20
    radius: 3
    color: on ? Theme.accent : Theme.bg
    border.width: 1
    border.color: on ? Theme.accent : Theme.muted

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
