import QtQuick
import Quickshell
import Quickshell.Io
import "../base"

Module {
    id: root

    signal clicked(var source)

    moduleHeight: 33
    moduleWidth: 60

    property int batteryLevel: 0
    property string batteryStatus: "full"
    property bool charging: root.batteryStatus === "charging"
    property bool lowBattery: root.batteryLevel < 15 && !root.charging

    property color containerColor: root.charging ? "#3675ff" : (root.lowBattery ? (root.blinkOn ? "#ff3636" : "#555555") : "#3675ff")

    property bool blinkOn: true
    property int blinkInterval: 400

    Timer {
        id: blinkTimer
        interval: root.blinkInterval
        running: false
        repeat: true
        onTriggered: root.blinkOn = !root.blinkOn
    }

    onLowBatteryChanged: {
        if (root.lowBattery && !root.charging) {
            root.blinkOn = true
            blinkTimer.start()
        } else {
            blinkTimer.stop()
            root.blinkOn = true
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: 6

        color: root.containerColor

        Behavior on color {
            ColorAnimation { duration: 80 }
        }

        Row {
            anchors.centerIn: parent
            spacing: 4

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.icon
                color: "#111111"
                font.pixelSize: 14
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.batteryLevel + "%"
                color: "#111111"
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }
        }
    }

    property string icon: root.charging ? "" : root._icon

    property string _icon: {
        if (root.batteryLevel <= 10) return "󰁺"
        if (root.batteryLevel <= 30) return "󰁼"
        if (root.batteryLevel <= 60) return "󰁾"
        if (root.batteryLevel <= 90) return "󰂀"
        return "󰂀"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: {
            root.y = -2
            root.scale = 1.03
        }

        onExited: {
            root.y = 0
            root.scale = 1
        }
    }

    Process {
        id: batteryProc
        command: [
            "bash", "-c",
            "upower -i $(upower -e | grep 'BAT') 2>/dev/null | grep -E 'state|percentage' | awk -F: '{print $2}' | sed 's/^ *//' | tr '\\n' ' '"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let text = this.text.trim()
                let parts = text.split(/\s+/)

                for (let i = 0; i < parts.length; i++) {
                    if (parts[i] === "discharging" || parts[i] === "charging" || parts[i] === "full" || parts[i] === "empty") {
                        root.batteryStatus = parts[i]
                    }
                    if (parts[i].includes("%")) {
                        root.batteryLevel = parseInt(parts[i])
                    }
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: batteryProc.running = true
    }

    Component.onCompleted: batteryProc.running = true
}
