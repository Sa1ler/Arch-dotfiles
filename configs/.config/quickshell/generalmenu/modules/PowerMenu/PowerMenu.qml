import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell

Item {
    id: root

    property var theme: null
    property var soundPlayer: null
    signal actionExecuted()

    implicitHeight: 60

    RowLayout {
        anchors.fill: parent
        spacing: 12

        PowerButton {
            Layout.fillWidth: true
            icon: ""
            liquidColor: root.theme ? root.theme.colors.accent : "#5B9BFF"
            surfaceColor: root.theme ? root.theme.colors.surface : "#1A1F26"
            surfaceHoverColor: root.theme ? root.theme.colors.surfaceHover : "#252C36"
            borderColor: root.theme ? root.theme.colors.border : "#2A323D"
            textColor: root.theme ? root.theme.colors.text : "#F0F4F8"
            textSelectedColor: root.theme ? root.theme.colors.textSelected : "#FFFFFF"
            executeSound: "power_on.wav"
            onExecute: {
                Quickshell.execDetached(["systemctl", "poweroff"])
                root.actionExecuted()
            }
        }

        PowerButton {
            Layout.fillWidth: true
            icon: ""
            liquidColor: root.theme ? root.theme.colors.accent : "#5B9BFF"
            surfaceColor: root.theme ? root.theme.colors.surface : "#1A1F26"
            surfaceHoverColor: root.theme ? root.theme.colors.surfaceHover : "#252C36"
            borderColor: root.theme ? root.theme.colors.border : "#2A323D"
            textColor: root.theme ? root.theme.colors.text : "#F0F4F8"
            textSelectedColor: root.theme ? root.theme.colors.textSelected : "#FFFFFF"
            executeSound: "charge_loop2.wav"
            onExecute: {
                Quickshell.execDetached(["systemctl", "reboot"])
                root.actionExecuted()
            }
        }

        PowerButton {
            Layout.fillWidth: true
            icon: ""
            liquidColor: root.theme ? root.theme.colors.accent : "#5B9BFF"
            surfaceColor: root.theme ? root.theme.colors.surface : "#1A1F26"
            surfaceHoverColor: root.theme ? root.theme.colors.surfaceHover : "#252C36"
            borderColor: root.theme ? root.theme.colors.border : "#2A323D"
            textColor: root.theme ? root.theme.colors.text : "#F0F4F8"
            textSelectedColor: root.theme ? root.theme.colors.textSelected : "#FFFFFF"
            executeSound: "sfx2.wav"
            onExecute: {
                Quickshell.execDetached(["hyprlock"])
                root.actionExecuted()
            }
        }

        PowerButton {
            Layout.fillWidth: true
            icon: ""
            liquidColor: root.theme ? root.theme.colors.accent : "#5B9BFF"
            surfaceColor: root.theme ? root.theme.colors.surface : "#1A1F26"
            surfaceHoverColor: root.theme ? root.theme.colors.surfaceHover : "#252C36"
            borderColor: root.theme ? root.theme.colors.border : "#2A323D"
            textColor: root.theme ? root.theme.colors.text : "#F0F4F8"
            textSelectedColor: root.theme ? root.theme.colors.textSelected : "#FFFFFF"
            executeSound: "swoosh.wav"
            onExecute: {
                Quickshell.execDetached(["systemctl", "suspend"])
                root.actionExecuted()
            }
        }
    }

    component PowerButton: Item {
        id: button
        property string icon: ""
        property color liquidColor: "#5B9BFF"
        property color surfaceColor: "#1A1F26"
        property color surfaceHoverColor: "#252C36"
        property color borderColor: "#2A323D"
        property color textColor: "#F0F4F8"
        property color textSelectedColor: "#FFFFFF"
        property string executeSound: "click.wav"
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
            color: mouseArea.containsMouse ? button.surfaceHoverColor : button.surfaceColor
            border.width: 1
            border.color: button.borderColor
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
            color: liquid.height > parent.height / 2 ? button.textSelectedColor : button.textColor
            Behavior on color { ColorAnimation { duration: 200 } }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onPressed: {
                if (root.soundPlayer) root.soundPlayer.play("charge_loop2.wav")
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
            onStopped: {
                if (liquid.height === button.height && mouseArea.pressed) {
                    if (root.soundPlayer) root.soundPlayer.play(button.executeSound)
                    executeTimer.start()
                }
            }
        }

        Timer { 
            id: executeTimer
            interval: 50 
            onTriggered: button.execute() 
        }
    }
}