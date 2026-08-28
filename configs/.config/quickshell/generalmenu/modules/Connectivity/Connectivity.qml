import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null
    signal dndStateChanged(bool enabled)

    property bool wifiEnabled: false
    property bool bluetoothEnabled: false
    property bool dndEnabled: false
    property string wifiSsid: ""

    readonly property string dndFile: Quickshell.shellDir + "/../notification-dnd"
    readonly property int blockHeight: 66
    implicitHeight: blockHeight

    readonly property string clickSoundPath: Quickshell.shellDir + "/sounds/click.wav"

    function playClick() {
        Quickshell.execDetached(["sh", "-c", "pw-play '" + clickSoundPath + "' 2>/dev/null || paplay '" + clickSoundPath + "' 2>/dev/null || true"])
    }

    readonly property color backgroundColor: root.theme.colors.surface
    readonly property color borderColor: root.theme.colors.border
    readonly property color accentColor: root.theme.colors.accent
    readonly property color textColor: root.theme.colors.text
    readonly property color secondaryTextColor: root.theme.colors.textSecondary
    readonly property color inactiveColor: root.theme.colors.surfaceSelected

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
                    if (parts.length >= 2) {
                        if (parts[0] === "yes" || parts[0] === "*") { activeSsid = parts[1]; anyEnabled = true }
                        else if (parts[0] !== "") anyEnabled = true
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
    }

    Process {
        id: bluetoothStatus
        command: ["bluetoothctl", "show"]
        stdout: StdioCollector {
            onStreamFinished: { root.bluetoothEnabled = text.trim().indexOf("Powered: yes") !== -1 }
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
    }

    Process {
        id: dndWriter
        property bool pendingState: false
        command: ["sh", "-c", "printf '%s\\n' '" + (pendingState ? "1" : "0") + "' > '" + root.dndFile + "'"]
    }

    function toggleDnd() {
        var newState = !root.dndEnabled
        root.dndEnabled = newState
        dndWriter.pendingState = newState
        dndWriter.running = true
        Qt.callLater(function() {
            if (newState) Quickshell.execDetached(["notify-send", "-u", "normal", "Режим тишины", "Уведомления не будут всплывать"])
            else Quickshell.execDetached(["notify-send", "-u", "normal", "Режим тишины выключен", "Уведомления снова будут всплывать"])
        })
        root.dndStateChanged(newState)
    }

    Rectangle {
        id: mainBlock
        anchors.fill: parent
        radius: 16
        color: root.backgroundColor
        border.width: 1
        border.color: root.borderColor

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            ToggleButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: root.wifiEnabled ? "󰤨" : "󰤮"
                enabled: root.wifiEnabled
                activeColor: root.accentColor
                inactiveColor: root.inactiveColor
                textColor: root.textColor
                secondaryTextColor: root.secondaryTextColor
                onClicked: root.toggleWifi()
            }

            ToggleButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: root.bluetoothEnabled ? "󰂯" : "󰂲"
                enabled: root.bluetoothEnabled
                activeColor: root.accentColor
                inactiveColor: root.inactiveColor
                textColor: root.textColor
                secondaryTextColor: root.secondaryTextColor
                onClicked: root.toggleBluetooth()
            }

            ToggleButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: root.dndEnabled ? "󰹠" : "󰂛"
                enabled: root.dndEnabled
                activeColor: root.accentColor
                inactiveColor: root.inactiveColor
                textColor: root.textColor
                secondaryTextColor: root.secondaryTextColor
                onClicked: root.toggleDnd()
            }
        }
    }

    component ToggleButton: Rectangle {
        id: btn
        property string icon: ""
        property bool enabled: false
        property color activeColor: "#FFB080"
        property color inactiveColor: "#303030"
        property color textColor: "#FFFFFF"
        property color secondaryTextColor: "#A0A0A0"
        signal clicked()

        radius: 12
        color: enabled ? activeColor : inactiveColor
        Behavior on color { ColorAnimation { duration: 160 } }
        scale: hoverArea.pressed ? 0.94 : (hoverArea.containsMouse ? 1.04 : 1.0)
        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

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
            onPressed: root.playClick()
            onClicked: btn.clicked()
        }
    }

    Component.onCompleted: {
        wifiStatus.running = true
        bluetoothStatus.running = true
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        onTriggered: {
            wifiStatus.running = true
            bluetoothStatus.running = true
        }
    }
}