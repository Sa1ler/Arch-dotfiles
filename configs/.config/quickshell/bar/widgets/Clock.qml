import QtQuick

Item {
    id: root

    property var theme: null
    property var soundManager: null
    property var stopwatch: null
    
    readonly property var monthNames: [
        "января", "февраля", "марта", "апреля", "мая", "июня",
        "июля", "августа", "сентября", "октября", "ноября", "декабря"
    ]
    
    implicitWidth: contentRow.implicitWidth
    implicitHeight: contentRow.implicitHeight

    Row {
        id: contentRow
        spacing: 10
        anchors.centerIn: parent
        
        // Часы
        Text {
            id: timeText
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatTime(new Date(), "HH:mm")
            color: root.theme && root.theme.colors ? root.theme.colors.text : "#FFFFFF"
            font.pixelSize: 17
            font.weight: Font.Black
            font.family: "JetBrainsMono Nerd Font Mono"
        }
        
        // Точка-разделитель
        Rectangle {
            width: root.stopwatch && root.stopwatch.running ? 0 : 5
            height: 5
            anchors.verticalCenter: parent.verticalCenter
            radius: 2.5
            color: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#888"
            opacity: root.stopwatch && root.stopwatch.running ? 0 : 0.7
            
            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }
        
        // Секундомер (расширяется синхронно с сектором)
        Rectangle {
            id: stopwatchBadge
            anchors.verticalCenter: parent.verticalCenter
            width: root.stopwatch && root.stopwatch.running ? stopwatchContent.implicitWidth + 12 : 0
            height: 20
            radius: 10
            color: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
            clip: true
            
            opacity: root.stopwatch && root.stopwatch.running ? 1 : 0
            
            // Расширяется синхронно с сектором (450мс)
            Behavior on width { 
                NumberAnimation { duration: 450; easing.type: Easing.OutCubic } 
            }
            // Содержимое появляется ПОСЛЕ расширения сектора
            Behavior on opacity { 
                SequentialAnimation {
                    PauseAnimation { duration: root.stopwatch && root.stopwatch.running ? 450 : 0 }
                    NumberAnimation { duration: 200 }
                }
            }
            
            Row {
                id: stopwatchContent
                anchors.centerIn: parent
                spacing: 4
                
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\uf253"
                    font.family: "JetBrainsMono Nerd Font Mono"
                    font.pixelSize: 12
                    color: root.theme && root.theme.colors && root.theme.colors.textSelected ? 
                           root.theme.colors.textSelected : "#FFF"
                }
                
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.stopwatch ? root.stopwatch.formatTime() : "00:00"
                    font.family: "JetBrainsMono Nerd Font Mono"
                    font.pixelSize: 11
                    font.weight: Font.Black
                    color: root.theme && root.theme.colors && root.theme.colors.textSelected ? 
                           root.theme.colors.textSelected : "#FFF"
                }
            }
        }
        
        // Дата
        Text {
            id: dateText
            anchors.verticalCenter: parent.verticalCenter
            text: {
                var now = new Date()
                return now.getDate() + " " + root.monthNames[now.getMonth()]
            }
            color: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
            font.pixelSize: 15
            font.weight: Font.Black
            font.family: "JetBrainsMono Nerd Font Mono"
        }
    }
    
    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            var now = new Date()
            timeText.text = Qt.formatTime(now, "HH:mm")
            dateText.text = now.getDate() + " " + root.monthNames[now.getMonth()]
        }
    }
}