import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null
    property string currentLayout: "EN"
    
    // === Кэш цветов темы ===
    readonly property color textColor: root.theme && root.theme.colors ? root.theme.colors.text : "#FFFFFF"
    readonly property color textSecondaryColor: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#AAAAAA"
    
    implicitWidth: contentRow.implicitWidth
    implicitHeight: contentRow.implicitHeight

    Process {
        id: getLayout
        command: ["sh", "-c", "hyprctl devices -j 2>&1"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                var output = text.trim()
                
                if (output.length === 0) return
                
                try {
                    var data = JSON.parse(output)
                    
                    if (data && data.keyboards && data.keyboards.length > 0) {
                        // Ищем основную клавиатуру
                        var keyboard = null
                        for (var i = 0; i < data.keyboards.length; i++) {
                            if (data.keyboards[i].main) {
                                keyboard = data.keyboards[i]
                                break
                            }
                        }
                        if (!keyboard) {
                            keyboard = data.keyboards[0]
                        }
                        
                        var keymap = keyboard.active_keymap || ""
                        var newLayout = parseLayout(keymap)
                        
                        if (root.currentLayout !== newLayout) {
                            root.currentLayout = newLayout
                        }
                    }
                } catch(e) {
                    console.warn("KeyboardLayout: parse error:", e)
                }
            }
        }
        
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    console.warn("KeyboardLayout stderr:", text.trim())
                }
            }
        }
    }

    // === ОПТИМИЗАЦИЯ: Увеличен интервал с 300мс до 1000мс ===
    // Раскладка не меняется чаще чем раз в секунду, это снижает нагрузку на CPU
    Timer {
        id: layoutTimer
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!getLayout.running) {
                getLayout.running = true
            }
        }
    }

    function parseLayout(keymap) {
        var lower = keymap.toLowerCase()
        
        if (lower.indexOf("russian") !== -1) return "RU"
        if (lower.indexOf("english") !== -1 || lower.indexOf("us") !== -1) return "EN"
        if (lower.indexOf("german") !== -1) return "DE"
        if (lower.indexOf("french") !== -1) return "FR"
        if (lower.indexOf("ukrainian") !== -1) return "UA"
        if (keymap.length >= 2) return keymap.substring(0, 2).toUpperCase()
        
        return "EN"
    }

    Row {
        id: contentRow
        spacing: 7
        anchors.verticalCenter: parent.verticalCenter
        
        // Иконка клавиатуры
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "\uf11c"
            font.family: "Font Awesome 6 Free Solid"
            font.pixelSize: 20
            color: root.textSecondaryColor
        }
        
        // Надпись раскладки
        Text {
            id: layoutText
            anchors.verticalCenter: parent.verticalCenter
            text: root.currentLayout
            font.family: "Font Awesome 6 Free Solid"
            font.pixelSize: 11
            font.bold: true
            color: root.textColor
            
            Behavior on text {
                SequentialAnimation {
                    NumberAnimation { target: layoutText; property: "opacity"; to: 0; duration: 100 }
                    PropertyAction { target: layoutText; property: "text" }
                    NumberAnimation { target: layoutText; property: "opacity"; to: 1; duration: 150 }
                }
            }
        }
    }
}