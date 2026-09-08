import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "panel"
import "widgets"
import "popups/time"

ShellRoot {
    id: root

    ThemeManager { id: themeManager }
    
    SoundPlayer { 
        id: soundManager
        soundsDir: Quickshell.shellDir + "/../sounds"
    }
    
    Stopwatch { id: stopwatch }
    CountdownTimer { id: countdownTimer }

    // Оптимизированный IPC
    IpcHandler {
        target: "topbar"
        
        function toggleWallpaper() { topBar.setMode(topBar.modeWallpaper) }
        function toggleTheme() { topBar.setMode(topBar.modeTheme) }
        function toggleLauncher() { topBar.setMode(topBar.modeLauncher) }
        function toggleScreenshot() { topBar.setMode(topBar.modeScreenshot) }
        function toggleTimePopup() { timePopupWindow.toggle() }
        
        function closeWallpaper() { topBar.closeMode(topBar.modeWallpaper) }
        function closeTheme() { topBar.closeMode(topBar.modeTheme) }
        function closeLauncher() { topBar.closeMode(topBar.modeLauncher) }
        function closeScreenshot() { topBar.closeMode(topBar.modeScreenshot) }
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
        visible: false // <-- ИСПРАВЛЕНО: было false1, теперь корректный boolean
        
        theme: themeManager.theme
        soundManager: soundManager
        stopwatch: stopwatch
        countdownTimer: countdownTimer
    }
}