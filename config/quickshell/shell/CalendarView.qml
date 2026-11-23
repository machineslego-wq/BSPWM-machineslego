import QtQuick
import QtQuick.Layouts

// Календарь на месяц: неделя начинается с понедельника,
// сегодня подсвечено акцентом. Никаких Qt.labs.calendar —
// сетка считается в JS, чтобы не тянуть зависимости.
Item {
    id: root

    property date cursor: new Date()
    property date today: new Date()

    readonly property int firstOffset: {
        const first = new Date(root.cursor.getFullYear(), root.cursor.getMonth(), 1)
        return (first.getDay() + 6) % 7
    }
    readonly property int daysInMonth:
        new Date(root.cursor.getFullYear(), root.cursor.getMonth() + 1, 0).getDate()

    implicitHeight: layout.implicitHeight

    // «Сегодня» должно переехать и через полночь, если панель
    // открыта сутками.
    Timer {
        interval: 60000
        repeat: true
        running: true
        onTriggered: root.today = new Date()
    }

    function shiftMonth(delta) {
        root.cursor = new Date(root.cursor.getFullYear(), root.cursor.getMonth() + delta, 1)
    }

    function isToday(day) {
        return day === root.today.getDate()
            && root.cursor.getMonth() === root.today.getMonth()
            && root.cursor.getFullYear() === root.today.getFullYear()
    }

    ColumnLayout {
        id: layout
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            BarButton {
                text: "󰁍"
                pixelSize: 14
                horizontalPadding: 6
                onClicked: root.shiftMonth(-1)
            }

            Item { Layout.fillWidth: true }

            Text {
                text: Util.monthText(root.cursor)
                font.family: Theme.font
                font.pixelSize: 13
                font.bold: true
                color: Theme.fg
            }

            Item { Layout.fillWidth: true }

            BarButton {
                text: "󰁔"
                pixelSize: 14
                horizontalPadding: 6
                onClicked: root.shiftMonth(1)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: Util.weekdaysGrid

                delegate: Text {
                    required property var modelData

                    Layout.fillWidth: true
                    text: modelData
                    font.family: Theme.font
                    font.pixelSize: 10
                    color: Theme.muted
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 7
            columnSpacing: 0
            rowSpacing: 2

            Repeater {
                model: 42

                delegate: Item {
                    required property int index

                    readonly property int day: index - root.firstOffset + 1
                    readonly property bool inMonth: day >= 1 && day <= root.daysInMonth
                    readonly property bool isToday: inMonth && root.isToday(day)

                    Layout.fillWidth: true
                    Layout.preferredHeight: 26

                    Rectangle {
                        anchors.centerIn: parent
                        width: 24
                        height: 22
                        radius: 4
                        color: parent.isToday ? Theme.accent : "transparent"
                    }

                    Text {
                        anchors.centerIn: parent
                        text: parent.inMonth ? parent.day : ""
                        font.family: Theme.font
                        font.pixelSize: 12
                        font.bold: parent.isToday
                        color: parent.isToday ? Theme.bg : Theme.fgDim
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 4
        }

        BarButton {
            text: "Сегодня"
            Layout.alignment: Qt.AlignHCenter
            pixelSize: Theme.smallSize
            dimmed: root.cursor.getMonth() === root.today.getMonth()
                && root.cursor.getFullYear() === root.today.getFullYear()
            onClicked: root.cursor = new Date()
        }
    }
}
