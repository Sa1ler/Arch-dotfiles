import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null
    property var soundManager: null
    property bool active: false
    
    signal close()

    // Процесс для полного снимка
    Process {
        id: fullScreenshot
        command: ["sh", "-c", "grim - | wl-copy && notify-send 'Скриншот' 'Полный снимок экрана' -i camera -t 2000"]
        
        onRunningChanged: {
            if (!running && root.soundManager) {
                root.soundManager.play("quick_click.wav")
            }
        }
    }

    // Кнопки
    Row {
        id: buttonRow
        anchors.centerIn: parent
        spacing: 14

        // Кнопка полного снимка
        Rectangle {
            id: fullBtn
            width: 52
            height: 52
            radius: 12
            color: fullMouse.containsMouse ? 
                   (root.theme.colors.accent || "#5B9BFF") : 
                   (root.theme.colors.surface || "#1A1F26")
            border.width: 1
            border.color: root.theme.colors.border || "#2A2A2A"
            
            Behavior on color { ColorAnimation { duration: 200 } }
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
            
            scale: fullMouse.pressed ? 0.95 : 1.0

            Text {
                anchors.centerIn: parent
                text: "\uf065"
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 24
                color: fullMouse.containsMouse ? "#FFF" : (root.theme.colors.text || "#FFF")
                
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            MouseArea {
                id: fullMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: {
                    fullScreenshot.running = true
                    root.close()
                }
            }
        }

        // Кнопка частичного снимка
        Rectangle {
            id: regionBtn
            width: 52
            height: 52
            radius: 12
            color: regionMouse.containsMouse ? 
                   (root.theme.colors.accent || "#5B9BFF") : 
                   (root.theme.colors.surface || "#1A1F26")
            border.width: 1
            border.color: root.theme.colors.border || "#2A2A2A"
            
            Behavior on color { ColorAnimation { duration: 200 } }
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
            
            scale: regionMouse.pressed ? 0.95 : 1.0

            Text {
                anchors.centerIn: parent
                text: "\uf125"
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 24
                color: regionMouse.containsMouse ? "#FFF" : (root.theme.colors.text || "#FFF")
                
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            MouseArea {
                id: regionMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: {
                    Quickshell.execDetached(["sh", "-c", "grim -g \"$(slurp)\" - | wl-copy && notify-send 'Скриншот' 'Снимок области' -i camera -t 2000"])
                    if (root.soundManager) root.soundManager.play("quick_click.wav")
                    root.close()
                }
            }
        }
    }
}