import QtQuick
import Quickshell
import Quickshell.Wayland

// ==========================================================
// Одно окно на все всплывающие панели.
// Quickshell 0.3 не умеет надёжно вешать PopupWindow на
// layer-shell панель (попапы отваливаются и едут по размеру),
// поэтому оверлей — обычный PanelWindow на весь экран:
// прозрачный фон, клик мимо закрывает, панель рисуется внутри.
// ==========================================================
PanelWindow {
    id: overlay

    property var bar

    readonly property string kind: (ShellState.open !== "" && ShellState.bar === bar)
        ? ShellState.open : ""

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    visible: kind !== ""
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    aboveWindows: true
    focusable: true
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    // Клик по пустому месту закрывает оверлей. Панели лежат выше
    // и перехватывают клики внутри себя.
    MouseArea {
        anchors.fill: parent
        onClicked: ShellState.hide()
    }

    // Esc закрывает любое окно оверлея. Фокус на этом Item нужен,
    // когда в окне нет поля ввода (центр управления, календарь).
    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: ShellState.hide()
    }

    ControlCenter {
        id: cc

        visible: overlay.kind === "cc"
        maxHeight: overlay.height - Theme.barHeight - 20
        x: overlay.width - width - 8
        y: Theme.barHeight + 2
    }

    Launcher {
        id: launcher

        visible: overlay.kind === "launcher"
        maxHeight: overlay.height - Theme.barHeight - 24
        x: Math.round((overlay.width - width) / 2)
        y: Theme.barHeight + 8
    }

    PowerMenu {
        id: power

        visible: overlay.kind === "power"
        x: overlay.width - width - 8
        y: Theme.barHeight + 2
    }

    Rectangle {
        id: calendarBox

        visible: overlay.kind === "calendar"
        width: 300
        height: calendar.implicitHeight + 24
        x: Math.round((overlay.width - width) / 2)
        y: Theme.barHeight + 2
        radius: Theme.popupRadius
        color: Theme.bg
        border.width: 1
        border.color: Theme.surfaceHigh

    // Клик по фону панели не должен закрывать оверлей:
        // перехватываем его до общего MouseArea в Overlay.
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        CalendarView {
            id: calendar
            anchors.fill: parent
            anchors.margins: 12
        }
    }
}
