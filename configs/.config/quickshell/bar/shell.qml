import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

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

    IpcHandler {
        target: "topbar"
        
        function toggleWallpaper() {
            topBar.toggleWallpaperMode()
        }
        
        function closeWallpaper() {
            topBar.closeWallpaperMode()
        }
        
        function toggleTheme() {
            topBar.toggleThemeMode()
        }
        
        function closeTheme() {
            topBar.closeThemeMode()
        }
        
        function toggleLauncher() {
            topBar.toggleLauncherMode()
        }
        
        function closeLauncher() {
            topBar.closeLauncherMode()
        }
    }

    TopBar {
        id: topBar
        visible: true
        
        theme: themeManager.theme
        themeManager: themeManager
        soundManager: soundManager
    }
}