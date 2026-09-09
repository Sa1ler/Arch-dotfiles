import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null
    property var soundManager: null
    property bool active: false
    
    readonly property color surfaceColor: root.theme && root.theme.colors ? root.theme.colors.surface : "#1A1F26"
    readonly property color textColor: root.theme && root.theme.colors ? root.theme.colors.text : "#FFFFFF"
    readonly property color accentColor: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
    readonly property color borderColor: root.theme && root.theme.colors ? root.theme.colors.border : "#2A2A2A"
    
    signal close()

    function takeFullScreenshot() {
        console.log("[ScreenshotMenu] Taking full screenshot")
        Quickshell.execDetached([
            "sh", "-c",
            "grim - | wl-copy && notify-send '📸 Скриншот' 'Полный снимок скопирован в буфер' -i camera -t 2000"
        ])
        // 🔊 quick_click.wav — снимок сделан
        if (root.soundManager) root.soundManager.play("quick_click.wav")
        root.close()
    }
    
    function takeRegionScreenshot() {
        console.log("[ScreenshotMenu] Taking region screenshot")
        Quickshell.execDetached([
            "sh", "-c",
            "grim -g \"$(slurp)\" - | wl-copy && notify-send '📸 Скриншот' 'Снимок области скопирован' -i camera -t 2000"
        ])
        // 🔊 quick_click.wav — снимок области сделан
        if (root.soundManager) root.soundManager.play("quick_click.wav")
        root.close()
    }

    Row {
        id: buttonRow
        anchors.centerIn: parent
        spacing: 14

        // === Кнопка полного снимка ===
        Rectangle {
            id: fullBtn
            width: 52
            height: 52
            radius: 12
            color: fullMouse.containsMouse ? root.accentColor : root.surfaceColor
            border.width: 1
            border.color: root.borderColor
            scale: fullMouse.pressed ? 0.95 : (fullMouse.containsMouse ? 1.05 : 1.0)
            
            Behavior on color { ColorAnimation { duration: 180 } }
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuart } }

            Text {
                anchors.centerIn: parent
                text: "\uf030"  // fa-camera (есть в Free)
                font.family: "Font Awesome 6 Free Solid"
                font.pixelSize: 22
                font.weight: Font.Black
                color: fullMouse.containsMouse ? "#FFFFFF" : root.textColor
                Behavior on color { ColorAnimation { duration: 180 } }
            }

            MouseArea {
                id: fullMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.takeFullScreenshot()
            }
        }

        // === Кнопка частичного снимка ===
        Rectangle {
            id: regionBtn
            width: 52
            height: 52
            radius: 12
            color: regionMouse.containsMouse ? root.accentColor : root.surfaceColor
            border.width: 1
            border.color: root.borderColor
            scale: regionMouse.pressed ? 0.95 : (regionMouse.containsMouse ? 1.05 : 1.0)
            
            Behavior on color { ColorAnimation { duration: 180 } }
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuart } }

            Text {
                anchors.centerIn: parent
                text: "\uf125"  // fa-crop (есть в Free, НЕ crop-alt!)
                font.family: "Font Awesome 6 Free Solid"
                font.pixelSize: 22
                font.weight: Font.Black
                color: regionMouse.containsMouse ? "#FFFFFF" : root.textColor
                Behavior on color { ColorAnimation { duration: 180 } }
            }

            MouseArea {
                id: regionMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.takeRegionScreenshot()
            }
        }
    }
}