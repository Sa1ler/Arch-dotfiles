import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell

Item {
    id: root

    property var theme: null
    signal actionExecuted()

    implicitHeight: 60

    RowLayout {
        anchors.fill: parent
        spacing: 12

        PowerButton {
            Layout.fillWidth: true
            icon: ""
            liquidColor: root.theme.colors.accent
            onExecute: {
                Quickshell.execDetached(["systemctl", "poweroff"])
                root.actionExecuted()
            }
        }

        PowerButton {
            Layout.fillWidth: true
            icon: ""
            liquidColor: root.theme.colors.accent
            onExecute: {
                Quickshell.execDetached(["systemctl", "reboot"])
                root.actionExecuted()
            }
        }

        PowerButton {
            Layout.fillWidth: true
            icon: ""
            liquidColor: root.theme.colors.accent
            onExecute: {
                Quickshell.execDetached(["hyprlock"])
                root.actionExecuted()
            }
        }

        PowerButton {
            Layout.fillWidth: true
            icon: ""
            liquidColor: root.theme.colors.accent
            onExecute: {
                Quickshell.execDetached(["systemctl", "suspend"])
                root.actionExecuted()
            }
        }
    }

    component PowerButton: Item {
        id: button
        property string icon: ""
        property color liquidColor: root.theme.colors.accent
        signal execute()

        implicitHeight: 60
        scale: mouseArea.pressed ? 0.92 : 1.0
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

        Item {
            id: buttonMask
            anchors.fill: parent
            visible: false
            Rectangle { anchors.fill: parent; radius: 16 }
        }

        Rectangle {
            id: btnBg
            anchors.fill: parent
            radius: 16
            color: mouseArea.containsMouse ? root.theme.colors.surfaceHover : root.theme.colors.surface
            border.width: 1
            border.color: root.theme.colors.border
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        Item {
            id: liquidContainer
            anchors.fill: parent
            layer.enabled: true
            layer.effect: OpacityMask { maskSource: buttonMask }

            Rectangle {
                id: liquid
                width: parent.width
                height: 0
                anchors.bottom: parent.bottom
                color: button.liquidColor
            }
        }

        Text {
            anchors.centerIn: parent
            text: button.icon
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 24
            color: liquid.height > parent.height / 2 ? root.theme.colors.textSelected : root.theme.colors.text
            Behavior on color { ColorAnimation { duration: 200 } }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onPressed: {
                liquid.height = 0
                liquidAnim.stop()
                liquidAnim.to = button.height
                liquidAnim.duration = 1500
                liquidAnim.start()
            }
            onReleased: drainLiquid()
            onCanceled: drainLiquid()
            function drainLiquid() {
                if (liquidAnim.running) liquidAnim.stop()
                if (liquid.height > 0) {
                    liquidAnim.to = 0
                    liquidAnim.duration = 250
                    liquidAnim.start()
                }
            }
        }

        NumberAnimation {
            id: liquidAnim
            target: liquid
            property: "height"
            easing.type: Easing.Linear
            onStopped: if (liquid.height === button.height && mouseArea.pressed) executeTimer.start()
        }

        Timer { id: executeTimer; interval: 50; onTriggered: button.execute() }
    }
}