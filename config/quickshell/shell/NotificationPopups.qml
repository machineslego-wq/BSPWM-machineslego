import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.I3
import Quickshell.Wayland

// ==========================================================
// Всплывающие уведомления под панелью (справа).
// Отдельное окно, а не оверлей: оно не забирает клавиатуру и
// не мешает работать. Показывается только на фокусном мониторе.
// ==========================================================
PanelWindow {
    id: root

    property var bar

    readonly property bool onFocusedScreen: {
        if (!bar || !bar.screen)
            return true
        return I3.focusedMonitor
            ? I3.focusedMonitor.name === bar.screen.name
            : true
    }

    visible: Notify.active.length > 0 && root.onFocusedScreen

    anchors.top: true
    anchors.right: true
    margins.top: Theme.barHeight + 8
    margins.right: 8
    implicitWidth: 360
    implicitHeight: stack.implicitHeight

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    aboveWindows: true
    WlrLayershell.layer: WlrLayer.Overlay

    ColumnLayout {
        id: stack

        anchors.fill: parent
        spacing: 6

        Repeater {
            model: Notify.active

            delegate: Rectangle {
                id: card

                required property var modelData

                Layout.fillWidth: true
                implicitHeight: content.implicitHeight + 20
                radius: 6
                color: Theme.bg
                border.width: 1
                border.color: modelData.urgency >= 2 ? Theme.error : Theme.surfaceHigh

                // Клик по карточке: действие по умолчанию или закрыть.
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        const actions = card.modelData.actions || []
                        let fallback = null
                        for (let i = 0; i < actions.length; i++) {
                            if (actions[i].identifier === "default")
                                fallback = actions[i]
                        }
                        if (fallback)
                            Notify.invoke(card.modelData, fallback)
                        else
                            Notify.dismiss(card.modelData)
                    }
                }

                ColumnLayout {
                    id: content

                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    // --- OSD громкости (wpctl-volume) ---
                    RowLayout {
                        visible: card.modelData.isOsd
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: Util.volumeIcon(card.modelData.value,
                                Volume.muted)
                            font.family: Theme.font
                            font.pixelSize: 16
                            color: Theme.fg
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 6
                            radius: 3
                            color: Theme.bgMid

                            Rectangle {
                                width: parent.width * Math.max(0,
                                    Math.min(1, card.modelData.value / 100))
                                height: parent.height
                                radius: 3
                                color: Theme.accent
                            }
                        }

                        Text {
                            text: card.modelData.value >= 0
                                ? card.modelData.value + "%" : ""
                            font.family: Theme.font
                            font.pixelSize: 12
                            color: Theme.fgDim
                        }
                    }

                    // --- Обычное уведомление ---
                    RowLayout {
                        visible: !card.modelData.isOsd
                        Layout.fillWidth: true
                        spacing: 6

                        Image {
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                            visible: card.modelData.appIcon !== ""
                            source: Util.iconSource(card.modelData.appIcon)
                            sourceSize.width: 16
                            sourceSize.height: 16
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            Layout.fillWidth: true
                            text: card.modelData.appName
                            font.family: Theme.font
                            font.pixelSize: 10
                            color: Theme.muted
                            elide: Text.ElideRight
                        }

                        BarButton {
                            text: "󰅖"
                            pixelSize: 12
                            horizontalPadding: 4
                            onClicked: Notify.dismiss(card.modelData)
                        }
                    }

                    Text {
                        visible: !card.modelData.isOsd
                        Layout.fillWidth: true
                        text: card.modelData.summary
                        font.family: Theme.font
                        font.pixelSize: 12
                        font.bold: true
                        color: card.modelData.urgency >= 2 ? Theme.error : Theme.fg
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: !card.modelData.isOsd && card.modelData.body !== ""
                        Layout.fillWidth: true
                        text: card.modelData.body
                        font.family: Theme.font
                        font.pixelSize: 11
                        color: Theme.fgDim
                        wrapMode: Text.WordWrap
                        maximumLineCount: 4
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        visible: !card.modelData.isOsd
                            && card.modelData.actions.length > 0
                        Layout.fillWidth: true
                        spacing: 4

                        Repeater {
                            model: card.modelData.actions

                            delegate: BarButton {
                                required property var modelData

                                text: modelData.text
                                pixelSize: Theme.smallSize
                                normalColor: Theme.accent
                                onClicked: Notify.invoke(card.modelData, modelData)
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }
                }
            }
        }
    }
}
