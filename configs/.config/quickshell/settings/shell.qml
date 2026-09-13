import QtQuick
import Quickshell
import Quickshell.Io

import "."

ShellRoot {
    id: root

    ThemeManager { id: themeManager }
    
    SoundPlayer { 
        id: soundManager
        soundsDir: Quickshell.shellDir + "/../sounds"
    }
    
    SettingsWindow {
        id: settingsWindow
        visible: true  // Контейнер всегда активен, окно внутри скрывается
        
        theme: themeManager.theme
        soundManager: soundManager
    }
    
    IpcHandler {
        target: "settings"
        
        function toggle() { settingsWindow.toggle() }
        function open() { settingsWindow.open() }
        function close() { settingsWindow.close() }
    }
}
