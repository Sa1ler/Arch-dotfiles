import QtQuick
import Quickshell

import "../modules/UserCard"
import "../modules/VolumeBrightness"
import "../modules/Connectivity"
import "../modules/NotificationCenter"
import "../modules/PowerMenu"

PanelWindow {
    id: root

    // ============================================================
    // THEME (передаётся из shell.qml)
    // ============================================================
    property var theme: null

    // ============================================================
    // STATE
    // ============================================================
    property bool opened: false
    property bool panelVisible: false

    // ============================================================
    // NOTIFICATION MODEL
    // ============================================================
    property var notificationModel: null
    property var notificationList: null

    // ============================================================
    // SIZE
    // ============================================================
    readonly property int panelWidth: 380
    readonly property int panelMargin: 12

    // ============================================================
    // WINDOW
    // ============================================================
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: root.panelVisible

    // ============================================================
    // KEYBOARD FOCUS
    // ============================================================
    focusable: root.panelVisible

    // ============================================================
    // INPUT LAYER
    // ============================================================
    Item {
        id: inputLayer
        anchors.fill: parent
        focus: root.panelVisible

        Keys.onEscapePressed: function(event) {
            root.close()
            event.accepted = true
        }

        MouseArea {
            id: backgroundMouseArea
            anchors.fill: parent
            onClicked: function(mouse) {
                root.close()
            }
        }

        Rectangle {
            id: panel
            width: root.panelWidth
            height: root.height - root.panelMargin * 2
            y: root.panelMargin
            x: root.opened ? root.width - width : root.width

            topLeftRadius: 24
            bottomLeftRadius: 24
            topRightRadius: 0
            bottomRightRadius: 0

            color: root.theme.colors.background
            border.width: 1
            border.color: root.theme.colors.border

            Behavior on x {
                NumberAnimation {
                    duration: 380
                    easing.type: Easing.OutCubic
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: function(mouse) {
                    mouse.accepted = true
                }
            }

            Item {
                id: content
                anchors.fill: parent

                UserCard {
                    id: userCard
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 16
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    theme: root.theme
                }

                VolumeBrightness {
                    id: volumeBrightness
                    anchors.top: userCard.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 10
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    theme: root.theme
                }

                Connectivity {
                    id: connectivity
                    anchors.top: volumeBrightness.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 10
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    theme: root.theme
                }

                NotificationCenter {
                    id: notificationCenter
                    anchors.top: connectivity.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: powerMenu.top
                    anchors.topMargin: 16
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    anchors.bottomMargin: 16
                    theme: root.theme
                    notificationList: root.notificationList

                    onRequestClose: function(notification) {
                        if (root.notificationModel) {
                            root.notificationModel.removeCenter(notification)
                        }
                    }

                    onRequestClear: function() {
                        if (root.notificationModel) {
                            root.notificationModel.clearCenter()
                        }
                    }
                }

                PowerMenu {
                    id: powerMenu
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    anchors.bottomMargin: 16
                    theme: root.theme
                    onActionExecuted: root.close()
                }
            }
        }
    }

    // CLOSE TIMER
    Timer {
        id: closeTimer
        interval: 390
        repeat: false
        onTriggered: {
            root.panelVisible = false
        }
    }

    // OPEN
    function open() {
        closeTimer.stop()
        root.panelVisible = true
        Qt.callLater(function() {
            root.opened = true
            inputLayer.forceActiveFocus()
        })
    }

    // CLOSE
    function close() {
        if (!root.opened) return
        root.opened = false
        closeTimer.restart()
    }
}