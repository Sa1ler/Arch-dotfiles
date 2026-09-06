import QtQuick

Item {
    id: root
    
    property var theme: null
    property var soundManager: null
    property var stopwatch: null
    
    property bool isTimerMode: true
    
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
            
            // Содержимое секундомера
            Item {
                width: parent.width
                height: parent.height - 42
                
                Column {
                    anchors.centerIn: parent
                    spacing: 16
                    
                    // Время секундомера
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
                    
                    // Кнопки управления
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8
                        
                        // Кнопка Пуск/Стоп
                        Rectangle {
                            id: startStopBtn
                            width: 100
                            height: 36
                            radius: 10
                            color: root.stopwatch && root.stopwatch.running ? 
                                   "#FF5555" : 
                                   (root.theme.colors.accent || "#5B9BFF")
                            
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                            
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
                                        if (root.soundManager) root.soundManager.play("sfx.wav")
                                    } else {
                                        root.stopwatch.start()
                                        if (root.soundManager) root.soundManager.play("quick_click.wav")
                                    }
                                }
                            }
                        }
                        
                        // Кнопка Сброс (вылезает при запущенном секундомере)
                        Rectangle {
                            id: resetBtn
                            width: root.stopwatch && root.stopwatch.running ? 70 : 0
                            height: 36
                            radius: 10
                            color: startStopMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.08)
                            opacity: root.stopwatch && root.stopwatch.running ? 1 : 0
                            
                            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            Behavior on color { ColorAnimation { duration: 150 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Сброс"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: root.theme.colors.text || "#FFF"
                            }
                            
                            MouseArea {
                                id: startStopMouse
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