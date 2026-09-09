import QtQuick
import Quickshell
import Quickshell.Wayland

import "sections"

PanelWindow {
    id: root

    // === ВАЖНО: Возвращаем property var для JS-объектов ===
    // Строгая типизация QtObject/Item ломает передачу JSON-объектов (QJSValue)
    property var theme: null
    property var themeManager: null
    property var soundManager: null
    property var timePopup: null
    property var stopwatch: null
    property var countdownTimer: null
    
    // === Целочисленные свойства (быстрее, чем real) ===
    property int barHeight: 33
    property int topMargin: 6
    property int sideMargin: 3
    property int sectionRadius: 10
    property int sectionPadding: 6
    
    // === State Machine: Единый источник правды для режимов ===
    readonly property int modeNone: 0
    readonly property int modeWallpaper: 1
    readonly property int modeTheme: 2
    readonly property int modeLauncher: 3
    readonly property int modeScreenshot: 4
    readonly property int modeTimerFinished: 5

    property int currentMode: modeNone
    readonly property bool anyModeActive: currentMode !== modeNone

    // === Константы размеров ===
    readonly property int expandedWidth: 580
    readonly property int expandedHeight: 280
    readonly property int launcherWidth: 400
    readonly property int launcherHeight: 340
    readonly property int screenshotWidth: 250
    readonly property int screenshotHeight: 76
    readonly property int timerFinishedWidth: 300
    readonly property int timerFinishedHeight: 120
    readonly property int badgeWidth: 70

    // === TextMetrics: Вычисляем ОДИН РАЗ при старте ===
    property int timeWidth: 0
    property int dateWidth: 0
    
    Component.onCompleted: {
        timeWidth = timeMetrics.advanceWidth
        dateWidth = dateMetrics.advanceWidth
    }

    TextMetrics {
        id: timeMetrics
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 17
        font.weight: Font.Black
        text: "00:00" 
    }
    
    TextMetrics {
        id: dateMetrics
        font.family: "JetBrainsMono Nerd Font Mono"
        font.pixelSize: 15
        font.weight: Font.Black
        text: "30 сентября" 
    }
    
    readonly property int centerBaseWidth: timeWidth + 10 + 5 + 10 + dateWidth + (sectionPadding * 2) + 12
    readonly property int centerExpandedWidth: timeWidth + 10 + badgeWidth + 10 + dateWidth + (sectionPadding * 2) + 12

    // === Функции управления ===
    function setMode(mode) {
        currentMode = (currentMode === mode) ? modeNone : mode
    }
    
    function closeMode(mode) {
        if (currentMode === mode) currentMode = modeNone
    }

    function dismissTimer() {
        if (countdownTimer) countdownTimer.dismiss()
        autoCloseTimer.stop()
    }

    // === Сигналы таймера ===
    Connections {
        target: root.countdownTimer
        enabled: root.countdownTimer !== null
        
        function onFinishedChanged() {
            if (countdownTimer && countdownTimer.finished) {
                root.currentMode = modeTimerFinished
                autoCloseTimer.restart()
                if (soundManager) soundManager.play("tip.wav")
            } else if (root.currentMode === modeTimerFinished) {
                root.currentMode = modeNone
                dismissTimer()
            }
        }
    }
    
    Timer {
        id: autoCloseTimer
        interval: 5000
        onTriggered: {
            root.currentMode = modeNone
            dismissTimer()
        }
    }

    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: root.topMargin + root.barHeight + Math.max(
        root.expandedHeight, 
        root.launcherHeight, 
        root.screenshotHeight, 
        root.timerFinishedHeight
    )

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
        width: leftSection.implicitWidth + (root.sectionPadding * 2) + 8
        radius: root.sectionRadius
        color: root.theme && root.theme.colors ? root.theme.colors.surface : "#1A1F26"
        border.width: 1
        border.color: root.theme && root.theme.colors ? (root.theme.colors.border || "#2A2A2A") : "#2A2A2A"
        
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
            // === НОВОЕ: Расширение при активной записи ===
            if (root.screenRecording) return root.centerExpandedWidth
            
            switch (root.currentMode) {
                case root.modeTimerFinished: return root.timerFinishedWidth
                case root.modeLauncher: return root.launcherWidth
                case root.modeScreenshot: return root.screenshotWidth
                case root.modeWallpaper: 
                case root.modeTheme: return root.expandedWidth
                default:
                    var hasTimer = root.countdownTimer && root.countdownTimer.running
                    var hasStopwatch = root.stopwatch && root.stopwatch.running
                    return (hasTimer || hasStopwatch) ? root.centerExpandedWidth : root.centerBaseWidth
            }
        }
        
        height: {
            switch (root.currentMode) {
                case root.modeTimerFinished: return root.timerFinishedHeight
                case root.modeLauncher: return root.launcherHeight
                case root.modeScreenshot: return root.screenshotHeight
                case root.modeWallpaper: 
                case root.modeTheme: return root.expandedHeight
                default: return root.barHeight
            }
        }
        
        radius: root.sectionRadius
        color: root.theme && root.theme.colors ? root.theme.colors.surface : "#1A1F26"
        border.width: 1
        border.color: root.theme && root.theme.colors ? (root.theme.colors.border || "#2A2A2A") : "#2A2A2A"
        clip: true 
        
        Behavior on width {
            NumberAnimation { duration: 300; easing.type: Easing.OutQuart }
        }
        
        Behavior on height {
            NumberAnimation { duration: 300; easing.type: Easing.OutQuart }
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
            
            wallpaperMode: root.currentMode === root.modeWallpaper
            themeMode: root.currentMode === root.modeTheme
            launcherMode: root.currentMode === root.modeLauncher
            screenshotMode: root.currentMode === root.modeScreenshot
            timerFinishedMode: root.currentMode === root.modeTimerFinished
            
            onClosed: {
                root.currentMode = root.modeNone
                dismissTimer()
            }
        }
        
        MouseArea {
            anchors.fill: parent
            // === ИСПРАВЛЕНО: Отключаем при активной записи (чтобы клик по бейджу не открывал попап) ===
            enabled: !root.anyModeActive
            cursorShape: Qt.PointingHandCursor
            
            onClicked: {
                if (root.timePopup) root.timePopup.toggle()
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
        width: rightSection.implicitWidth + (root.sectionPadding * 2) + 8
        radius: root.sectionRadius
        color: root.theme && root.theme.colors ? root.theme.colors.surface : "#1A1F26"
        border.width: 1
        border.color: root.theme && root.theme.colors ? (root.theme.colors.border || "#2A2A2A") : "#2A2A2A"
        
        RightSection {
            id: rightSection
            anchors.centerIn: parent
            theme: root.theme
            soundManager: root.soundManager
        }
    }
}