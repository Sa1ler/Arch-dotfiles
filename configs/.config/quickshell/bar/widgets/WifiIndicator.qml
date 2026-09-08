import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null
    property string wifiState: "off"  // "off", "on", "connected"
    property string networkName: ""
    
    // === Кэш цветов темы ===
    readonly property color accentColor: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
    readonly property color badgeTextColor: root.theme && root.theme.colors && root.theme.colors.textSelected ? root.theme.colors.textSelected : "#FFFFFF"
    readonly property color offBgColor: "#3A3A3A"
    readonly property color offTextColor: "#888888"
    
    implicitWidth: wifiCard.implicitWidth
    implicitHeight: wifiCard.implicitHeight

    // === ОДИН процесс вместо двух (меньше spawn) ===
    Process {
        id: getWifiStatus
        command: ["sh", "-c", "LC_ALL=C nmcli -t -f active,ssid dev wifi 2>/dev/null"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                var output = text.trim()
                
                if (output.length === 0) {
                    // nmcli не может получить данные — скорее всего wifi выключен
                    root.wifiState = "off"
                    root.networkName = ""
                    return
                }
                
                // Ищем активную сеть
                var lines = output.split("\n")
                var activeSSID = ""
                
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split(":")
                    if (parts[0] === "yes" || parts[0] === "*" || parts[0] === "да") {
                        activeSSID = parts.slice(1).join(":").trim()
                        break
                    }
                }
                
                if (activeSSID.length > 0) {
                    root.wifiState = "connected"
                    root.networkName = activeSSID
                } else {
                    // WiFi включен, но нет подключения
                    root.wifiState = "on"
                    root.networkName = ""
                }
            }
        }
    }

    Timer {
        id: wifiTimer
        interval: 3000  // Увеличил до 3 секунд — сети не меняются чаще
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
        implicitWidth: contentRow.implicitWidth + 10
        implicitHeight: 25
        radius: 8
        
        color: root.wifiState === "off" ? root.offBgColor : root.accentColor
        border.width: 1
        border.color: root.wifiState === "off" ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(1, 1, 1, 0.2)
        
        Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutQuart } }
        Behavior on border.color { ColorAnimation { duration: 250; easing.type: Easing.OutQuart } }

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 6
            
            // Иконка: одинаковый wifi, но с разной насыщенностью
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "\uf1eb"  // fa-wifi
                font.family: "Font Awesome 6 Free Solid"
                font.pixelSize: 28
                color: root.wifiState === "off" ? root.offTextColor : root.badgeTextColor
                opacity: root.wifiState === "off" ? 0.6 : 1
                
                Behavior on color { ColorAnimation { duration: 250 } }
                Behavior on opacity { NumberAnimation { duration: 250 } }
            }
            
            // Текст состояния/сети
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (root.wifiState === "connected") return root.networkName
                    if (root.wifiState === "on") return "On"
                    return "Off"
                }
                // JetBrains Mono для ровного текста (не Nerd Font!)
                font.family: "Font Awesome 6 Free Solid"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: root.wifiState === "off" ? root.offTextColor : root.badgeTextColor
                
                Behavior on color { ColorAnimation { duration: 250 } }
            }
        }
    }
}