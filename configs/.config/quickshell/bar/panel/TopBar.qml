import QtQuick
import Quickshell
import Quickshell.Wayland

import "sections"

PanelWindow {
    id: root

    property var theme: null
    property var themeManager: null
    property var soundManager: null
    
    property real barHeight: 33
    
    property real topMargin: 6
    property real sideMargin: 3
    property real sectionSpacing: 100
    property real sectionRadius: 10
    property real sectionPadding: 6
    
    property real leftSectionWidth: 0
    property real centerSectionWidth: 0
    property real rightSectionWidth: 0
    
    // Размеры для обоев и тем
    property real expandedWidth: 620
    property real expandedHeight: 280
    
    // Размеры для лаунчера
    property real launcherWidth: 440
    property real launcherHeight: 340
    
    // Размеры для скриншотов (ещё компактнее)
    property real screenshotWidth: 250
    property real screenshotHeight: 76
    
    // Режимы
    property bool wallpaperMode: false
    property bool themeMode: false
    property bool launcherMode: false
    property bool screenshotMode: false
    property bool anyModeActive: wallpaperMode || themeMode || launcherMode || screenshotMode

    function toggleWallpaperMode() {
        wallpaperMode = !wallpaperMode
        if (wallpaperMode) {
            if (themeMode) themeMode = false
            if (launcherMode) launcherMode = false
            if (screenshotMode) screenshotMode = false
        }
    }
    
    function closeWallpaperMode() {
        if (wallpaperMode) wallpaperMode = false
    }
    
    function toggleThemeMode() {
        themeMode = !themeMode
        if (themeMode) {
            if (wallpaperMode) wallpaperMode = false
            if (launcherMode) launcherMode = false
            if (screenshotMode) screenshotMode = false
        }
    }
    
    function closeThemeMode() {
        if (themeMode) themeMode = false
    }
    
    function toggleLauncherMode() {
        launcherMode = !launcherMode
        if (launcherMode) {
            if (wallpaperMode) wallpaperMode = false
            if (themeMode) themeMode = false
            if (screenshotMode) screenshotMode = false
        }
    }
    
    function closeLauncherMode() {
        if (launcherMode) launcherMode = false
    }
    
    function toggleScreenshotMode() {
        screenshotMode = !screenshotMode
        if (screenshotMode) {
            if (wallpaperMode) wallpaperMode = false
            if (themeMode) themeMode = false
            if (launcherMode) launcherMode = false
        }
    }
    
    function closeScreenshotMode() {
        if (screenshotMode) screenshotMode = false
    }

    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: root.topMargin + root.barHeight + Math.max(root.expandedHeight, root.launcherHeight, root.screenshotHeight)

    exclusiveZone: barHeight + topMargin
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: root.anyModeActive ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    
    mask: Region {
        Region { item: leftSectionBg }
        Region { item: centerSectionBg }
        Region { item: rightSectionBg }
    }

    // ЛЕВЫЙ СЕКТОР
    Rectangle {
        id: leftSectionBg
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: root.topMargin
        anchors.leftMargin: root.sideMargin
        height: root.barHeight
        width: root.leftSectionWidth > 0 ? 
               root.leftSectionWidth : 
               (leftSection.implicitWidth + root.sectionPadding * 2 + 8)
        radius: root.sectionRadius
        color: root.theme && root.theme.colors ? root.theme.colors.surface : "#1A1F26"
        border.width: 1
        border.color: root.theme.colors.border || "#2A2A2A"
        
        LeftSection {
            id: leftSection
            anchors.centerIn: parent
            theme: root.theme
            soundManager: root.soundManager
        }
    }
    
    // ЦЕНТРАЛЬНЫЙ СЕКТОР
    Rectangle {
        id: centerSectionBg
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: root.topMargin
        
        width: {
            if (root.launcherMode) return root.launcherWidth
            if (root.screenshotMode) return root.screenshotWidth
            if (root.wallpaperMode || root.themeMode) return root.expandedWidth
            return (root.centerSectionWidth > 0 ? 
                    root.centerSectionWidth : 
                    (centerSection.implicitWidth + root.sectionPadding * 2 + 8))
        }
        
        height: {
            if (root.launcherMode) return root.launcherHeight
            if (root.screenshotMode) return root.screenshotHeight
            if (root.wallpaperMode || root.themeMode) return root.expandedHeight
            return root.barHeight
        }
        
        radius: root.sectionRadius
        color: root.theme && root.theme.colors ? root.theme.colors.surface : "#1A1F26"
        border.width: 1
        border.color: root.theme.colors.border || "#2A2A2A"
        clip: true
        
        Behavior on width {
            NumberAnimation {
                duration: 450
                easing.type: root.anyModeActive ? Easing.OutCubic : Easing.InCubic
            }
        }
        
        Behavior on height {
            NumberAnimation {
                duration: 450
                easing.type: root.anyModeActive ? Easing.OutCubic : Easing.InCubic
            }
        }
        
        CenterSection {
            id: centerSection
            anchors.fill: parent
            anchors.margins: root.anyModeActive ? 0 : root.sectionPadding
            
            theme: root.theme
            themeManager: root.themeManager
            soundManager: root.soundManager
            wallpaperMode: root.wallpaperMode
            themeMode: root.themeMode
            launcherMode: root.launcherMode
            screenshotMode: root.screenshotMode
            
            onClosed: {
                if (root.wallpaperMode) {
                    root.closeWallpaperMode()
                } else if (root.themeMode) {
                    root.closeThemeMode()
                } else if (root.launcherMode) {
                    root.closeLauncherMode()
                } else if (root.screenshotMode) {
                    root.closeScreenshotMode()
                }
            }
        }
    }
    
    // ПРАВЫЙ СЕКТОР
    Rectangle {
        id: rightSectionBg
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: root.topMargin
        anchors.rightMargin: root.sideMargin
        height: root.barHeight
        width: root.rightSectionWidth > 0 ? 
               root.rightSectionWidth : 
               (rightSection.implicitWidth + root.sectionPadding * 2 + 8)
        radius: root.sectionRadius
        color: root.theme && root.theme.colors ? root.theme.colors.surface : "#1A1F26"
        border.width: 1
        border.color: root.theme.colors.border || "#2A2A2A"
        
        RightSection {
            id: rightSection
            anchors.centerIn: parent
            theme: root.theme
            soundManager: root.soundManager
        }
    }
}