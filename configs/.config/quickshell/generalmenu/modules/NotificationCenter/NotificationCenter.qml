import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../../notifications"

Item {
    id: root

    property var notificationList: null
    property var theme: null

    signal requestClose(var notification)
    signal requestClear()

    readonly property string clickSoundPath: Quickshell.shellDir + "/sounds/clicks.wav"

    function playClick() {
        Quickshell.execDetached(["sh", "-c", "pw-play '" + clickSoundPath + "' 2>/dev/null || paplay '" + clickSoundPath + "' 2>/dev/null || true"])
    }

    readonly property color backgroundColor: root.theme.colors.surface
    readonly property color borderColor: root.theme.colors.border
    readonly property color textColor: root.theme.colors.text
    readonly property color secondaryTextColor: root.theme.colors.textSecondary
    readonly property color disabledTextColor: root.theme.colors.textDisabled
    readonly property color hoverColor: root.theme.colors.surfaceHover
    readonly property color accentColor: root.theme.colors.accent
    readonly property color surfaceSelectedColor: root.theme.colors.surfaceSelected
    readonly property color dangerColor: "#FF453A"

    Rectangle {
        id: mainBlock
        anchors.fill: parent
        radius: 16
        color: root.backgroundColor
        border.width: 1
        border.color: root.borderColor
        clip: true

        ColumnLayout {
            id: contentLayout
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Column {
                    spacing: 2
                    Text {
                        text: "Уведомления"
                        color: root.textColor
                        font.pixelSize: 15
                        font.bold: true
                    }
                    Text {
                        text: root.notificationList != null && root.notificationList.count > 0
                              ? root.notificationList.count + " новых"
                              : "Всё прочитано"
                        color: root.secondaryTextColor
                        font.pixelSize: 11
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: clearArea.containsMouse ? Qt.rgba(root.dangerColor.r, root.dangerColor.g, root.dangerColor.b, 0.15) : "transparent"
                    border.width: 1
                    border.color: clearArea.containsMouse ? root.dangerColor : "transparent"
                    visible: root.notificationList != null && root.notificationList.count > 0
                    scale: clearArea.pressed ? 0.9 : (clearArea.containsMouse ? 1.05 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                    Text {
                        anchors.centerIn: parent
                        text: "󰆴"
                        font.family: "JetBrainsMono Nerd Font"
                        color: clearArea.containsMouse ? root.dangerColor : root.secondaryTextColor
                        font.pixelSize: 16
                    }

                    MouseArea {
                        id: clearArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: root.playClick()
                        onClicked: root.requestClear()
                    }

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.borderColor
                opacity: 0.5
            }

            Flickable {
                id: flickable
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: notifColumn.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                visible: root.notificationList != null && root.notificationList.count > 0

                ScrollBar.vertical: ScrollBar {
                    id: verticalScrollBar
                    policy: ScrollBar.AsNeeded
                    width: 8
                    contentItem: Rectangle {
                        implicitWidth: 8
                        radius: 4
                        color: root.accentColor
                        opacity: verticalScrollBar.pressed ? 1.0 : 0.6
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }
                    background: Rectangle {
                        radius: 4
                        color: root.surfaceSelectedColor
                        opacity: 0.4
                    }
                }

                Column {
                    id: notifColumn
                    width: parent.width - verticalScrollBar.width - 12
                    spacing: 10

                    Repeater {
                        model: root.notificationList
                        delegate: NotificationCard {
                            width: notifColumn.width
                            notification: model.notification
                            theme: root.theme
                            autoClose: false
                            onClosed: root.requestClose(model.notification)
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: root.notificationList == null || root.notificationList.count === 0

                Column {
                    anchors.centerIn: parent
                    spacing: 10
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰂚"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 42
                        color: root.disabledTextColor
                        opacity: 0.5
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Нет новых уведомлений"
                        color: root.disabledTextColor
                        font.pixelSize: 13
                        font.bold: true
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Они появятся здесь, когда придут"
                        color: root.disabledTextColor
                        font.pixelSize: 11
                        opacity: 0.7
                    }
                }
            }
        }
    }
}