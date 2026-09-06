import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null
    
    property string wifiState: "off"
    property string networkName: ""
    
    implicitWidth: wifiCard.implicitWidth
    implicitHeight: wifiCard.implicitHeight

    Process {
        id: getWifiStatus
        command: ["sh", "-c", "nmcli radio wifi 2>/dev/null"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                var status = text.trim().toLowerCase()
                
                if (status === "enabled") {
                    getActiveNetwork.running = true
                } else {
                    root.wifiState = "off"
                    root.networkName = ""
                }
            }
        }
    }

    Process {
        id: getActiveNetwork
        command: ["sh", "-c", "LC_ALL=C nmcli -t -f active,ssid dev wifi 2>/dev/null | grep -E '^(yes|\\*|да)' | head -1 | cut -d: -f2-"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                var ssid = text.trim()
                
                if (ssid.length > 0) {
                    root.wifiState = "connected"
                    root.networkName = ssid
                } else {
                    root.wifiState = "on"
                    root.networkName = ""
                }
            }
        }
    }

    Timer {
        id: wifiTimer
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!getWifiStatus.running) {
                getWifiStatus.running = true
            }
        }
    }

    Rectangle {
        id: wifiCard
        anchors.centerIn: parent
        
        // Параметры плашки
        implicitWidth: contentRow.implicitWidth + 10
        implicitHeight: 25
        radius: 8
        
        color: {
            if (root.wifiState === "off") {
                // Захардкоженный серый при выключенном
                return "#3A3A3A"
            }
            // connected и on — акцентный цвет
            return root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
        }
        
        border.width: 1
        border.color: {
            if (root.wifiState === "off") {
                return Qt.rgba(1, 1, 1, 0.05)
            }
            return Qt.rgba(1, 1, 1, 0.2)
        }
        
        Behavior on color { ColorAnimation { duration: 250 } }
        Behavior on border.color { ColorAnimation { duration: 250 } }

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 6
            
            // Иконка: перечёркнутый wifi при выключенном
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.wifiState === "off" ? "\uf05e" : "\uf1eb"  // ban / wifi
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 25
                color: {
                    if (root.wifiState === "off") {
                        return "#888"
                    }
                    return root.theme && root.theme.colors && root.theme.colors.textSelected ? 
                        root.theme.colors.textSelected : "#FFF"
                }
                
                Behavior on color { ColorAnimation { duration: 250 } }
            }
            
            // Текст
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (root.wifiState === "connected") {
                        return root.networkName
                    }
                    if (root.wifiState === "on") {
                        return "On"
                    }
                    return "Off"
                }
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 14
                font.bold: true
                font.weight: Font.DemiBold
                color: {
                    if (root.wifiState === "off") {
                        return "#888"
                    }
                    return root.theme && root.theme.colors && root.theme.colors.textSelected ? 
                           root.theme.colors.textSelected : "#FFF"
                }
                
                Behavior on color { ColorAnimation { duration: 250 } }
                Behavior on text {
                    SequentialAnimation {
                        NumberAnimation { target: parent; property: "opacity"; to: 0; duration: 100 }
                        PropertyAction { target: parent; property: "text" }
                        NumberAnimation { target: parent; property: "opacity"; to: 1; duration: 150 }
                    }
                }
            }
        }
    }
}