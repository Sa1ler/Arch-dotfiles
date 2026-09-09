import QtQuick
import Qt5Compat.GraphicalEffects
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
    
    // === Целочисленные размеры (быстрее, чем real) ===
    property int collapsedWidth: 180
    property int expandedWidth: 980
    property int expandedHeight: 360
    property int barOffset: 45
    
    // === Кэширование цветов темы ===
    readonly property color bgColor: root.theme && root.theme.colors ? root.theme.colors.background : "#181818"
    readonly property color borderColor: root.theme && root.theme.colors ? root.theme.colors.border : "#2A2A2A"

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

    // === Анимация открытия (3 фазы, но параллельно где возможно) ===
    SequentialAnimation {
        id: openAnimation
        
        onStarted: {
            contentWrapper.opacity = 0
            contentWrapper.y = 12
            popupRect.scale = 0.96
            shadowRect.opacity = 0
        }
        
        // Фаза 1: раскрытие вниз + масштабирование
        ParallelAnimation {
            NumberAnimation { 
                target: popupRect 
                property: "height" 
                from: 0 
                to: root.expandedHeight 
                duration: 200 
                easing.type: Easing.OutQuart 
            }
            NumberAnimation { 
                target: popupRect 
                property: "scale" 
                from: 0.96 
                to: 1.0 
                duration: 200 
                easing.type: Easing.OutQuart 
            }
        }
        
        // Фаза 2: раскрытие в стороны с мягким отскоком + тень
        ParallelAnimation {
            NumberAnimation { 
                target: popupRect 
                property: "width" 
                from: root.collapsedWidth 
                to: root.expandedWidth 
                duration: 340 
                easing.type: Easing.OutBack 
                easing.overshoot: 1.08
            }
            NumberAnimation { 
                target: shadowRect 
                property: "opacity" 
                from: 0 
                to: 1 
                duration: 280 
                easing.type: Easing.OutQuart 
            }
        }
        
        // Фаза 3: каскадное появление контента
        ParallelAnimation {
            NumberAnimation { 
                target: contentWrapper 
                property: "y" 
                from: 12 
                to: 0 
                duration: 280 
                easing.type: Easing.OutQuart 
            }
            NumberAnimation { 
                target: contentWrapper 
                property: "opacity" 
                from: 0 
                to: 1 
                duration: 260 
                easing.type: Easing.OutQuart 
            }
        }
    }

    // === Анимация закрытия (быстрее и чище) ===
    SequentialAnimation {
        id: closeAnimation
        
        onStarted: shadowRect.opacity = 0
        
        // Фаза 1: контент уходит вниз и исчезает
        ParallelAnimation {
            NumberAnimation { 
                target: contentWrapper 
                property: "opacity" 
                to: 0 
                duration: 120 
                easing.type: Easing.InQuart 
            }
            NumberAnimation { 
                target: contentWrapper 
                property: "y" 
                from: 0 
                to: 10 
                duration: 120 
                easing.type: Easing.InQuart 
            }
        }
        
        // Фаза 2: сворачивание в стороны + масштабирование
        ParallelAnimation {
            NumberAnimation { 
                target: popupRect 
                property: "width" 
                from: root.expandedWidth 
                to: root.collapsedWidth 
                duration: 200 
                easing.type: Easing.InQuart 
            }
            NumberAnimation { 
                target: popupRect 
                property: "scale" 
                from: 1.0 
                to: 0.97 
                duration: 200 
                easing.type: Easing.InQuart 
            }
        }
        
        // Фаза 3: сворачивание вниз
        NumberAnimation { 
            target: popupRect 
            property: "height" 
            from: root.expandedHeight 
            to: 0 
            duration: 180 
            easing.type: Easing.InQuart 
        }
        
        onFinished: {
            root.visible = false
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

        // === Нативная GPU-тень через DropShadow ===
        // Выглядит намного лучше, чем два Rectangle, и рендерится аппаратно
        Rectangle {
            id: shadowRect
            anchors.top: popupRect.top
            anchors.horizontalCenter: popupRect.horizontalCenter
            width: popupRect.width
            height: popupRect.height
            radius: 16
            color: "#000000"
            opacity: 0
            
            layer.enabled: opacity > 0.01
            layer.effect: DropShadow {
                transparentBorder: true
                radius: 24
                samples: 32
                color: Qt.rgba(0, 0, 0, 0.5)
                horizontalOffset: 0
                verticalOffset: 8
            }
        }

        // === Прямоугольник попапа ===
        Rectangle {
            id: popupRect
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: root.barOffset
            
            width: root.collapsedWidth
            height: 0
            
            radius: 14
            color: root.bgColor
            border.width: 1
            border.color: root.borderColor
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

        // === ОДИН MouseArea для закрытия по клику вне попапа ===
        // Вместо 4 отдельных MouseArea по сторонам
        MouseArea {
            anchors.fill: parent
            z: -1  // Под попапом
            
            onClicked: function(mouse) {
                // Преобразуем координаты клика в координаты popupRect
                var clickX = mouse.x
                var clickY = mouse.y
                
                var popupX = popupRect.x
                var popupY = popupRect.y
                var popupW = popupRect.width
                var popupH = popupRect.height
                
                // Если клик вне попапа — закрываем
                if (clickX < popupX || clickX > popupX + popupW ||
                    clickY < popupY || clickY > popupY + popupH) {
                    root.close()
                }
            }
        }
    }
}