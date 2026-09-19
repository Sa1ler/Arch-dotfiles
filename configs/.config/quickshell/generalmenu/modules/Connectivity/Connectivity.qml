import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null
    property var soundPlayer: null
    signal dndStateChanged(bool enabled)

    property bool wifiEnabled: false
    property bool bluetoothEnabled: false
    property bool dndEnabled: false
    property bool nightModeEnabled: false
    property string wifiSsid: ""

    readonly property string dndFile: Quickshell.shellDir + "/../notification-dnd"
    readonly property string nightModeFile: Quickshell.shellDir + "/../night-mode"
    readonly property int blockHeight: 66
    implicitHeight: blockHeight
    
    // Температура ночного режима
    readonly property int nightTemp: 4700
    readonly property int normalTemp: 6500

    FileView {
        id: dndFileWriter
        path: root.dndFile
        printErrors: false
    }
    
    FileView {
        id: nightModeFileWriter
        path: root.nightModeFile
        printErrors: false
    }

    // === WiFi ===
    Process {
        id: wifiStatus
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID", "dev", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n")
                var activeSsid = ""
                var anyEnabled = false
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split(":")
                    if (parts.length >= 2 && parts[0] !== "") {
                        anyEnabled = true
                        if (parts[0] === "yes" || parts[0] === "*") {
                            activeSsid = parts[1]
                        }
                    }
                }
                root.wifiEnabled = anyEnabled
                root.wifiSsid = activeSsid
            }
        }
    }

    Process {
        id: wifiToggle
        property string targetState: "on"
        command: ["nmcli", "radio", "wifi", targetState]
        onExited: wifiStatus.running = true
    }

    function toggleWifi() {
        root.wifiEnabled = !root.wifiEnabled
        wifiToggle.targetState = root.wifiEnabled ? "on" : "off"
        wifiToggle.running = true
        if (root.soundPlayer) {
            root.soundPlayer.play(root.wifiEnabled ? "connect.wav" : "disconnect.wav")
        }
    }

    // === Bluetooth ===
    Process {
        id: bluetoothStatus
        command: ["bluetoothctl", "show"]
        stdout: StdioCollector {
            onStreamFinished: { 
                root.bluetoothEnabled = text.indexOf("Powered: yes") !== -1 
            }
        }
    }

    Process {
        id: bluetoothToggle
        property string targetState: "on"
        command: ["bluetoothctl", "power", targetState]
        onExited: bluetoothStatus.running = true
    }

    function toggleBluetooth() {
        root.bluetoothEnabled = !root.bluetoothEnabled
        bluetoothToggle.targetState = root.bluetoothEnabled ? "on" : "off"
        bluetoothToggle.running = true
        if (root.soundPlayer) {
            root.soundPlayer.play(root.bluetoothEnabled ? "connect.wav" : "disconnect.wav")
        }
    }

    // === DND ===
    function toggleDnd() {
        var newState = !root.dndEnabled
        root.dndEnabled = newState
        dndFileWriter.setText(newState ? "1" : "0")
        
        if (root.soundPlayer) {
            root.soundPlayer.play(newState ? "switch.wav" : "sfx.wav")
        }
        
        Qt.callLater(function() {
            var msg = newState ? "Уведомления не будут всплывать" : "Уведомления снова будут всплывать"
            Quickshell.execDetached(["notify-send", "-u", "normal", "Режим тишины", msg])
        })
        root.dndStateChanged(newState)
    }
    
    // === Ночной режим (wl-gammarelay-rs) ===
    
    // Проверка текущей температуры через D-Bus
    Process {
        id: nightModeCheck
        command: ["busctl", "--user", "get-property", "rs.wl-gammarelay", "/", "rs.wl.gammarelay", "Temperature"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                var output = text.trim()
                if (output.length > 0) {
                    var match = output.match(/(\d+)/)
                    if (match) {
                        var temp = parseInt(match[1])
                        root.nightModeEnabled = temp < root.normalTemp
                    } else {
                        root.nightModeEnabled = false
                    }
                } else {
                    root.nightModeEnabled = false
                }
            }
        }
    }
    
    // Запуск демона если не запущен
    Process {
        id: gammaRelayStart
        command: ["sh", "-c", "pgrep -x wl-gammarelay-rs || wl-gammarelay-rs &"]
    }
    
    function enableNightMode() {
        // Убеждаемся что демон запущен
        gammaRelayStart.running = true
        
        // Устанавливаем тёплую температуру через D-Bus (set-property)
        Quickshell.execDetached([
            "busctl", "--user", "set-property", 
            "rs.wl-gammarelay", "/", "rs.wl.gammarelay", 
            "Temperature", "q", String(root.nightTemp)
        ])
    }
    
    function disableNightMode() {
        // Сбрасываем на обычную температуру через D-Bus (set-property)
        Quickshell.execDetached([
            "busctl", "--user", "set-property", 
            "rs.wl-gammarelay", "/", "rs.wl.gammarelay", 
            "Temperature", "q", String(root.normalTemp)
        ])
    }
    
    function toggleNightMode() {
        var newState = !root.nightModeEnabled
        root.nightModeEnabled = newState
        nightModeFileWriter.setText(newState ? "1" : "0")
        
        if (newState) {
            enableNightMode()
        } else {
            disableNightMode()
        }
        
        if (root.soundPlayer) {
            root.soundPlayer.play(newState ? "switch.wav" : "sfx.wav")
        }
        
        Qt.callLater(function() {
            var msg = newState 
                ? "Цветовая температура: " + root.nightTemp + "K" 
                : "Цветовая температура: обычная"
            Quickshell.execDetached(["notify-send", "-u", "normal", "Ночной режим", msg])
        })
    }

    // === UI ===
    Rectangle {
        id: mainBlock
        anchors.fill: parent
        radius: 16
        color: root.theme ? root.theme.colors.surface : "#1A1F26"
        border.width: 1
        border.color: root.theme ? root.theme.colors.border : "#2A323D"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            // Ночной режим (ПЕРВАЯ)
            ToggleButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: root.nightModeEnabled ? "󰖔" : "󰖨"
                enabled: root.nightModeEnabled
                activeColor: root.theme ? root.theme.colors.accent : "#5B9BFF"
                inactiveColor: root.theme ? root.theme.colors.surfaceSelected : "#2C3A50"
                textColor: root.theme ? root.theme.colors.text : "#F0F4F8"
                secondaryTextColor: root.theme ? root.theme.colors.textSecondary : "#9AA9B9"
                onClicked: root.toggleNightMode()
            }

            ToggleButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: root.wifiEnabled ? "󰤨" : "󰤮"
                enabled: root.wifiEnabled
                activeColor: root.theme ? root.theme.colors.accent : "#5B9BFF"
                inactiveColor: root.theme ? root.theme.colors.surfaceSelected : "#2C3A50"
                textColor: root.theme ? root.theme.colors.text : "#F0F4F8"
                secondaryTextColor: root.theme ? root.theme.colors.textSecondary : "#9AA9B9"
                onClicked: root.toggleWifi()
            }

            ToggleButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: root.bluetoothEnabled ? "󰂯" : "󰂲"
                enabled: root.bluetoothEnabled
                activeColor: root.theme ? root.theme.colors.accent : "#5B9BFF"
                inactiveColor: root.theme ? root.theme.colors.surfaceSelected : "#2C3A50"
                textColor: root.theme ? root.theme.colors.text : "#F0F4F8"
                secondaryTextColor: root.theme ? root.theme.colors.textSecondary : "#9AA9B9"
                onClicked: root.toggleBluetooth()
            }

            ToggleButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: root.dndEnabled ? "󰹠" : "󰂛"
                enabled: root.dndEnabled
                activeColor: root.theme ? root.theme.colors.accent : "#5B9BFF"
                inactiveColor: root.theme ? root.theme.colors.surfaceSelected : "#2C3A50"
                textColor: root.theme ? root.theme.colors.text : "#F0F4F8"
                secondaryTextColor: root.theme ? root.theme.colors.textSecondary : "#9AA9B9"
                onClicked: root.toggleDnd()
            }
        }
    }

    component ToggleButton: Rectangle {
        id: btn
        property string icon: ""
        property bool enabled: false
        property color activeColor: "#5B9BFF"
        property color inactiveColor: "#2C3A50"
        property color textColor: "#F0F4F8"
        property color secondaryTextColor: "#9AA9B9"
        signal clicked()

        radius: 12
        color: enabled ? activeColor : inactiveColor
        Behavior on color { ColorAnimation { duration: 160 } }
        
        scale: hoverArea.pressed ? 0.94 : (hoverArea.containsMouse ? 1.06 : 1.0)
        Behavior on scale { 
            NumberAnimation { 
                duration: 120
                easing.type: Easing.OutBack 
            } 
        }

        Text {
            anchors.centerIn: parent
            text: btn.icon
            color: btn.enabled ? btn.textColor : btn.secondaryTextColor
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 22
            Behavior on color { ColorAnimation { duration: 140 } }
        }

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }

    Component.onCompleted: {
        wifiStatus.running = true
        bluetoothStatus.running = true
        nightModeCheck.running = true
    }

    Timer {
        interval: 5000
        repeat: true
        running: true
        onTriggered: {
            wifiStatus.running = true
            bluetoothStatus.running = true
            nightModeCheck.running = true
        }
    }
}