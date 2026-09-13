import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: manager
    
    // === Свойства топбара ===
    property bool enabled: true
    property bool attachToEdge: true
    property string barType: "modular"
    property string position: "top"
    property bool autoHide: false
    property int hideDelay: 500
    property int barLength: 900
    property int cornerRadius: 12
    property int screenMaxWidth: 1920
    
    readonly property string settingsFilePath: Quickshell.env["HOME"] + "/.config/quickshell/settings.json"
    
    // === Чтение настроек ===
    Process {
        id: readSettings
        command: ["bash", "-c", 
            "FILE=\"$HOME/.config/quickshell/settings.json\"; " +
            "if [ -f \"$FILE\" ]; then cat \"$FILE\"; " +
            "else echo '{\"topbar\":{}}'; fi"
        ]
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text.trim())
                    if (data.topbar) {
                        if (typeof data.topbar.enabled === "boolean") manager.enabled = data.topbar.enabled
                        if (typeof data.topbar.attachToEdge === "boolean") manager.attachToEdge = data.topbar.attachToEdge
                        if (typeof data.topbar.type === "string") manager.barType = data.topbar.type
                        if (typeof data.topbar.position === "string") manager.position = data.topbar.position
                        if (typeof data.topbar.autoHide === "boolean") manager.autoHide = data.topbar.autoHide
                        if (typeof data.topbar.hideDelay === "number") manager.hideDelay = data.topbar.hideDelay
                        if (typeof data.topbar.width === "number") manager.barLength = data.topbar.width
                        if (typeof data.topbar.cornerRadius === "number") manager.cornerRadius = data.topbar.cornerRadius
                    }
                    console.log("[TopBarManager] Loaded settings")
                } catch(e) {
                    console.warn("[TopBarManager] Parse error:", e)
                }
            }
        }
    }
    
    // === Запись настроек ===
    function save() {
        var json = JSON.stringify({
            topbar: {
                enabled: manager.enabled,
                attachToEdge: manager.attachToEdge,
                type: manager.barType,
                position: manager.position,
                autoHide: manager.autoHide,
                hideDelay: manager.hideDelay,
                width: manager.barLength,
                cornerRadius: manager.cornerRadius
            }
        }, null, 2)
        
        writeSettings.command = ["bash", "-c",
            "echo '" + json.replace(/'/g, "'\\''") + "' > \"$HOME/.config/quickshell/settings.json\""
        ]
        writeSettings.running = true
    }
    
    Process { id: writeSettings }
    
    // === Методы установки значений ===
    function setEnabled(val) { enabled = val; save() }
    function setAttachToEdge(val) { attachToEdge = val; save() }
    function setBarType(val) { barType = val; save() }
    function setPosition(val) { position = val; save() }
    function setAutoHide(val) { autoHide = val; save() }
    function setHideDelay(val) { hideDelay = val; save() }
    function setBarLength(val) { barLength = val; save() }
    function setCornerRadius(val) { cornerRadius = val; save() }
    
    Component.onCompleted: readSettings.running = true
}