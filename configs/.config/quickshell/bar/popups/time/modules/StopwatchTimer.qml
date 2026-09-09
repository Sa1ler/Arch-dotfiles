import QtQuick

Item {
    id: root
    
    property var theme: null
    property var soundManager: null
    property var stopwatch: null
    property var countdownTimer: null
    
    property bool isTimerMode: false
    
    readonly property color surfaceColor: root.theme && root.theme.colors ? root.theme.colors.surface : "#1A1F26"
    readonly property color bgColor: root.theme && root.theme.colors ? root.theme.colors.background : "#181818"
    readonly property color textColor: root.theme && root.theme.colors ? root.theme.colors.text : "#FFFFFF"
    readonly property color textSelectedColor: root.theme && root.theme.colors ? root.theme.colors.textSelected : "#FFFFFF"
    readonly property color textSecondaryColor: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#AAAAAA"
    readonly property color accentColor: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
    readonly property color borderColor: root.theme && root.theme.colors ? root.theme.colors.border : "#2A2A2A"
    
    implicitWidth: frameCard.width
    implicitHeight: frameCard.height
    
    Rectangle {
        id: frameCard
        width: 280
        height: 320
        radius: 14
        color: root.surfaceColor
        border.width: 1
        border.color: root.borderColor
        
        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8
            
            Item {
                width: parent.width
                height: parent.height - 42
                
                // ===== СЕКУНДОМЕР =====
                Column {
                    anchors.centerIn: parent
                    spacing: 16
                    opacity: !root.isTimerMode ? 1 : 0
                    visible: opacity > 0
                    
                    Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutQuart } }
                    
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 4
                        
                        Text {
                            text: root.stopwatch ? (root.stopwatch.getHours() < 10 ? "0" : "") + root.stopwatch.getHours() : "00"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 36
                            font.weight: Font.Black
                            color: root.textColor
                        }
                        
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: ":"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 36
                            font.weight: Font.Black
                            color: root.textSecondaryColor
                            opacity: 0.5
                        }
                        
                        Text {
                            text: root.stopwatch ? (root.stopwatch.getMinutes() < 10 ? "0" : "") + root.stopwatch.getMinutes() : "00"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 36
                            font.weight: Font.Black
                            color: root.textColor
                        }
                        
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: ":"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 36
                            font.weight: Font.Black
                            color: root.textSecondaryColor
                            opacity: 0.5
                        }
                        
                        Text {
                            text: root.stopwatch ? (root.stopwatch.getSeconds() < 10 ? "0" : "") + root.stopwatch.getSeconds() : "00"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 36
                            font.weight: Font.Black
                            color: root.accentColor
                        }
                    }
                    
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8
                        
                        // Кнопка Пуск/Стоп секундомера
                        Rectangle {
                            id: startStopBtn
                            width: 100
                            height: 36
                            radius: 10
                            color: root.stopwatch && root.stopwatch.running ? "#FF5555" : root.accentColor
                            scale: startStopMouse.containsMouse ? 1.03 : 1.0
                            
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuart } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: root.stopwatch && root.stopwatch.running ? "Стоп" : "Пуск"
                                font.family: "JetBrains Mono"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: root.textSelectedColor
                            }
                            
                            MouseArea {
                                id: startStopMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onClicked: {
                                    if (!root.stopwatch) return
                                    if (root.stopwatch.running) {
                                        root.stopwatch.stop()
                                        // 🔊 sfx2.wav — остановка секундомера (стоп)
                                        if (root.soundManager) root.soundManager.play("click2.wav")
                                    } else {
                                        root.stopwatch.start()
                                        // 🔊 quick_click.wav — запуск секундомера
                                        if (root.soundManager) root.soundManager.play("quick_click.wav")
                                    }
                                }
                            }
                        }
                        
                        // Кнопка Сброс секундомера
                        Rectangle {
                            id: resetBtn
                            width: root.stopwatch && root.stopwatch.running ? 70 : 0
                            height: 36
                            radius: 10
                            color: resetMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.08)
                            opacity: root.stopwatch && root.stopwatch.running ? 1 : 0
                            clip: true
                            
                            // === ИСПРАВЛЕНО: Убран OutBack с overshoot, теперь OutQuart ===
                            // Это убирает "подрагивание" и тряску при появлении/исчезновении
                            Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutQuart } }
                            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuart } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Сброс"
                                font.family: "JetBrains Mono"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: root.textColor
                            }
                            
                            MouseArea {
                                id: resetMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onClicked: {
                                    if (!root.stopwatch) return
                                    root.stopwatch.reset()
                                    // 🔊 sfx.wav — сброс секундомера
                                    if (root.soundManager) root.soundManager.play("click2.wav")
                                }
                            }
                        }
                    }
                }
                
                // ===== ТАЙМЕР =====
                Column {
                    anchors.centerIn: parent
                    spacing: 16
                    opacity: root.isTimerMode ? 1 : 0
                    visible: opacity > 0
                    
                    Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutQuart } }
                    
                    component TimeSetter: Column {
                        property int value: 0
                        property bool isAccent: false
                        property var onIncrement: null
                        property var onDecrement: null
                        
                        spacing: 4
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "\uf077"
                            font.family: "Font Awesome 6 Free Solid"
                            font.pixelSize: 12
                            color: upMouse.containsMouse ? root.accentColor : root.textSecondaryColor
                            
                            Behavior on color { ColorAnimation { duration: 140 } }
                            
                            MouseArea {
                                id: upMouse
                                anchors.fill: parent
                                anchors.margins: -4
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (onIncrement) onIncrement()
                                    // 🔊 quick_click.wav — изменение значения (стрелка вверх)
                                    if (root.soundManager) root.soundManager.play("click.wav")
                                }
                            }
                        }
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: (value < 10 ? "0" : "") + value
                            font.family: "JetBrains Mono"
                            font.pixelSize: 32
                            font.weight: Font.Black
                            color: isAccent ? root.accentColor : root.textColor
                        }
                        
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "\uf078"
                            font.family: "Font Awesome 6 Free Solid"
                            font.pixelSize: 12
                            color: downMouse.containsMouse ? root.accentColor : root.textSecondaryColor
                            
                            Behavior on color { ColorAnimation { duration: 140 } }
                            
                            MouseArea {
                                id: downMouse
                                anchors.fill: parent
                                anchors.margins: -4
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (onDecrement) onDecrement()
                                    // 🔊 quick_click.wav — изменение значения (стрелка вниз)
                                    if (root.soundManager) root.soundManager.play("click.wav")
                                }
                            }
                        }
                    }
                    
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8
                        
                        TimeSetter {
                            value: root.countdownTimer ? root.countdownTimer.setHours : 0
                            onIncrement: function() { if (root.countdownTimer) root.countdownTimer.incrementHours() }
                            onDecrement: function() { if (root.countdownTimer) root.countdownTimer.decrementHours() }
                        }
                        
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: ":"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 32
                            font.weight: Font.Black
                            color: root.textSecondaryColor
                            opacity: 0.5
                        }
                        
                        TimeSetter {
                            value: root.countdownTimer ? root.countdownTimer.setMinutes : 0
                            onIncrement: function() { if (root.countdownTimer) root.countdownTimer.incrementMinutes() }
                            onDecrement: function() { if (root.countdownTimer) root.countdownTimer.decrementMinutes() }
                        }
                        
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: ":"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 32
                            font.weight: Font.Black
                            color: root.textSecondaryColor
                            opacity: 0.5
                        }
                        
                        TimeSetter {
                            value: root.countdownTimer ? root.countdownTimer.setSeconds : 0
                            isAccent: true
                            onIncrement: function() { if (root.countdownTimer) root.countdownTimer.incrementSeconds() }
                            onDecrement: function() { if (root.countdownTimer) root.countdownTimer.decrementSeconds() }
                        }
                    }
                    
                    // Кнопки управления таймером
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8
                        
                        // Кнопка Пуск/Пауза/Далее таймера
                        Rectangle {
                            id: timerStartBtn
                            width: 100
                            height: 36
                            radius: 10
                            color: root.countdownTimer && root.countdownTimer.running ? "#FFB84D" : root.accentColor
                            scale: timerStartMouse.containsMouse ? 1.03 : 1.0
                            
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuart } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: {
                                    if (!root.countdownTimer) return "Пуск"
                                    if (root.countdownTimer.running) return "Пауза"
                                    if (root.countdownTimer.paused) return "Далее"
                                    return "Пуск"
                                }
                                font.family: "JetBrains Mono"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: root.textSelectedColor
                            }
                            
                            MouseArea {
                                id: timerStartMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onClicked: {
                                    if (!root.countdownTimer) return
                                    if (root.countdownTimer.running) {
                                        root.countdownTimer.pause()
                                        // 🔊 sfx.wav — пауза таймера
                                        if (root.soundManager) root.soundManager.play("click.wav")
                                    } else {
                                        root.countdownTimer.start()
                                        // 🔊 quick_click.wav — запуск/возобновление таймера
                                        if (root.soundManager) root.soundManager.play("click2.wav")
                                    }
                                }
                            }
                        }
                        
                        // Кнопка Сброс таймера
                        Rectangle {
                            id: timerResetBtn
                            width: root.countdownTimer && (root.countdownTimer.running || root.countdownTimer.paused) ? 70 : 0
                            height: 36
                            radius: 10
                            color: timerResetMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.08)
                            opacity: root.countdownTimer && (root.countdownTimer.running || root.countdownTimer.paused) ? 1 : 0
                            clip: true
                            
                            // === ИСПРАВЛЕНО: Убран OutBack с overshoot, теперь OutQuart ===
                            Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutQuart } }
                            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuart } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Сброс"
                                font.family: "JetBrains Mono"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: root.textColor
                            }
                            
                            MouseArea {
                                id: timerResetMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onClicked: {
                                    if (!root.countdownTimer) return
                                    root.countdownTimer.reset()
                                    // 🔊 sfx.wav — сброс таймера
                                    if (root.soundManager) root.soundManager.play("click.wav")
                                }
                            }
                        }
                    }
                }
            }
            
            // Переключатель Таймер / Секундомер
            Rectangle {
                width: parent.width
                height: 30
                radius: 8
                color: root.bgColor
                
                Rectangle {
                    id: sliderFill
                    width: parent.width / 2 - 3
                    height: parent.height - 4
                    radius: 6
                    y: 2
                    x: root.isTimerMode ? 2 : parent.width / 2 + 1
                    color: root.accentColor
                    
                    Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutQuart } }
                }
                
                Row {
                    anchors.fill: parent
                    
                    Item {
                        width: parent.width / 2
                        height: parent.height
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Таймер"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: root.isTimerMode ? root.textSelectedColor : root.textSecondaryColor
                            Behavior on color { ColorAnimation { duration: 180 } }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: root.isTimerMode ? Qt.ArrowCursor : Qt.PointingHandCursor
                            
                            onClicked: {
                                if (!root.isTimerMode) {
                                    root.isTimerMode = true
                                    // 🔊 quick_click.wav — переключение на режим "Таймер"
                                    if (root.soundManager) root.soundManager.play("quick_click.wav")
                                }
                            }
                        }
                    }
                    
                    Item {
                        width: parent.width / 2
                        height: parent.height
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Секундомер"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: !root.isTimerMode ? root.textSelectedColor : root.textSecondaryColor
                            Behavior on color { ColorAnimation { duration: 180 } }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: !root.isTimerMode ? Qt.ArrowCursor : Qt.PointingHandCursor
                            
                            onClicked: {
                                if (root.isTimerMode) {
                                    root.isTimerMode = false
                                    // 🔊 quick_click.wav — переключение на режим "Секундомер"
                                    if (root.soundManager) root.soundManager.play("quick_click.wav")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}