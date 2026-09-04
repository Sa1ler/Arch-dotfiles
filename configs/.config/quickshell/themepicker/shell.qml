import QtQuick
import Quickshell
import Quickshell.Io

import "panel"

ShellRoot {
    id: root

    ThemeManager {
        id: themeManager
    }

    IpcHandler {
        target: "themepicker"
        
        function toggle() {
            themePickerWindow.windowVisible = !themePickerWindow.windowVisible
        }
    }

    ThemePickerWindow {
        id: themePickerWindow
        visible: false
        
        theme: themeManager.theme
        themeManager: themeManager
        themesList: themeManager.themes
        themesLoaded: themeManager.themesLoaded
        
        onApplyTheme: function(themeName) {
            themeManager.loadTheme(themeName)
            themePickerWindow.windowVisible = false
        }
    }
}