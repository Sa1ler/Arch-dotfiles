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
    
    property bool stopwatchRunning: root.stopwatch && root.stopwatch.running
    property bool stopwatchVisible: false
    
    // Смещение центра: разница между шириной времени и даты
    // Это позиционирует точку/секундомер ровно посередине между ними
    property real centerOffset: (timeText.implicitWidth - dateText.implicitWidth) / 2
    
    height: 20
    
    onStopwatchRunningChanged: {
        if (stopwatchRunning) {
            hideTimer.stop()
            showTimer.restart()
        } else {
            showTimer.stop()
            stopwatchVisible = false
        }
    }
    
    Timer {
        id: showTimer
        interval: 450
        onTriggered: stopwatchVisible = true
    }
    
    Timer {
        id: hideTimer
        interval: 300
    }

    // Время (слева)
    Text {
        id: timeText
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatTime(new Date(), "HH:mm")
        color: root.theme && root.theme.colors ? root.theme.colors.text : "#FFFFFF"
        font.pixelSize: 17
        font.weight: Font.Black
        font.family: "JetBrainsMono Nerd Font Mono"
    }
    
    // Точка-разделитель (по центру МЕЖДУ временем и датой)
    Rectangle {
        id: dot
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: root.centerOffset
        anchors.verticalCenter: parent.verticalCenter
        width: stopwatchRunning ? 0 : 5
        height: 5
        radius: 2.5
        color: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#888"
        opacity: stopwatchRunning ? 0 : 0.7
        
        Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.InOutCubic } }
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutCubic } }
    }
    
    // Секундомер (по центру МЕЖДУ временем и датой)
    Rectangle {
        id: stopwatchBadge
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: root.centerOffset
        anchors.verticalCenter: parent.verticalCenter
        width: stopwatchVisible ? stopwatchContent.implicitWidth + 12 : 0
        height: 20
        radius: 10
        color: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
        clip: true
        
        opacity: stopwatchVisible ? 1 : 0
        scale: stopwatchVisible ? 1 : 0.85
        
        Behavior on width { NumberAnimation { duration: 350; easing.type: Easing.InOutCubic } }
        Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.1 } }
        
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
    
    // Дата (справа)
    Text {
        id: dateText
        anchors.right: parent.right
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