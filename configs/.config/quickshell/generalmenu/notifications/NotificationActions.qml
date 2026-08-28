import QtQuick

Item {
    id: root

    property var notification: null
    property var theme: null

    signal actionTriggered(string actionId)

    property color accentColor: root.theme.colors.accent
    property color textColor: root.theme.colors.text
    property color selectedTextColor: root.theme.colors.textSelected
    property color surfaceColor: root.theme.colors.surface
    property color surfaceHoverColor: root.theme.colors.surfaceHover
    property color borderColor: root.theme.colors.border

    height: actionsColumn.implicitHeight
    width: parent ? parent.width : 0

    Column {
        id: actionsColumn
        width: parent.width
        spacing: 6

        Repeater {
            model: root.notification ? root.notification.actions : []

            delegate: Rectangle {
                required property var modelData

                width: actionsColumn.width
                height: 30
                radius: 9

                color: actionArea.containsMouse ? root.surfaceHoverColor : root.surfaceColor
                border.width: 1
                border.color: actionArea.containsMouse ? root.accentColor : root.borderColor
                antialiasing: true

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: modelData.text || modelData.label || ""
                    color: actionArea.containsMouse ? root.selectedTextColor : root.textColor
                    font.family: "Cascadia Code"
                    font.pixelSize: 10
                    font.bold: true
                    elide: Text.ElideRight
                }

                MouseArea {
                    id: actionArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (root.notification) {
                            root.notification.invokeAction(
                                modelData.identifier || modelData.id
                            )
                        }
                        root.actionTriggered(
                            modelData.identifier || modelData.id || ""
                        )
                    }
                }
            }
        }
    }
}