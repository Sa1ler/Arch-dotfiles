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

    function playWindowSound(isOpen) {
        if (isOpen) {
            soundManager.play("list.wav")
        } else {
            soundManager.play("sfx.wav")
        }
    }

    IpcHandler {
        target: "themepicker"
        
        function toggle() {
            var willOpen = !themePickerWindow.windowVisible
            themePickerWindow.windowVisible = willOpen
            playWindowSound(willOpen)
        }
    }

    ThemePickerWindow {
        id: themePickerWindow
        visible: false
        
        theme: themeManager.theme
        themeManager: themeManager
        themesList: themeManager.themes
        themesLoaded: themeManager.themesLoaded
        soundManager: soundManager
        
        onApplyTheme: function(themeName) {
            soundManager.play("quick_click.wav")
            themeManager.loadTheme(themeName)
            themePickerWindow.windowVisible = false
        }
    }
}