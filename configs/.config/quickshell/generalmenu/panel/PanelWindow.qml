import QtQuick
import Quickshell

import "../modules/UserCard"
import "../modules/VolumeBrightness"
import "../modules/Connectivity"
import "../modules/NotificationCenter"
import "../modules/PowerMenu"

PanelWindow {
    id: root

    property var theme: null
    property var themeManager: null
    property var soundPlayer: null

    property bool opened: false
    property bool panelVisible: false

    property var notificationModel: null
    property var notificationList: null

    readonly property int panelWidth: 380
    readonly property int panelMargin: 12

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: root.panelVisible
    focusable: root.panelVisible

    Connections {
        target: root.themeManager
        function onThemeChanging() {
            themeTransition.start()
        }
    }

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
            x: root.width - width
            clip: true

            topLeftRadius: 24
            bottomLeftRadius: 24
            topRightRadius: 0
            bottomRightRadius: 0

            color: root.theme.colors.background
            border.width: 1
            border.color: root.theme.colors.border

            transform: Translate {
                id: panelTranslate
                x: 0
            }

            states: [
                State {
                    name: "closed"
                    PropertyChanges { 
                        target: panelTranslate 
                        x: panel.width 
                    }
                },
                State {
                    name: "open"
                    PropertyChanges { 
                        target: panelTranslate 
                        x: 0 
                    }
                }
            ]

            transitions: Transition {
                NumberAnimation { 
                    target: panelTranslate
                    property: "x"
                    duration: 380
                    easing.type: Easing.OutCubic
                }
            }

            state: root.opened ? "open" : "closed"

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
                    soundPlayer: root.soundPlayer
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
                    soundPlayer: root.soundPlayer
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
                    soundPlayer: root.soundPlayer
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
                    soundPlayer: root.soundPlayer
                    notificationList: root.notificationList

                    onRequestClose: function(notification) {
                        if (root.notificationModel) root.notificationModel.removeCenter(notification)
                    }

                    onRequestClear: function() {
                        if (root.notificationModel) root.notificationModel.clearCenter()
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
                    soundPlayer: root.soundPlayer
                    onActionExecuted: root.close()
                }
            }

            Item {
                id: themeTransitionLayer
                anchors.fill: parent
                z: 9999
                clip: true

                Rectangle {
                    id: themeCircle
                    anchors.centerIn: parent
                    width: Math.max(parent.width, parent.height) * 2.5
                    height: width
                    radius: width / 2
                    color: root.theme ? root.theme.colors.background : "#000000"
                    scale: 0
                    visible: scale > 0

                    NumberAnimation on scale {
                        id: themeTransition
                        from: 0
                        to: 1
                        duration: 600
                        easing.type: Easing.OutCubic
                        running: false
                        onStopped: themeCircle.scale = 0
                    }
                }
            }
        }
    }

    Timer {
        id: closeTimer
        interval: 390
        repeat: false
        onTriggered: {
            root.panelVisible = false
        }
    }

    function open() {
        closeTimer.stop()
        root.panelVisible = true
        Qt.callLater(function() {
            root.opened = true
            inputLayer.forceActiveFocus()
        })
    }

    function close() {
        if (!root.opened) return
        root.opened = false
        closeTimer.restart()
    }
}