import QtQuick

Item {
    id: root
    
    property var theme: null
    property var soundManager: null
    property var stopwatch: null
    property var countdownTimer: null
    
    property bool isTimerMode: false
    
    implicitWidth: frameCard.width
    implicitHeight: frameCard.height
    
    Rectangle {
        id: frameCard
        width: 280
        height: 320
        radius: 14
        color: root.theme && root.theme.colors ? root.theme.colors.surface : "#1A1F26"
        border.width: 1
        border.color: root.theme && root.theme.colors ? root.theme.colors.border : "#2A2A2A"
        
        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8
            
            // Содержимое (секундомер ИЛИ таймер)
            Item {
                width: parent.width
                height: parent.height - 42
                
                // ===== СЕКУНДОМЕР =====
                Column {
                    anchors.centerIn: parent
                    spacing: 16
                    visible: !root.isTimerMode
                    opacity: !root.isTimerMode ? 1 : 0
                    
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 4
                        
                        Text {
                            text: root.stopwatch ? (root.stopwatch.getHours() < 10 ? "0" : "") + root.stopwatch.getHours() : "00"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 36
                            font.weight: Font.Black
                            color: root.theme.colors.text || "#FFF"
                        }
                        
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: ":"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 36
                            font.weight: Font.Black
                            color: root.theme.colors.textSecondary || "#AAA"
                            opacity: 0.5
                        }
                        
                        Text {
                            text: root.stopwatch ? (root.stopwatch.getMinutes() < 10 ? "0" : "") + root.stopwatch.getMinutes() : "00"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 36
                            font.weight: Font.Black
                            color: root.theme.colors.text || "#FFF"
                        }
                        
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: ":"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 36
                            font.weight: Font.Black
                            color: root.theme.colors.textSecondary || "#AAA"
                            opacity: 0.5
                        }
                        
                        Text {
                            text: root.stopwatch ? (root.stopwatch.getSeconds() < 10 ? "0" : "") + root.stopwatch.getSeconds() : "00"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 36
                            font.weight: Font.Black
                            color: root.theme.colors.accent || "#5B9BFF"
                        }
                    }
                    
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8
                        
                        Rectangle {
                            id: startStopBtn
                            width: 100
                            height: 36
                            radius: 10
                            color: root.stopwatch && root.stopwatch.running ? 
                                   "#FF5555" : 
                                   (root.theme.colors.accent || "#5B9BFF")
                            
                            Behavior on color { ColorAnimation { duration: 200 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: root.stopwatch && root.stopwatch.running ? "Стоп" : "Пуск"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: root.theme.colors.textSelected || "#FFF"
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onClicked: {
                                    if (!root.stopwatch) return
                                    if (root.stopwatch.running) {
                                        root.stopwatch.stop()
                                        if (root.soundManager) root.soundManager.play("sfx2.wav")
                                    } else {
                                        root.stopwatch.start()
                                        if (root.soundManager) root.soundManager.play("quick_click.wav")
                                    }
                                }
                            }
                        }
                        
                        Rectangle {
                            id: resetBtn
                            width: root.stopwatch && root.stopwatch.running ? 70 : 0
                            height: 36
                            radius: 10
                            color: resetMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.08)
                            opacity: root.stopwatch && root.stopwatch.running ? 1 : 0
                            clip: true
                            
                            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Сброс"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: root.theme.colors.text || "#FFF"
                            }
                            
                            MouseArea {
                                id: resetMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onClicked: {
                                    if (!root.stopwatch) return
                                    root.stopwatch.reset()
                                    if (root.soundManager) root.soundManager.play("sfx.wav")
                                }
                            }
                        }
                    }
                }
                
                // ===== ТАЙМЕР =====
                Column {
                    anchors.centerIn: parent
                    spacing: 16
                    visible: root.isTimerMode
                    opacity: root.isTimerMode ? 1 : 0
                    
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    
                    // Установка времени со стрелками
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8
                        
                        // Часы
                        Column {
                            spacing: 4
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "\uf077"
                                font.family: "JetBrainsMono Nerd Font Mono"
                                font.pixelSize: 14
                                color: hoursUpMouse.containsMouse ? (root.theme.colors.accent || "#5B9BFF") : (root.theme.colors.textSecondary || "#AAA")
                                
                                MouseArea {
                                    id: hoursUpMouse
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.countdownTimer) root.countdownTimer.incrementHours()
                                        if (root.soundManager) root.soundManager.play("quick_click.wav")
                                    }
                                }
                            }
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.countdownTimer ? (root.countdownTimer.setHours < 10 ? "0" : "") + root.countdownTimer.setHours : "00"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 32
                                font.weight: Font.Black
                                color: root.theme.colors.text || "#FFF"
                            }
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "\uf078"
                                font.family: "JetBrainsMono Nerd Font Mono"
                                font.pixelSize: 14
                                color: hoursDownMouse.containsMouse ? (root.theme.colors.accent || "#5B9BFF") : (root.theme.colors.textSecondary || "#AAA")
                                
                                MouseArea {
                                    id: hoursDownMouse
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.countdownTimer) root.countdownTimer.decrementHours()
                                        if (root.soundManager) root.soundManager.play("quick_click.wav")
                                    }
                                }
                            }
                        }
                        
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: ":"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 32
                            font.weight: Font.Black
                            color: root.theme.colors.textSecondary || "#AAA"
                            opacity: 0.5
                        }
                        
                        // Минуты
                        Column {
                            spacing: 4
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "\uf077"
                                font.family: "JetBrainsMono Nerd Font Mono"
                                font.pixelSize: 14
                                color: minutesUpMouse.containsMouse ? (root.theme.colors.accent || "#5B9BFF") : (root.theme.colors.textSecondary || "#AAA")
                                
                                MouseArea {
                                    id: minutesUpMouse
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.countdownTimer) root.countdownTimer.incrementMinutes()
                                        if (root.soundManager) root.soundManager.play("quick_click.wav")
                                    }
                                }
                            }
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.countdownTimer ? (root.countdownTimer.setMinutes < 10 ? "0" : "") + root.countdownTimer.setMinutes : "00"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 32
                                font.weight: Font.Black
                                color: root.theme.colors.text || "#FFF"
                            }
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "\uf078"
                                font.family: "JetBrainsMono Nerd Font Mono"
                                font.pixelSize: 14
                                color: minutesDownMouse.containsMouse ? (root.theme.colors.accent || "#5B9BFF") : (root.theme.colors.textSecondary || "#AAA")
                                
                                MouseArea {
                                    id: minutesDownMouse
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.countdownTimer) root.countdownTimer.decrementMinutes()
                                        if (root.soundManager) root.soundManager.play("quick_click.wav")
                                    }
                                }
                            }
                        }
                        
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: ":"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 32
                            font.weight: Font.Black
                            color: root.theme.colors.textSecondary || "#AAA"
                            opacity: 0.5
                        }
                        
                        // Секунды
                        Column {
                            spacing: 4
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "\uf077"
                                font.family: "JetBrainsMono Nerd Font Mono"
                                font.pixelSize: 14
                                color: secondsUpMouse.containsMouse ? (root.theme.colors.accent || "#5B9BFF") : (root.theme.colors.textSecondary || "#AAA")
                                
                                MouseArea {
                                    id: secondsUpMouse
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.countdownTimer) root.countdownTimer.incrementSeconds()
                                        if (root.soundManager) root.soundManager.play("quick_click.wav")
                                    }
                                }
                            }
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: root.countdownTimer ? (root.countdownTimer.setSeconds < 10 ? "0" : "") + root.countdownTimer.setSeconds : "00"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 32
                                font.weight: Font.Black
                                color: root.theme.colors.accent || "#5B9BFF"
                            }
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "\uf078"
                                font.family: "JetBrainsMono Nerd Font Mono"
                                font.pixelSize: 14
                                color: secondsDownMouse.containsMouse ? (root.theme.colors.accent || "#5B9BFF") : (root.theme.colors.textSecondary || "#AAA")
                                
                                MouseArea {
                                    id: secondsDownMouse
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.countdownTimer) root.countdownTimer.decrementSeconds()
                                        if (root.soundManager) root.soundManager.play("quick_click.wav")
                                    }
                                }
                            }
                        }
                    }
                    
                    // Кнопки управления таймером
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8
                        
                        Rectangle {
                            id: timerStartBtn
                            width: 100
                            height: 36
                            radius: 10
                            color: root.countdownTimer && root.countdownTimer.running ? 
                                   "#FFB84D" : 
                                   (root.theme.colors.accent || "#5B9BFF")
                            
                            Behavior on color { ColorAnimation { duration: 200 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: {
                                    if (!root.countdownTimer) return "Пуск"
                                    if (root.countdownTimer.running) return "Пауза"
                                    if (root.countdownTimer.paused) return "Далее"
                                    return "Пуск"
                                }
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: root.theme.colors.textSelected || "#FFF"
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onClicked: {
                                    if (!root.countdownTimer) return
                                    if (root.countdownTimer.running) {
                                        root.countdownTimer.pause()
                                        if (root.soundManager) root.soundManager.play("sfx.wav")
                                    } else {
                                        root.countdownTimer.start()
                                        if (root.soundManager) root.soundManager.play("quick_click.wav")
                                    }
                                }
                            }
                        }
                        
                        Rectangle {
                            id: timerResetBtn
                            width: root.countdownTimer && (root.countdownTimer.running || root.countdownTimer.paused) ? 70 : 0
                            height: 36
                            radius: 10
                            color: timerResetMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.08)
                            opacity: root.countdownTimer && (root.countdownTimer.running || root.countdownTimer.paused) ? 1 : 0
                            clip: true
                            
                            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Сброс"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: root.theme.colors.text || "#FFF"
                            }
                            
                            MouseArea {
                                id: timerResetMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                
                                onClicked: {
                                    if (!root.countdownTimer) return
                                    root.countdownTimer.reset()
                                    if (root.soundManager) root.soundManager.play("sfx.wav")
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
                color: root.theme && root.theme.colors ? root.theme.colors.background : "#181818"
                
                Rectangle {
                    id: sliderFill
                    width: parent.width / 2 - 3
                    height: parent.height - 4
                    radius: 6
                    y: 2
                    x: root.isTimerMode ? 2 : parent.width / 2 + 1
                    color: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
                    
                    Behavior on x {
                        NumberAnimation { 
                            duration: 200 
                            easing.type: Easing.OutCubic 
                        }
                    }
                }
                
                Row {
                    anchors.fill: parent
                    
                    Item {
                        width: parent.width / 2
                        height: parent.height
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Таймер"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: root.isTimerMode ? 
                                   (root.theme.colors.textSelected || "#FFF") : 
                                   (root.theme.colors.textSecondary || "#AAA")
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: root.isTimerMode ? Qt.ArrowCursor : Qt.PointingHandCursor
                            
                            onClicked: {
                                if (!root.isTimerMode) {
                                    root.isTimerMode = true
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
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: !root.isTimerMode ? 
                                   (root.theme.colors.textSelected || "#FFF") : 
                                   (root.theme.colors.textSecondary || "#AAA")
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: !root.isTimerMode ? Qt.ArrowCursor : Qt.PointingHandCursor
                            
                            onClicked: {
                                if (root.isTimerMode) {
                                    root.isTimerMode = false
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