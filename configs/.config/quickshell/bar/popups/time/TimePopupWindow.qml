import QtQuick
import Quickshell
import Quickshell.Wayland

import "modules"

PanelWindow {
    id: root

    property var theme: null
    property var soundManager: null
    property var stopwatch: null
    property var countdownTimer: null
    
    property bool windowVisible: false
    property bool isAnimating: false
    
    property real collapsedWidth: 180
    property real expandedWidth: 980
    property real expandedHeight: 360
    property real barOffset: 45

    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: root.barOffset + root.expandedHeight + 20

    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: windowVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    
    mask: Region {
        Region { item: popupRect }
    }

    function toggle() {
        windowVisible = !windowVisible
        if (soundManager) soundManager.play(windowVisible ? "list.wav" : "out.wav")
    }
    
    function close() {
        if (windowVisible) {
            windowVisible = false
            if (soundManager) soundManager.play("out.wav")
        }
    }

    onWindowVisibleChanged: {
        if (windowVisible) {
            visible = true
            openAnimation.start()
        } else {
            closeAnimation.start()
        }
    }

    // Анимация открытия
    SequentialAnimation {
        id: openAnimation
        
        onStarted: {
            root.isAnimating = true
            contentWrapper.opacity = 0
            contentWrapper.y = 12
            popupRect.scale = 0.96
            shadowRect.opacity = 0
        }
        
        // Фаза 1: раскрытие вниз с лёгким масштабированием
        ParallelAnimation {
            NumberAnimation { 
                target: popupRect 
                property: "height" 
                from: 0 
                to: root.expandedHeight 
                duration: 220 
                easing.type: Easing.OutCubic 
            }
            NumberAnimation { 
                target: popupRect 
                property: "scale" 
                from: 0.96 
                to: 1.0 
                duration: 220 
                easing.type: Easing.OutCubic 
            }
        }
        
        // Фаза 2: раскрытие в стороны с мягким отскоком
        NumberAnimation { 
            target: popupRect 
            property: "width" 
            from: root.collapsedWidth 
            to: root.expandedWidth 
            duration: 380 
            easing.type: Easing.OutBack 
            easing.overshoot: 1.12 
        }
        
        // Фаза 3: каскадное появление контента
        ParallelAnimation {
            NumberAnimation { 
                target: shadowRect 
                property: "opacity" 
                from: 0 
                to: 1 
                duration: 300 
                easing.type: Easing.OutCubic 
            }
            NumberAnimation { 
                target: contentWrapper 
                property: "y" 
                from: 12 
                to: 0 
                duration: 300 
                easing.type: Easing.OutCubic 
            }
            NumberAnimation { 
                target: contentWrapper 
                property: "opacity" 
                from: 0 
                to: 1 
                duration: 280 
                easing.type: Easing.OutCubic 
            }
        }
        
        onFinished: root.isAnimating = false
    }

    // Анимация закрытия
    SequentialAnimation {
        id: closeAnimation
        
        onStarted: {
            root.isAnimating = true
            shadowRect.opacity = 0
        }
        
        // Фаза 1: контент уходит вниз и исчезает
        ParallelAnimation {
            NumberAnimation { 
                target: contentWrapper 
                property: "opacity" 
                to: 0 
                duration: 100 
                easing.type: Easing.InCubic 
            }
            NumberAnimation { 
                target: contentWrapper 
                property: "y" 
                from: 0 
                to: 8 
                duration: 100 
                easing.type: Easing.InCubic 
            }
        }
        
        // Фаза 2: сворачивание в стороны с лёгким масштабированием
        ParallelAnimation {
            NumberAnimation { 
                target: popupRect 
                property: "width" 
                from: root.expandedWidth 
                to: root.collapsedWidth 
                duration: 220 
                easing.type: Easing.InCubic 
            }
            NumberAnimation { 
                target: popupRect 
                property: "scale" 
                from: 1.0 
                to: 0.97 
                duration: 220 
                easing.type: Easing.InCubic 
            }
        }
        
        // Фаза 3: сворачивание вниз
        NumberAnimation { 
            target: popupRect 
            property: "height" 
            from: root.expandedHeight 
            to: 0 
            duration: 200 
            easing.type: Easing.InCubic 
        }
        
        onFinished: {
            root.visible = false
            root.isAnimating = false
            popupRect.scale = 1.0
            contentWrapper.y = 0
        }
    }

    FocusScope {
        id: focusScope
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: function(event) {
            root.close()
            event.accepted = true
        }

        // Тень под рамкой
        Rectangle {
            id: shadowRect
            anchors.top: popupRect.top
            anchors.topMargin: 4
            anchors.horizontalCenter: popupRect.horizontalCenter
            width: popupRect.width
            height: popupRect.height
            radius: 16
            color: "#000000"
            opacity: 0
            
            Behavior on opacity { NumberAnimation { duration: 300 } }
        }
        
        // Размытие тени (имитация)
        Rectangle {
            anchors.top: shadowRect.top
            anchors.topMargin: 2
            anchors.horizontalCenter: shadowRect.horizontalCenter
            width: shadowRect.width + 8
            height: shadowRect.height + 8
            radius: 20
            color: "#000000"
            opacity: shadowRect.opacity * 0.3
        }

        // Прямоугольник попапа
        Rectangle {
            id: popupRect
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: root.barOffset
            
            width: root.collapsedWidth
            height: 0
            
            radius: 14
            color: root.theme && root.theme.colors ? root.theme.colors.background : "#181818"
            border.width: 1
            border.color: root.theme && root.theme.colors ? root.theme.colors.border : "#2A2A2A"
            clip: true
            
            transformOrigin: Item.Top
            
            // Содержимое попапа
            Item {
                id: contentWrapper
                anchors.fill: parent
                anchors.margins: 16
                
                opacity: 0
                
                // Календарь (слева)
                Calendar {
                    id: calendar
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    theme: root.theme
                }
                
                // Часы (по центру)
                BigClock {
                    id: bigClock
                    anchors.left: calendar.right
                    anchors.right: stopwatchTimer.left
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    theme: root.theme
                    stopwatch: root.stopwatch
                }
                
                // Секундомер/Таймер (справа)
                StopwatchTimer {
                    id: stopwatchTimer
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    theme: root.theme
                    soundManager: root.soundManager
                    stopwatch: root.stopwatch
                    countdownTimer: root.countdownTimer
                }
            }
        }

        // Области для закрытия по клику вне попапа
        MouseArea {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: popupRect.top
            onClicked: root.close()
        }
        
        MouseArea {
            anchors.top: popupRect.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            onClicked: root.close()
        }
        
        MouseArea {
            anchors.top: popupRect.top
            anchors.left: parent.left
            anchors.bottom: popupRect.bottom
            anchors.right: popupRect.left
            onClicked: root.close()
        }
        
        MouseArea {
            anchors.top: popupRect.top
            anchors.left: popupRect.right
            anchors.right: parent.right
            anchors.bottom: popupRect.bottom
            onClicked: root.close()
        }
    }
}