import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root

    ThemeManager {
        id: themeManager
    }

    IpcHandler {
        target: "themepicker"
        
        function applyTheme(themeName: string) {
            // ЗВУК УБРАН — воспроизводится в ThemePicker
            themeManager.loadTheme(themeName)
            console.log("Theme applied:", themeName)
        }
    }
}
