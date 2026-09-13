import QtQuick

Item {
    id: root

    property var notification: null
    property var theme: null

    signal actionTriggered(string actionId)

    // === Кэшированные цвета ===
    readonly property color bgColor: theme ? theme.colors.surfaceSelected : "#2C3A50"
    readonly property color bgHoverColor: theme ? theme.colors.surfaceHover : "#354258"
    readonly property color accentColor: theme ? theme.colors.accent : "#5B9BFF"
    readonly property color borderNormal: theme ? theme.colors.border : "#303030"
    readonly property color textNormal: theme ? theme.colors.text : "#FFFFFF"
    readonly property color textHover: theme ? theme.colors.textSelected : "#000000"

    height: actionsColumn.implicitHeight
    width: parent ? parent.width : 0

    Column {
        id: actionsColumn
        width: parent.width
        spacing: 5

        Repeater {
            model: root.notification ? root.notification.actions : []

            delegate: Rectangle {
                required property var modelData
                
                readonly property string actionId: modelData.identifier || modelData.id || ""
                readonly property string actionText: modelData.text || modelData.label || ""

                width: actionsColumn.width
                height: 28
                radius: 8

                color: actionArea.containsMouse ? root.accentColor : root.bgColor
                border.width: 1
                border.color: actionArea.containsMouse 
                    ? root.accentColor 
                    : root.borderNormal

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
                
                scale: actionArea.pressed ? 0.96 : (actionArea.containsMouse ? 1.02 : 1.0)
                Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    
                    // Иконка действия
                    Text {
                        visible: index === 0  // Иконка только для первого действия
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰜴"  // arrow-right
                        color: actionArea.containsMouse ? root.textHover : root.accentColor
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: actionText
                        color: actionArea.containsMouse ? root.textHover : root.textNormal
                        font.family: "Cascadia Code"
                        font.pixelSize: 10
                        font.weight: actionArea.containsMouse ? Font.Bold : Font.DemiBold
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }

                MouseArea {
                    id: actionArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.notification) {
                            root.notification.invokeAction(actionId)
                        }
                        root.actionTriggered(actionId)
                    }
                }
            }
        }
    }
}