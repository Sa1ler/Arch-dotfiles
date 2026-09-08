import QtQuick
import "../../widgets"

Item {
    id: root

    property var theme: null
    property var themeManager: null
    property var soundManager: null
    property bool wallpaperMode: false
    property bool themeMode: false
    property bool launcherMode: false
    property bool screenshotMode: false
    property bool timerFinishedMode: false
    property var stopwatch: null
    property var countdownTimer: null
    
    signal closed()
    
    property bool anyModeActive: wallpaperMode || themeMode || launcherMode || screenshotMode || timerFinishedMode

    FocusScope {
        id: focusScope
        anchors.fill: parent
        
        // ОПТИМИЗАЦИЯ: Декларативное управление фокусом вместо forceActiveFocus()
        focus: root.anyModeActive 

        Keys.onEscapePressed: function(event) {
            if (root.launcherMode) launcher.close()
            else root.closed()
            event.accepted = true
        }
        
        Keys.onLeftPressed: function(event) {
            if (root.wallpaperMode) wallpaperPicker.navigateLeft()
            else if (root.themeMode) themePicker.navigateLeft()
            event.accepted = true
        }
        
        Keys.onRightPressed: function(event) {
            if (root.wallpaperMode) wallpaperPicker.navigateRight()
            else if (root.themeMode) themePicker.navigateRight()
            event.accepted = true
        }
        
        Keys.onUpPressed: function(event) {
            if (root.launcherMode) launcher.navigateUp()
            event.accepted = true
        }
        
        Keys.onDownPressed: function(event) {
            if (root.launcherMode) launcher.navigateDown()
            event.accepted = true
        }
        
        Keys.onReturnPressed: function(event) {
            if (root.wallpaperMode) wallpaperPicker.applyCurrent()
            else if (root.themeMode) themePicker.applyCurrent()
            else if (root.launcherMode) launcher.applyCurrent()
            event.accepted = true
        }

        // ===== ЧАСЫ =====
        Clock {
            id: clockWidget
            anchors.fill: parent
            
            theme: root.theme
            soundManager: root.soundManager
            stopwatch: root.stopwatch
            countdownTimer: root.countdownTimer
            
            // GPU Оптимизация: Скрываем после завершения анимации исчезновения
            visible: !root.anyModeActive || opacity > 0
            opacity: root.anyModeActive ? 0 : 1
            scale: root.anyModeActive ? 0.95 : 1
            
            Behavior on opacity { NumberAnimation { duration: root.anyModeActive ? 150 : 250; easing.type: Easing.OutQuart } }
            Behavior on scale { NumberAnimation { duration: root.anyModeActive ? 150 : 250; easing.type: Easing.OutQuart } }
        }
        
        // ===== ЭКРАН ЗАВЕРШЕНИЯ ТАЙМЕРА =====
        TimerFinished {
            id: timerFinished
            anchors.fill: parent
            
            theme: root.theme
            countdownTimer: root.countdownTimer
            active: root.timerFinishedMode
            enabled: root.timerFinishedMode
            
            onClose: root.closed()
            
            visible: root.timerFinishedMode || opacity > 0
            opacity: root.timerFinishedMode ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: root.timerFinishedMode ? 300 : 150
                    easing.type: Easing.OutQuart
                }
            }
        }
        
        // ===== WALLPAPER PICKER =====
        WallpaperPicker {
            id: wallpaperPicker
            anchors.fill: parent
            
            theme: root.theme
            soundManager: root.soundManager
            active: root.wallpaperMode
            enabled: root.wallpaperMode
            
            onClose: root.closed()
            
            visible: root.wallpaperMode || opacity > 0
            opacity: root.wallpaperMode ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: root.wallpaperMode ? 300 : 150
                    easing.type: Easing.OutQuart
                }
            }
        }
        
        // ===== THEME PICKER =====
        ThemePicker {
            id: themePicker
            anchors.fill: parent
            
            theme: root.theme
            themeManager: root.themeManager
            soundManager: root.soundManager
            active: root.themeMode
            enabled: root.themeMode
            
            onClose: root.closed()
            
            visible: root.themeMode || opacity > 0
            opacity: root.themeMode ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: root.themeMode ? 300 : 150
                    easing.type: Easing.OutQuart
                }
            }
        }
        
        // ===== LAUNCHER =====
        Launcher {
            id: launcher
            anchors.fill: parent
            
            theme: root.theme
            soundManager: root.soundManager
            active: root.launcherMode
            enabled: root.launcherMode
            
            onClose: root.closed()
            
            visible: root.launcherMode || opacity > 0
            opacity: root.launcherMode ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: root.launcherMode ? 300 : 150
                    easing.type: Easing.OutQuart
                }
            }
        }
        
        // ===== SCREENSHOT MENU =====
        ScreenshotMenu {
            id: screenshotMenu
            anchors.fill: parent
            
            theme: root.theme
            soundManager: root.soundManager
            active: root.screenshotMode
            enabled: root.screenshotMode
            
            onClose: root.closed()
            
            visible: root.screenshotMode || opacity > 0
            opacity: root.screenshotMode ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: root.screenshotMode ? 300 : 150
                    easing.type: Easing.OutQuart
                }
            }
        }
    }
}