import QtQuick
import Quickshell
import Quickshell.Hyprland

Item {
    id: root

    property var theme: null
    property var topbarManager: null
    property bool isVertical: false

    implicitWidth: root.isVertical ? 28 : workspacesRow.implicitWidth
    implicitHeight: root.isVertical ? workspacesColumn.implicitHeight : 28

    readonly property var colors: root.theme ? root.theme.colors : ({
        "background": "#181818",
        "surface": "#202020",
        "surfaceHover": "#282828",
        "accent": "#3675FF",
        "text": "#FFFFFF",
        "textSecondary": "#A0A0A0",
        "textSelected": "#000000"
    })

    // ============================================================
    // ГОРИЗОНТАЛЬНЫЙ РЕЖИМ
    // ============================================================
    Row {
        id: workspacesRow
        visible: !root.isVertical
        anchors.fill: parent
        spacing: 4

        Repeater {
            model: Hyprland.workspaces

            delegate: Rectangle {
                required property var model
                required property int index
                
                width: 26
                height: 26
                radius: 8

                anchors.verticalCenter: parent.verticalCenter

                color: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === model.id
                    ? root.colors.accent
                    : wsMa.containsMouse
                        ? root.colors.surfaceHover
                        : "transparent"

                border.width: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === model.id ? 0 : 1
                border.color: root.colors.surfaceHover

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: model.id !== undefined ? String(model.id) : String(index + 1)
                    font.family: "Cascadia Code"
                    font.pixelSize: 11
                    font.weight: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === model.id ? Font.Bold : Font.Normal
                    color: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === model.id
                        ? root.colors.textSelected
                        : root.colors.text
                }

                MouseArea {
                    id: wsMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace", String(model.id !== undefined ? model.id : index + 1))
                }
            }
        }
    }

    // ============================================================
    // ВЕРТИКАЛЬНЫЙ РЕЖИМ
    // ============================================================
    Column {
        id: workspacesColumn
        visible: root.isVertical
        anchors.fill: parent
        spacing: 4

        Repeater {
            model: Hyprland.workspaces

            delegate: Rectangle {
                required property var model
                required property int index
                
                width: 26
                height: 26
                radius: 8

                anchors.horizontalCenter: parent.horizontalCenter

                color: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === model.id
                    ? root.colors.accent
                    : wsMaV.containsMouse
                        ? root.colors.surfaceHover
                        : "transparent"

                border.width: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === model.id ? 0 : 1
                border.color: root.colors.surfaceHover

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: model.id !== undefined ? String(model.id) : String(index + 1)
                    font.family: "Cascadia Code"
                    font.pixelSize: 11
                    font.weight: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === model.id ? Font.Bold : Font.Normal
                    color: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === model.id
                        ? root.colors.textSelected
                        : root.colors.text
                }

                MouseArea {
                    id: wsMaV
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace", String(model.id !== undefined ? model.id : index + 1))
                }
            }
        }
    }
}