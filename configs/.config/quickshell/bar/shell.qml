import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "panel"
import "widgets"
import "popups/time"

ShellRoot {
    id: root

    ThemeManager {
        id: themeManager
    }

    SoundPlayer {
        id: soundManager
        soundsDir: Quickshell.shellDir + "/../sounds"
    }
    
    Stopwatch {
        id: stopwatch
    }
    
    CountdownTimer {
        id: countdownTimer
    }

    IpcHandler {
        target: "topbar"
        
        function toggleWallpaper() { topBar.toggleWallpaperMode() }
        function closeWallpaper() { topBar.closeWallpaperMode() }
        function toggleTheme() { topBar.toggleThemeMode() }
        function closeTheme() { topBar.closeThemeMode() }
        function toggleLauncher() { topBar.toggleLauncherMode() }
        function closeLauncher() { topBar.closeLauncherMode() }
        function toggleScreenshot() { topBar.toggleScreenshotMode() }
        function closeScreenshot() { topBar.closeScreenshotMode() }
        function toggleTimePopup() { timePopupWindow.toggle() }
    }

    TopBar {
        id: topBar
        visible: true
        
        theme: themeManager.theme
        themeManager: themeManager
        soundManager: soundManager
        timePopup: timePopupWindow
        stopwatch: stopwatch
        countdownTimer: countdownTimer
    }
    
    TimePopupWindow {
        id: timePopupWindow
        visible: false
        
        theme: themeManager.theme
        soundManager: soundManager
        stopwatch: stopwatch
        countdownTimer: countdownTimer
    }
}