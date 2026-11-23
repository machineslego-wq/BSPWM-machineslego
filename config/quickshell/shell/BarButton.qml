import QtQuick

// Кнопка-текст для панели и карточек: подсветка при наведении,
// заливка акцентом в активном состоянии. Без Controls — панель
// не должна зависеть от стиля Qt Quick Controls.
Item {
    id: root

    property string text: ""
    property bool active: false
    property bool dimmed: false
    property color activeBg: Theme.accent
    property color activeFg: Theme.bg
    property color normalColor: Theme.fg
    property int pixelSize: Theme.fontSize
    property bool bold: false
    property int horizontalPadding: 6

    signal clicked()

    implicitWidth: label.implicitWidth + horizontalPadding * 2
    implicitHeight: 22

    Rectangle {
        anchors.fill: parent
        radius: 4
        color: root.active
            ? root.activeBg
            : (mouse.containsMouse ? Theme.surfaceHigh : "transparent")
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        font.family: Theme.font
        font.pixelSize: root.pixelSize
        font.bold: root.bold
        color: root.active ? root.activeFg
            : root.dimmed ? Theme.muted
            : root.normalColor
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
