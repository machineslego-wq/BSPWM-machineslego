import QtQuick

// Индикатор в правом островке панели: текст/иконка, левый и
// правый клик, прокрутка. Без подложки — островок уже даёт фон.
Item {
    id: root

    property string text: ""
    property color color: Theme.fg
    property int pixelSize: Theme.fontSize

    signal clicked()
    signal rightClicked()
    signal wheeled(int delta)

    implicitWidth: label.implicitWidth + 10
    implicitHeight: 22

    Rectangle {
        anchors.fill: parent
        radius: 4
        color: mouse.containsMouse ? Theme.surfaceHigh : "transparent"
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        font.family: Theme.font
        font.pixelSize: root.pixelSize
        color: root.color
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: (event) => {
            if (event.button === Qt.RightButton)
                root.rightClicked()
            else
                root.clicked()
        }
        onWheel: (wheel) => root.wheeled(wheel.angleDelta.y)
    }
}
