import QtQuick

Item {
    id: root
    
    property var theme: null
    property var stopwatch: null
    property date currentTime: new Date()
    property string pendingSeconds: ""
    
    property var dayNames: ["Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"]
    property var monthNames: ["Января", "Февраля", "Марта", "Апреля", "Мая", "Июня", "Июля", "Августа", "Сентября", "Октября", "Ноября", "Декабря"]
    
    property string dayOfWeek: dayNames[currentTime.getDay()]
    property string dateText: currentTime.getDate() + " " + monthNames[currentTime.getMonth()] + " " + currentTime.getFullYear()
    property real dayProgress: (currentTime.getHours() * 60 + currentTime.getMinutes()) / 1440
    
    implicitWidth: contentColumn.implicitWidth
    implicitHeight: contentColumn.implicitHeight
    
    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            root.currentTime = new Date()
        }
    }
    
    onCurrentTimeChanged: {
        var newSeconds = Qt.formatTime(currentTime, "ss")
        if (secondsText.text !== newSeconds) {
            pendingSeconds = newSeconds
            slideAnimation.start()
        }
    }
    
    Column {
        id: contentColumn
        spacing: 12
        anchors.centerIn: parent
        
        // Иконка времени суток + День недели
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    var hour = root.currentTime.getHours()
                    if (hour >= 6 && hour < 18) return "\uf185"
                    return "\uf186"
                }
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
                color: {
                    var hour = root.currentTime.getHours()
                    if (hour >= 6 && hour < 18) return "#FFD93D"
                    return "#B8C4FF"
                }
            }
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.dayOfWeek
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 18
                font.weight: Font.DemiBold
                color: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#AAA"
            }
        }
        
        // Большие часы
        Row {
            id: clockRow
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4
            
            Text {
                text: Qt.formatTime(root.currentTime, "HH")
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 52
                font.weight: Font.Black
                color: root.theme && root.theme.colors ? root.theme.colors.text : "#FFF"
            }
            
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                
                Repeater {
                    model: 2
                    delegate: Rectangle {
                        width: 6
                        height: 6
                        radius: 3
                        color: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
                        opacity: root.currentTime.getSeconds() % 2 === 0 ? 1 : 0.3
                        
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                    }
                }
            }
            
            Text {
                text: Qt.formatTime(root.currentTime, "mm")
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 52
                font.weight: Font.Black
                color: root.theme && root.theme.colors ? root.theme.colors.text : "#FFF"
            }
            
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                
                Repeater {
                    model: 2
                    delegate: Rectangle {
                        width: 6
                        height: 6
                        radius: 3
                        color: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
                        opacity: root.currentTime.getSeconds() % 2 === 0 ? 1 : 0.3
                        
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                    }
                }
            }
            
            Item {
                width: secondsText.implicitWidth
                height: secondsText.implicitHeight
                clip: true
                
                Text {
                    id: secondsText
                    text: Qt.formatTime(root.currentTime, "ss")
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 52
                    font.weight: Font.Black
                    color: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
                }
            }
        }
        
        // Дата
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.dateText
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            font.weight: Font.DemiBold
            color: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#AAA"
        }
        
        // Прогресс-бар дня
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4
            
            Rectangle {
                width: 280
                height: 5
                radius: 2.5
                color: root.theme && root.theme.colors ? root.theme.colors.surface : "#1A1F26"
                clip: true
                
                Rectangle {
                    width: parent.width * root.dayProgress
                    height: parent.height
                    radius: 2.5
                    
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF" }
                        GradientStop { position: 1.0; color: Qt.lighter(root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF", 1.3) }
                    }
                    
                    Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
                }
            }
            
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 4
                
                Text {
                    text: Math.round(root.dayProgress * 100) + "%"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
                }
                
                Text {
                    text: "дня прошло"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                    color: root.theme && root.theme.colors ? root.theme.colors.textDisabled : "#666"
                }
            }
        }
    }
    
    // Анимация перелистывания секунд
    SequentialAnimation {
        id: slideAnimation
        
        ParallelAnimation {
            NumberAnimation { 
                target: secondsText 
                property: "y" 
                to: -secondsText.height 
                duration: 150 
                easing.type: Easing.InCubic 
            }
            NumberAnimation { 
                target: secondsText 
                property: "opacity" 
                to: 0 
                duration: 150 
            }
        }
        
        ScriptAction { 
            script: {
                secondsText.text = root.pendingSeconds
                secondsText.y = secondsText.height
            }
        }
        
        ParallelAnimation {
            NumberAnimation { 
                target: secondsText 
                property: "y" 
                to: 0 
                duration: 150 
                easing.type: Easing.OutCubic 
            }
            NumberAnimation { 
                target: secondsText 
                property: "opacity" 
                to: 1 
                duration: 150 
            }
        }
    }
}