import QtQuick
import Quickshell
import Quickshell.Io

import "panel"

ShellRoot {
    id: root

    ThemeManager {
        id: themeManager
    }

    SoundPlayer {
        id: soundManager
        soundsDir: Quickshell.shellDir + "/../sounds"
    }

    TopBar {
        id: topBar
        visible: true
        
        theme: themeManager.theme
        soundManager: soundManager
    }
}