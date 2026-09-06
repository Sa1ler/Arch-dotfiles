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
    property var stopwatch: null  // ← ДОБАВЛЕНО
    
    signal closed()
    
    implicitHeight: clockWidget.implicitHeight
    implicitWidth: clockWidget.implicitWidth
    
    property bool anyModeActive: wallpaperMode || themeMode || launcherMode || screenshotMode
    
    onAnyModeActiveChanged: {
        if (anyModeActive) {
            focusScope.forceActiveFocus()
        }
    }

    FocusScope {
        id: focusScope
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: function(event) {
            if (root.launcherMode) {
                launcher.close()
            } else {
                root.closed()
            }
            event.accepted = true
        }
        
        Keys.onLeftPressed: function(event) {
            if (root.wallpaperMode) {
                wallpaperPicker.navigateLeft()
            } else if (root.themeMode) {
                themePicker.navigateLeft()
            }
            event.accepted = true
        }
        
        Keys.onRightPressed: function(event) {
            if (root.wallpaperMode) {
                wallpaperPicker.navigateRight()
            } else if (root.themeMode) {
                themePicker.navigateRight()
            }
            event.accepted = true
        }
        
        Keys.onUpPressed: function(event) {
            if (root.launcherMode) {
                launcher.navigateUp()
            }
            event.accepted = true
        }
        
        Keys.onDownPressed: function(event) {
            if (root.launcherMode) {
                launcher.navigateDown()
            }
            event.accepted = true
        }
        
        Keys.onReturnPressed: function(event) {
            if (root.wallpaperMode) {
                wallpaperPicker.applyCurrent()
            } else if (root.themeMode) {
                themePicker.applyCurrent()
            } else if (root.launcherMode) {
                launcher.applyCurrent()
            }
            event.accepted = true
        }

        Clock {
            id: clockWidget
            anchors.centerIn: parent
            
            theme: root.theme
            soundManager: root.soundManager
            stopwatch: root.stopwatch  // ← ДОБАВЛЕНО
            
            opacity: root.anyModeActive ? 0 : 1
            scale: root.anyModeActive ? 0.9 : 1
            
            Behavior on opacity { NumberAnimation { duration: 150 } }
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        }
        
        WallpaperPicker {
            id: wallpaperPicker
            anchors.fill: parent
            
            theme: root.theme
            soundManager: root.soundManager
            active: root.wallpaperMode
            enabled: root.wallpaperMode
            
            onClose: {
                root.closed()
            }
            
            opacity: root.wallpaperMode ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: root.wallpaperMode ? 350 : 120
                    easing.type: Easing.OutCubic
                }
            }
        }
        
        ThemePicker {
            id: themePicker
            anchors.fill: parent
            
            theme: root.theme
            themeManager: root.themeManager
            soundManager: root.soundManager
            active: root.themeMode
            enabled: root.themeMode
            
            onClose: {
                root.closed()
            }
            
            opacity: root.themeMode ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: root.themeMode ? 350 : 120
                    easing.type: Easing.OutCubic
                }
            }
        }
        
        Launcher {
            id: launcher
            anchors.fill: parent
            
            theme: root.theme
            soundManager: root.soundManager
            active: root.launcherMode
            enabled: root.launcherMode
            
            onClose: {
                root.closed()
            }
            
            opacity: root.launcherMode ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: root.launcherMode ? 350 : 120
                    easing.type: Easing.OutCubic
                }
            }
        }
        
        ScreenshotMenu {
            id: screenshotMenu
            anchors.fill: parent
            
            theme: root.theme
            soundManager: root.soundManager
            active: root.screenshotMode
            enabled: root.screenshotMode
            
            onClose: {
                root.closed()
            }
            
            opacity: root.screenshotMode ? 1 : 0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: root.screenshotMode ? 350 : 120
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}