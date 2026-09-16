import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    property var theme: null
    property var soundManager: null
    
    property bool windowVisible: false
    
    // === Размеры попапа ===
    property int popupWidth: 320
    property int popupHeight: 400
    property int barOffset: 45
    property int rightMargin: 10
    
    // === Кэширование цветов темы ===
    readonly property color bgColor: root.theme && root.theme.colors ? root.theme.colors.background : "#181818"
    readonly property color borderColor: root.theme && root.theme.colors ? root.theme.colors.border : "#2A2A2A"
    readonly property color shadowColor: "#000000"

    color: "transparent"

    anchors {
        top: true
        right: true
    }

    implicitWidth: root.popupWidth + (root.rightMargin * 2)
    implicitHeight: root.barOffset + root.popupHeight + 20

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

    // === Анимация открытия ===
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
                to: root.popupHeight 
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
        
        // Фаза 2: раскрытие в ширину с мягким отскоком + тень
        ParallelAnimation {
            NumberAnimation { 
                target: popupRect 
                property: "width" 
                from: 0
                to: root.popupWidth 
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

    // === Анимация закрытия ===
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
        
        // Фаза 2: сворачивание в ширину + масштабирование
        ParallelAnimation {
            NumberAnimation { 
                target: popupRect 
                property: "width" 
                from: root.popupWidth 
                to: 0
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
            from: root.popupHeight 
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

        // === Тень через Rectangle (без Qt5Compat) ===
        Rectangle {
            id: shadowRect
            anchors.top: popupRect.top
            anchors.right: popupRect.right
            width: popupRect.width
            height: popupRect.height
            radius: 16
            color: root.shadowColor
            opacity: 0
            
            // Используем простой Rectangle с прозрачностью для эффекта тени
            Rectangle {
                anchors.fill: parent
                anchors.margins: -8
                radius: parent.radius + 8
                color: Qt.rgba(0, 0, 0, 0.3)
                visible: parent.opacity > 0
            }
        }

        // === Прямоугольник попапа ===
        Rectangle {
            id: popupRect
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: root.barOffset
            anchors.rightMargin: root.rightMargin
            
            width: 0
            height: 0
            
            radius: 14
            color: root.bgColor
            border.width: 1
            border.color: root.borderColor
            clip: true
            
            transformOrigin: Item.TopRight
            
            // Содержимое попапа
            Item {
                id: contentWrapper
                anchors.fill: parent
                anchors.margins: 16
                
                opacity: 0
                
                // Здесь будет контент попапа
                Text {
                    anchors.centerIn: parent
                    text: "WiFi Settings"
                    color: root.theme && root.theme.colors ? root.theme.colors.text : "#FFFFFF"
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                }
            }
        }

        // === MouseArea для закрытия по клику вне попапа ===
        MouseArea {
            anchors.fill: parent
            z: -1
            
            onClicked: function(mouse) {
                var clickX = mouse.x
                var clickY = mouse.y
                
                var popupX = popupRect.x
                var popupY = popupRect.y
                var popupW = popupRect.width
                var popupH = popupRect.height
                
                if (clickX < popupX || clickX > popupX + popupW ||
                    clickY < popupY || clickY > popupY + popupH) {
                    root.close()
                }
            }
        }
    }
}