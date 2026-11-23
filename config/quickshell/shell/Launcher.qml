import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

// ==========================================================
// Лаунчер приложений (замена wofi --show drun).
// Список .desktop берётся из Quickshell.DesktopEntries, поиск —
// по имени, genericName и комментарию. Управление: стрелки,
// Enter, Esc; клик по строке запускает приложение.
// ==========================================================
Item {
    id: root

    property int maxHeight: 520

    width: 640
    height: Math.min(520, maxHeight)

    focus: true

    // Клик по фону панели не должен закрывать оверлей:
    // перехватываем его до общего MouseArea в Overlay.
    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    property var results: []
    property int selected: 0

    // DesktopEntries заполняется асинхронно при первом обращении:
    // без этого хвоста первый открытый лаунчер показывал пустой список.
    readonly property int appCount: DesktopEntries.applications.values.length
    onAppCountChanged: if (visible) root.updateResults()

    function baseEntries() {
        return DesktopEntries.applications.values
            .filter(entry => !entry.noDisplay)
            .sort((a, b) => a.name.localeCompare(b.name))
    }

    function updateResults() {
        const query = input.text.trim().toLowerCase()
        const entries = root.baseEntries()
        if (query === "") {
            root.results = entries
        } else {
            const tokens = query.split(/\s+/)
            root.results = entries.filter(entry => {
                const haystack = ((entry.name || "") + " "
                    + (entry.genericName || "") + " "
                    + (entry.comment || "")).toLowerCase()
                for (let i = 0; i < tokens.length; i++) {
                    if (haystack.indexOf(tokens[i]) === -1)
                        return false
                }
                return true
            })
        }
        root.selected = 0
        appList.positionViewAtBeginning()
    }

    function move(delta) {
        if (root.results.length === 0)
            return
        root.selected = Math.max(0, Math.min(root.results.length - 1,
            root.selected + delta))
        appList.positionViewAtIndex(root.selected, ListView.Contain)
    }

    function launchSelected() {
        if (root.selected < 0 || root.selected >= root.results.length)
            return
        const entry = root.results[root.selected]
        ShellState.hide()
        entry.execute()
    }

    onVisibleChanged: {
        if (visible) {
            input.text = ""
            root.updateResults()
            input.forceActiveFocus()
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.popupRadius
        color: Theme.bg
        border.width: 1
        border.color: Theme.surfaceHigh

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 36
                radius: 4
                color: Theme.bgMid
                border.width: 1
                border.color: input.activeFocus ? Theme.accent : Theme.surfaceHigh

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        text: "󰍉"
                        font.family: Theme.font
                        font.pixelSize: 14
                        color: Theme.muted
                    }

                    TextField {
                        id: input

                        Layout.fillWidth: true
                        placeholderText: "Поиск приложений…"
                        color: Theme.fg
                        placeholderTextColor: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: 13
                        background: Item {}

                        onTextChanged: root.updateResults()
                        onAccepted: root.launchSelected()

                        Keys.onDownPressed: {
                            root.move(1)
                            event.accepted = true
                        }
                        Keys.onUpPressed: {
                            root.move(-1)
                            event.accepted = true
                        }
                        Keys.onEscapePressed: {
                            ShellState.hide()
                            event.accepted = true
                        }
                    }
                }
            }

            ListView {
                id: appList

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: root.results
                currentIndex: root.selected
                boundsBehavior: Flickable.StopAtBounds
                spacing: 1

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    width: appList.width
                    height: 44
                    radius: 4
                    color: index === root.selected ? Theme.surface
                        : rowHover.hovered ? Theme.surfaceHigh
                        : "transparent"

                    HoverHandler { id: rowHover }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.selected = index
                        onClicked: {
                            root.selected = index
                            root.launchSelected()
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 10

                        Image {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            source: Util.iconSource(modelData.icon)
                            sourceSize.width: 24
                            sourceSize.height: 24
                            fillMode: Image.PreserveAspectFit
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                text: modelData.name
                                font.family: Theme.font
                                font.pixelSize: 13
                                color: index === root.selected ? Theme.accent : Theme.fg
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.comment || modelData.genericName || ""
                                font.family: Theme.font
                                font.pixelSize: 10
                                color: Theme.muted
                                elide: Text.ElideRight
                                visible: text !== ""
                            }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.results.length === 0
                    text: "Ничего не найдено"
                    font.family: Theme.font
                    font.pixelSize: 12
                    color: Theme.muted
                }
            }
        }
    }
}
