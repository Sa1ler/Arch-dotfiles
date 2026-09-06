import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null
    property string currentLayout: "EN"
    
    implicitWidth: contentRow.implicitWidth
    implicitHeight: contentRow.implicitHeight

    // Процесс для получения раскладки с явным указанием экземпляра
    Process {
        id: getLayout
        command: ["sh", "-c", "hyprctl devices -j 2>&1"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                var output = text.trim()
                
                if (output.length === 0) {
                    console.warn("KeyboardLayout: empty output from hyprctl")
                    return
                }
                
                try {
                    var data = JSON.parse(output)
                    
                    if (data && data.keyboards && data.keyboards.length > 0) {
                        // Ищем основную клавиатуру или первую
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
                            console.log("KeyboardLayout: changed from", root.currentLayout, "to", newLayout, "(keymap:", keymap + ")")
                            root.currentLayout = newLayout
                        }
                    }
                } catch(e) {
                    console.warn("KeyboardLayout: parse error:", e, "output:", output.substring(0, 200))
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

    // Таймер для обновления раскладки
    Timer {
        id: layoutTimer
        interval: 300
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
        
        if (lower.indexOf("russian") !== -1) {
            return "RU"
        } else if (lower.indexOf("english") !== -1 || lower.indexOf("us") !== -1) {
            return "EN"
        } else if (lower.indexOf("german") !== -1) {
            return "DE"
        } else if (lower.indexOf("french") !== -1) {
            return "FR"
        } else if (lower.indexOf("ukrainian") !== -1) {
            return "UA"
        } else if (keymap.length >= 2) {
            return keymap.substring(0, 2).toUpperCase()
        }
        
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
            font.family: "JetBrainsMono Nerd Font Mono"
            font.pixelSize: 25
            color: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#AAA"
        }
        
        // Надпись раскладки
        Text {
            id: layoutText
            anchors.verticalCenter: parent.verticalCenter
            text: root.currentLayout
            font.family: "JetBrainsMono Nerd Font Mono"
            font.pixelSize: 13
            font.bold: true
            color: root.theme && root.theme.colors ? root.theme.colors.text : "#FFF"
            
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