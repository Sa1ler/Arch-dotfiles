import QtQuick
import Quickshell
import Quickshell.Wayland

import "sections"

PanelWindow {
    id: root

    property var theme: null
    property var themeManager: null
    property var soundManager: null
    property var timePopup: null
    property var stopwatch: null
    
    property real barHeight: 33
    property real topMargin: 6
    property real sideMargin: 3
    property real sectionSpacing: 100
    property real sectionRadius: 10
    property real sectionPadding: 6
    
    property real leftSectionWidth: 0
    property real centerSectionWidth: 0
    property real rightSectionWidth: 0
    
    property real expandedWidth: 580
    property real expandedHeight: 280
    property real launcherWidth: 400
    property real launcherHeight: 340
    property real screenshotWidth: 250
    property real screenshotHeight: 76
    
    property bool wallpaperMode: false
    property bool themeMode: false
    property bool launcherMode: false
    property bool screenshotMode: false
    property bool anyModeActive: wallpaperMode || themeMode || launcherMode || screenshotMode
    
    // ===== TextMetrics для точного вычисления ширины часов =====
    readonly property var monthNames: [
        "января", "февраля", "марта", "апреля", "мая", "июня",
        "июля", "августа", "сентября", "октября", "ноября", "декабря"
    ]
    
    TextMetrics {
        id: timeMetrics
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 17
        font.weight: Font.Black
        text: Qt.formatTime(new Date(), "HH:mm")
    }
    
    TextMetrics {
        id: dateMetrics
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 15
        font.weight: Font.Black
        text: {
            var now = new Date()
            return now.getDate() + " " + root.monthNames[now.getMonth()]
        }
    }
    
    // Фиксированная ширина секундомера (иконка + "00:00" + padding)
    property real stopwatchBadgeWidth: 70
    
    // Вычисляемые ширины центрального блока
    property real centerBaseWidth: timeMetrics.advanceWidth + 10 + 5 + 10 + dateMetrics.advanceWidth + sectionPadding * 2 + 12
    property real centerExpandedWidth: timeMetrics.advanceWidth + 10 + stopwatchBadgeWidth + 10 + dateMetrics.advanceWidth + sectionPadding * 2 + 12

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
    
    Rectangle {
        id: centerSectionBg
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: root.topMargin
        
        width: {
            if (root.launcherMode) return root.launcherWidth
            if (root.screenshotMode) return root.screenshotWidth
            if (root.wallpaperMode || root.themeMode) return root.expandedWidth
            // Обычный режим: зависит от секундомера
            return root.stopwatch && root.stopwatch.running ? root.centerExpandedWidth : root.centerBaseWidth
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
        
        // ПЛАВНАЯ АНИМАЦИЯ ширины — синхронная для рамки и содержимого
        Behavior on width {
            NumberAnimation {
                duration: 450
                easing.type: Easing.OutCubic
            }
        }
        
        Behavior on height {
            NumberAnimation {
                duration: 450
                easing.type: Easing.OutCubic
            }
        }
        
        CenterSection {
            id: centerSection
            anchors.fill: parent
            anchors.margins: root.anyModeActive ? 0 : root.sectionPadding
            
            theme: root.theme
            themeManager: root.themeManager
            soundManager: root.soundManager
            stopwatch: root.stopwatch
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
        
        MouseArea {
            anchors.fill: parent
            enabled: !root.anyModeActive
            cursorShape: Qt.PointingHandCursor
            
            onClicked: {
                if (root.timePopup) {
                    root.timePopup.toggle()
                }
            }
        }
    }
    
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