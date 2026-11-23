import QtQuick
import QtQuick.Layouts

// Ползунок громкости/яркости. Не QtQuick.Controls.Slider:
// у Controls своя высота и стиль, а здесь нужен тонкий трек
// и полный контроль над перетаскиванием.
//
// value только читается (биндинг на сервис): пользователь двигает
// ползунок, компонент отдаёт moved(v), сервис меняет значение,
// биндинг возвращает новое value. Так нет эха и рассинхрона.
Item {
    id: root

    property string icon: ""
    property string valueText: ""
    property real value: 0
    property color accentColor: Theme.accent
    property bool enabled: true

    signal moved(real v)
    signal iconClicked()
    signal iconWheeled(int delta)

    implicitHeight: 26
    Layout.fillWidth: true
    opacity: enabled ? 1 : 0.5

    RowLayout {
        anchors.fill: parent
        spacing: 10

        Item {
            Layout.preferredWidth: 20
            Layout.fillHeight: true

            Text {
                anchors.centerIn: parent
                text: root.icon
                font.family: Theme.font
                font.pixelSize: 15
                color: root.enabled ? Theme.fg : Theme.muted
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.iconClicked()
                onWheel: (wheel) => root.iconWheeled(wheel.angleDelta.y)
            }
        }

        Rectangle {
            id: track
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            radius: 3
            color: Theme.bgMid

            Rectangle {
                width: track.width * Math.max(0, Math.min(1, root.value))
                height: parent.height
                radius: 3
                color: root.enabled ? root.accentColor : Theme.muted
            }

            Rectangle {
                width: 8
                height: 14
                radius: 3
                color: root.enabled ? root.accentColor : Theme.muted
                x: Math.max(0, Math.min(track.width - width,
                    track.width * Math.max(0, Math.min(1, root.value)) - width / 2))
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                // область захвата шире трека: 6 px мышью не поймать
                anchors.fill: parent
                anchors.topMargin: -8
                anchors.bottomMargin: -8
                enabled: root.enabled
                cursorShape: Qt.PointingHandCursor

                function apply(x) {
                    const v = Math.max(0, Math.min(1, x / width))
                    root.moved(v)
                }

                onPressed: (mouse) => apply(mouse.x)
                onPositionChanged: (mouse) => {
                    if (pressed)
                        apply(mouse.x)
                }
                onWheel: (wheel) => root.iconWheeled(wheel.angleDelta.y)
            }
        }

        Text {
            Layout.preferredWidth: 42
            text: root.valueText
            font.family: Theme.font
            font.pixelSize: Theme.smallSize
            color: Theme.fgDim
            horizontalAlignment: Text.AlignRight
        }
    }
}
