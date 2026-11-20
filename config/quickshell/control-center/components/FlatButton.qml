import QtQuick

Rectangle {
    id: button

    property string text: ""
    property bool active: false
    property bool danger: false
    property bool small: false

    signal clicked()

    implicitWidth: label.implicitWidth + (small ? 16 : 22)
    implicitHeight: small ? 22 : 30
    radius: 2
    color: active ? Theme.accent
        : danger ? Theme.bg
        : mouse.containsMouse ? Theme.surface
        : Theme.bg
    border.width: danger ? 1 : 0
    border.color: Theme.error
    opacity: enabled ? 1 : 0.45

    Txt {
        id: label
        anchors.centerIn: parent
        text: button.text
        font.pixelSize: button.small ? 11 : 12
        color: button.active ? Theme.bg
            : button.danger ? Theme.error
            : Theme.fg
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
