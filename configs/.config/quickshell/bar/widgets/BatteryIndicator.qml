import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null
    property int batteryLevel: 100
    property bool charging: false
    readonly property bool isLowBattery: batteryLevel < 15 && !charging
    
    implicitWidth: batteryCard.width
    implicitHeight: batteryCard.height

    readonly property color accentColor: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
    readonly property color textColor: root.theme && root.theme.colors && root.theme.colors.textSelected ? root.theme.colors.textSelected : "#FFFFFF"

    readonly property string chargingIcon: ""
    readonly property string batteryIcon: {
        if (batteryLevel <= 10) return "󰁺"
        if (batteryLevel <= 30) return "󰁼"
        if (batteryLevel <= 60) return "󰁾"
        if (batteryLevel <= 90) return "󰂀"
        return "󰁿"
    }
    readonly property string currentIcon: charging ? chargingIcon : batteryIcon

    // === Process для чтения батареи (работает с любым именем батареи) ===
    Process {
        id: getBattery
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1 && cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n")
                
                if (lines.length >= 1 && lines[0].length > 0) {
                    var level = parseInt(lines[0])
                    if (!isNaN(level)) {
                        root.batteryLevel = level
                    }
                }
                
                if (lines.length >= 2 && lines[1].length > 0) {
                    var status = lines[1].toLowerCase()
                    root.charging = (status === "charging" || status === "full")
                }
            }
        }
    }

    Timer {
        id: batteryTimer
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!getBattery.running) {
                getBattery.running = true
            }
        }
    }

    SequentialAnimation {
        id: blinkAnimation
        loops: Animation.Infinite
        
        ColorAnimation { 
            target: batteryCard 
            property: "color" 
            to: "#FF3B3B" 
            duration: 500 
            easing.type: Easing.InOutQuad
        }
        ColorAnimation { 
            target: batteryCard 
            property: "color" 
            to: root.accentColor
            duration: 500 
            easing.type: Easing.InOutQuad
        }
    }

    onIsLowBatteryChanged: {
        if (isLowBattery) {
            blinkAnimation.start()
        } else {
            blinkAnimation.stop()
            batteryCard.color = root.accentColor
        }
    }

    Rectangle {
        id: batteryCard
        anchors.centerIn: parent
        width: contentRow.implicitWidth + 10
        height: 25
        radius: 8
        color: root.accentColor
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.2)

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 6
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.currentIcon
                font.family: "Font Awesome 6 Free Solid"
                font.pixelSize: 20
                font.weight: Font.Black
                color: root.textColor
            }
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.batteryLevel + "%"
                font.family: "Font Awesome 6 Free Solid"
                font.pixelSize: 14
                font.weight: Font.ExtraBold
                color: root.textColor
            }
        }
    }
}