import QtQuick

Item {
    id: root

    property var notification: null
    property var theme: null

    signal actionTriggered(string actionId)

    // === Кэшированные цвета ===
    readonly property color bgColor: theme ? theme.colors.surface : "#202020"
    readonly property color bgHoverColor: theme ? theme.colors.surfaceHover : "#282828"
    readonly property color borderNormal: theme ? theme.colors.border : "#303030"
    readonly property color borderHover: theme ? theme.colors.accent : "#5B9BFF"
    readonly property color textNormal: theme ? theme.colors.text : "#FFFFFF"
    readonly property color textHover: theme ? theme.colors.textSelected : "#000000"

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
                
                // Кэшируем ID действия
                readonly property string actionId: modelData.identifier || modelData.id || ""
                readonly property string actionText: modelData.text || modelData.label || ""

                width: actionsColumn.width
                height: 30
                radius: 9

                color: actionArea.containsMouse ? root.bgHoverColor : root.bgColor
                border.width: 1
                border.color: actionArea.containsMouse ? root.borderHover : root.borderNormal

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on border.color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: parent.actionText
                    color: actionArea.containsMouse ? root.textHover : root.textNormal
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
                            root.notification.invokeAction(parent.actionId)
                        }
                        root.actionTriggered(parent.actionId)
                    }
                }
            }
        }
    }
}