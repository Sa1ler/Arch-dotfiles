import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null
    property int volume: 0
    property bool isMuted: true
    readonly property bool showPercentage: !isMuted && volume > 0
    
    readonly property color accentColor: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
    readonly property color textColor: root.theme && root.theme.colors && root.theme.colors.textSelected ? root.theme.colors.textSelected : "#FFFFFF"
    
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
                    if (!getVolume.running) {
                        getVolume.running = true
                    }
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
        
        property int collapsedWidth: volumeIcon.implicitWidth + 20
        property int expandedWidth: volumeIcon.implicitWidth + percentText.implicitWidth + 26
        
        width: root.showPercentage ? expandedWidth : collapsedWidth
        height: 25
        radius: 8
        color: root.accentColor
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.2)
        clip: true
        
        Behavior on width { 
            NumberAnimation { 
                duration: 250 
                easing.type: Easing.OutQuart 
            } 
        }

        Text {
            id: volumeIcon
            anchors.verticalCenter: parent.verticalCenter
            
            x: root.showPercentage ? 10 : (parent.width - implicitWidth) / 2
            
            text: {
                if (root.isMuted) return "\uf026"  // volume-off (пустой динамик)
                if (root.volume === 0) return "\uf026"  // volume-off
                if (root.volume > 50) return "\uf028"  // volume-high
                return "\uf027"  // volume-low
            }
            font.family: "Font Awesome 6 Free Solid"
            font.pixelSize: 28
            color: root.textColor
            
            Behavior on x {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutQuart
                }
            }
        }
        
        Text {
            id: percentText
            anchors.verticalCenter: parent.verticalCenter
            
            x: root.showPercentage ? (volumeIcon.x + volumeIcon.width + 6) : parent.width
            
            text: root.volume + "%"
            font.family: "Font Awesome 6 Free Solid"
            font.pixelSize: 14
            font.weight: Font.ExtraBold
            color: root.textColor
            
            opacity: root.showPercentage ? 1 : 0
            
            Behavior on x {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutQuart
                }
            }
            
            Behavior on opacity { 
                NumberAnimation { 
                    duration: 200
                    easing.type: Easing.OutQuart
                } 
            }
        }
    }
}