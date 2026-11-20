import QtQuick
import QtQuick.Layouts

Rectangle {
    id: card
    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 20
    radius: 2
    color: Theme.surface

    default property alias content: content.data

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8
    }
}
