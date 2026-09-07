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
    property var countdownTimer: null
    
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
    property real expandedWidth: 580
    property real expandedHeight: 280
    
    // Размеры для лаунчера
    property real launcherWidth: 400
    property real launcherHeight: 340
    
    // Размеры для скриншотов
    property real screenshotWidth: 250
    property real screenshotHeight: 76
    
    // Размеры для завершения таймера
    property real timerFinishedWidth: 300
    property real timerFinishedHeight: 120
    
    // Режимы
    property bool wallpaperMode: false
    property bool themeMode: false
    property bool launcherMode: false
    property bool screenshotMode: false
    property bool timerFinishedMode: false
    property bool anyModeActive: wallpaperMode || themeMode || launcherMode || screenshotMode || timerFinishedMode
    
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
    
    // Фиксированная ширина бейджа (иконка + "00:00" + padding)
    property real badgeWidth: 70
    
    // Вычисляемые ширины центрального блока
    property real centerBaseWidth: timeMetrics.advanceWidth + 10 + 5 + 10 + dateMetrics.advanceWidth + sectionPadding * 2 + 12
    property real centerExpandedWidth: timeMetrics.advanceWidth + 10 + badgeWidth + 10 + dateMetrics.advanceWidth + sectionPadding * 2 + 12

    // ===== Функции переключения режимов =====
    function toggleWallpaperMode() {
        wallpaperMode = !wallpaperMode
        if (wallpaperMode) {
            if (themeMode) themeMode = false
            if (launcherMode) launcherMode = false
            if (screenshotMode) screenshotMode = false
            if (timerFinishedMode) closeTimerFinishedMode()
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
            if (timerFinishedMode) closeTimerFinishedMode()
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
            if (timerFinishedMode) closeTimerFinishedMode()
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
            if (timerFinishedMode) closeTimerFinishedMode()
        }
    }
    
    function closeScreenshotMode() {
        if (screenshotMode) screenshotMode = false
    }
    
    function closeTimerFinishedMode() {
        timerFinishedMode = false
        if (countdownTimer) countdownTimer.dismiss()
        autoCloseTimer.stop()
    }
    
    // ===== Реакция на завершение таймера =====
    Connections {
        target: root.countdownTimer
        
        function onFinishedChanged() {
            if (countdownTimer && countdownTimer.finished) {
                // Закрываем другие режимы
                if (wallpaperMode) wallpaperMode = false
                if (themeMode) themeMode = false
                if (launcherMode) launcherMode = false
                if (screenshotMode) screenshotMode = false
                
                timerFinishedMode = true
                autoCloseTimer.restart()
                if (soundManager) soundManager.play("tip.wav")
            } else {
                if (timerFinishedMode) timerFinishedMode = false
            }
        }
    }
    
    // Автозакрытие через 5 секунд
    Timer {
        id: autoCloseTimer
        interval: 5000
        onTriggered: {
            root.closeTimerFinishedMode()
        }
    }

    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: root.topMargin + root.barHeight + Math.max(root.expandedHeight, root.launcherHeight, root.screenshotHeight, root.timerFinishedHeight)

    exclusiveZone: barHeight + topMargin
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: root.anyModeActive ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    
    mask: Region {
        Region { item: leftSectionBg }
        Region { item: centerSectionBg }
        Region { item: rightSectionBg }
    }

    // ===== ЛЕВЫЙ СЕКТОР =====
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
    
    // ===== ЦЕНТРАЛЬНЫЙ СЕКТОР =====
    Rectangle {
        id: centerSectionBg
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: root.topMargin
        
        width: {
            if (root.timerFinishedMode) return root.timerFinishedWidth
            if (root.launcherMode) return root.launcherWidth
            if (root.screenshotMode) return root.screenshotWidth
            if (root.wallpaperMode || root.themeMode) return root.expandedWidth
            
            // Обычный режим: зависит от секундомера/таймера
            var hasTimer = root.countdownTimer && root.countdownTimer.running
            var hasStopwatch = root.stopwatch && root.stopwatch.running
            if (hasTimer || hasStopwatch) return root.centerExpandedWidth
            return root.centerBaseWidth
        }
        
        height: {
            if (root.timerFinishedMode) return root.timerFinishedHeight
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
            countdownTimer: root.countdownTimer
            wallpaperMode: root.wallpaperMode
            themeMode: root.themeMode
            launcherMode: root.launcherMode
            screenshotMode: root.screenshotMode
            timerFinishedMode: root.timerFinishedMode
            
            onClosed: {
                if (root.wallpaperMode) {
                    root.closeWallpaperMode()
                } else if (root.themeMode) {
                    root.closeThemeMode()
                } else if (root.launcherMode) {
                    root.closeLauncherMode()
                } else if (root.screenshotMode) {
                    root.closeScreenshotMode()
                } else if (root.timerFinishedMode) {
                    root.closeTimerFinishedMode()
                }
            }
        }
        
        // Клик по центральному блоку в обычном состоянии — открыть попап времени
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
    
    // ===== ПРАВЫЙ СЕКТОР =====
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