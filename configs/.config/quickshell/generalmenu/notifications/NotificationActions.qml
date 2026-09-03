import QtQuick

Item {
    id: root

    property var notification: null
    property var theme: null

    signal actionTriggered(string actionId)

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

                color: actionArea.containsMouse ? root.theme.colors.surfaceHover : root.theme.colors.surface
                border.width: 1
                border.color: actionArea.containsMouse ? root.theme.colors.accent : root.theme.colors.border
                antialiasing: true

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: modelData.text || modelData.label || ""
                    color: actionArea.containsMouse ? root.theme.colors.textSelected : root.theme.colors.text
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