import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null
    
    property int volume: 0
    property bool isMuted: true
    
    property bool showPercentage: !isMuted && volume > 0
    
    implicitWidth: volumeCard.width
    implicitHeight: volumeCard.height

    Process {
        id: getVolume
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                var output = text.trim()
                
                if (output.indexOf("Volume:") !== -1) {
                    var parts = output.split(" ")
                    if (parts.length >= 2) {
                        var vol = parseFloat(parts[1])
                        if (!isNaN(vol)) {
                            root.volume = Math.round(vol * 100)
                        }
                    }
                    root.isMuted = output.indexOf("[MUTED]") !== -1
                }
            }
        }
    }

    Process {
        id: volumeListener
        command: ["bash", "-c", "pactl subscribe 2>/dev/null"]
        running: true
        
        stdout: SplitParser {
            onRead: function(line) {
                if (line.indexOf("sink") !== -1 || line.indexOf("server") !== -1) {
                    getVolume.running = true
                }
            }
        }
    }

    Timer {
        id: volumeTimer
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!getVolume.running) {
                getVolume.running = true
            }
        }
    }

    Rectangle {
        id: volumeCard
        anchors.centerIn: parent
        
        // УМЕНЬШЕНЫЕ размеры
        property real collapsedWidth: 32   // Только иконка (было 35)
        property real expandedWidth: 60    // Иконка + проценты (было 80)
        
        width: root.showPercentage ? expandedWidth : collapsedWidth
        height: 25
        radius: 8
        
        color: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
        
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.2)
        
        Behavior on width { 
            NumberAnimation { 
                duration: 250 
                easing.type: Easing.OutCubic 
            } 
        }

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 6
            
            // Иконка громкости
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (!root.showPercentage) return "\uf026"
                    if (root.volume > 50) return "\uf028"
                    return "\uf027"
                }
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 23
                font.weight: Font.Black
                color: root.theme && root.theme.colors && root.theme.colors.textSelected ? 
                       root.theme.colors.textSelected : "#FFF"
            }
            
            // Проценты (ИСПРАВЛЕНО: ширина 0 при скрытии для центрирования иконки)
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.volume + "%"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                font.weight: Font.ExtraBold
                color: root.theme && root.theme.colors && root.theme.colors.textSelected ? 
                       root.theme.colors.textSelected : "#FFF"
                
                // Ширина 0 при скрытии — иконка центрируется
                width: root.showPercentage ? implicitWidth : 0
                
                opacity: root.showPercentage ? 1 : 0
                
                // Задержка перед появлением
                Behavior on opacity { 
                    SequentialAnimation {
                        PauseAnimation { duration: root.showPercentage ? 150 : 0 }
                        NumberAnimation { duration: 150 }
                    }
                }
            }
        }
    }
}