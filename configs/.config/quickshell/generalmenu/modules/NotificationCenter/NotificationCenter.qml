import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../../notifications"

Item {
    id: root

    property var notificationList: null
    property var theme: null
    property var soundPlayer: null

    signal requestClose(var notification)
    signal requestClear()

    Rectangle {
        id: mainBlock
        anchors.fill: parent
        radius: 16
        color: root.theme ? root.theme.colors.surface : "#1A1F26"
        border.width: 1
        border.color: root.theme ? root.theme.colors.border : "#2A323D"
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
                        color: root.theme ? root.theme.colors.text : "#F0F4F8"
                        font.pixelSize: 15
                        font.bold: true
                    }
                    Text {
                        text: root.notificationList != null && root.notificationList.count > 0
                              ? root.notificationList.count + " новых"
                              : "Всё прочитано"
                        color: root.theme ? root.theme.colors.textSecondary : "#9AA9B9"
                        font.pixelSize: 11
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: clearArea.containsMouse 
                           ? Qt.rgba(1.0, 0.27, 0.23, 0.15) 
                           : "transparent"
                    border.width: 1
                    border.color: clearArea.containsMouse 
                                  ? "#FF453A" 
                                  : "transparent"
                    visible: root.notificationList != null && root.notificationList.count > 0
                    scale: clearArea.pressed ? 0.9 : (clearArea.containsMouse ? 1.05 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                    Text {
                        anchors.centerIn: parent
                        text: "󰆴"
                        font.family: "JetBrainsMono Nerd Font"
                        color: clearArea.containsMouse 
                               ? "#FF453A" 
                               : (root.theme ? root.theme.colors.textSecondary : "#9AA9B9")
                        font.pixelSize: 16
                    }

                    MouseArea {
                        id: clearArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.soundPlayer) root.soundPlayer.play("quick_click.wav")
                            root.requestClear()
                        }
                    }

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.theme ? root.theme.colors.border : "#2A323D"
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
                        color: root.theme ? root.theme.colors.accent : "#5B9BFF"
                        opacity: verticalScrollBar.pressed ? 1.0 : 0.6
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }
                    background: Rectangle {
                        radius: 4
                        color: root.theme ? root.theme.colors.surfaceSelected : "#2C3A50"
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
                            onClosed: {
                                if (root.soundPlayer) root.soundPlayer.play("tick.wav")
                                root.requestClose(model.notification)
                            }
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
                        color: root.theme ? root.theme.colors.textDisabled : "#5A6675"
                        opacity: 0.5
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Нет новых уведомлений"
                        color: root.theme ? root.theme.colors.textDisabled : "#5A6675"
                        font.pixelSize: 13
                        font.bold: true
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Они появятся здесь, когда придут"
                        color: root.theme ? root.theme.colors.textDisabled : "#5A6675"
                        font.pixelSize: 11
                        opacity: 0.7
                    }
                }
            }
        }
    }
}