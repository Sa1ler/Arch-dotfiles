import QtQuick

Item {
    id: root
    
    property var theme: null
    property var stopwatch: null
    property date currentTime: new Date()
    property string pendingSeconds: ""
    
    // === Кэширование цветов темы ===
    readonly property color textColor: root.theme && root.theme.colors ? root.theme.colors.text : "#FFFFFF"
    readonly property color textSecondaryColor: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#AAAAAA"
    readonly property color textDisabledColor: root.theme && root.theme.colors ? root.theme.colors.textDisabled : "#666666"
    readonly property color accentColor: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
    readonly property color surfaceColor: root.theme && root.theme.colors ? root.theme.colors.surface : "#1A1F26"
    
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
        onTriggered: root.currentTime = new Date()
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
                font.family: "Font Awesome 6 Free Solid"
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
                font.family: "JetBrains Mono"
                font.pixelSize: 18
                font.weight: Font.DemiBold
                font.letterSpacing: 0.3
                color: root.textSecondaryColor
            }
        }
        
        // Большие часы
        Row {
            id: clockRow
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4
            
            Text {
                text: Qt.formatTime(root.currentTime, "HH")
                font.family: "JetBrains Mono"
                font.pixelSize: 52
                font.weight: Font.Black
                color: root.textColor
            }
            
            // === КОМПОНЕНТ: Разделитель-точки ===
            component DotSeparator: Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                
                Repeater {
                    model: 2
                    delegate: Rectangle {
                        width: 6
                        height: 6
                        radius: 3
                        color: root.accentColor
                        opacity: root.currentTime.getSeconds() % 2 === 0 ? 1 : 0.3
                        
                        Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutQuart } }
                    }
                }
            }
            
            DotSeparator {}
            
            Text {
                text: Qt.formatTime(root.currentTime, "mm")
                font.family: "JetBrains Mono"
                font.pixelSize: 52
                font.weight: Font.Black
                color: root.textColor
            }
            
            DotSeparator {}
            
            Item {
                width: secondsText.implicitWidth
                height: secondsText.implicitHeight
                clip: true
                
                Text {
                    id: secondsText
                    text: Qt.formatTime(root.currentTime, "ss")
                    font.family: "JetBrains Mono"
                    font.pixelSize: 52
                    font.weight: Font.Black
                    color: root.accentColor
                }
            }
        }
        
        // Дата
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.dateText
            font.family: "JetBrains Mono"
            font.pixelSize: 16
            font.weight: Font.DemiBold
            font.letterSpacing: 0.3
            color: root.textSecondaryColor
        }
        
        // Прогресс-бар дня
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4
            
            Rectangle {
                width: 280
                height: 5
                radius: 2.5
                color: root.surfaceColor
                clip: true
                
                Rectangle {
                    width: parent.width * root.dayProgress
                    height: parent.height
                    radius: 2.5
                    
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: root.accentColor }
                        GradientStop { position: 1.0; color: Qt.lighter(root.accentColor, 1.25) }
                    }
                    
                    Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutQuart } }
                }
            }
            
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 4
                
                Text {
                    text: Math.round(root.dayProgress * 100) + "%"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    color: root.accentColor
                }
                
                Text {
                    text: "дня прошло"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 10
                    color: root.textDisabledColor
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
                duration: 140 
                easing.type: Easing.InQuart 
            }
            NumberAnimation { 
                target: secondsText 
                property: "opacity" 
                to: 0 
                duration: 140 
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
                duration: 140 
                easing.type: Easing.OutQuart 
            }
            NumberAnimation { 
                target: secondsText 
                property: "opacity" 
                to: 1 
                duration: 140 
            }
        }
    }
}