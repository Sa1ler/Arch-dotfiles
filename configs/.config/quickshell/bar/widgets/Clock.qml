import QtQuick

Item {
    id: root

    property var theme: null
    property var soundManager: null
    property var stopwatch: null
    property var countdownTimer: null
    
    readonly property var monthNames: [
        "января", "февраля", "марта", "апреля", "мая", "июня",
        "июля", "августа", "сентября", "октября", "ноября", "декабря"
    ]
    
    property bool stopwatchRunning: root.stopwatch && root.stopwatch.running
    property bool timerRunning: root.countdownTimer && root.countdownTimer.running
    property bool stopwatchVisible: false
    property bool timerVisible: false
    
    property real centerOffset: (timeText.implicitWidth - dateText.implicitWidth) / 2
    
    height: 20
    
    onStopwatchRunningChanged: {
        if (stopwatchRunning) {
            showTimer.restart()
        } else {
            showTimer.stop()
            stopwatchVisible = false
        }
    }
    
    onTimerRunningChanged: {
        if (timerRunning) {
            showTimer2.restart()
        } else {
            showTimer2.stop()
            timerVisible = false
        }
    }
    
    Timer {
        id: showTimer
        interval: 450
        onTriggered: stopwatchVisible = true
    }
    
    Timer {
        id: showTimer2
        interval: 450
        onTriggered: timerVisible = true
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
    
    // Точка-разделитель (скрыта когда таймер или секундомер запущен)
    Rectangle {
        id: dot
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: root.centerOffset
        anchors.verticalCenter: parent.verticalCenter
        width: (stopwatchRunning || timerRunning) ? 0 : 5
        height: 5
        radius: 2.5
        color: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#888"
        opacity: (stopwatchRunning || timerRunning) ? 0 : 0.7
        
        Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.InOutCubic } }
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutCubic } }
    }
    
    // Бейдж секундомера
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
        
        opacity: stopwatchVisible && !timerVisible ? 1 : 0
        scale: stopwatchVisible && !timerVisible ? 1 : 0.85
        
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
                color: root.theme.colors.textSelected || "#FFF"
            }
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.stopwatch ? root.stopwatch.formatTime() : "00:00"
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 11
                font.weight: Font.Black
                color: root.theme.colors.textSelected || "#FFF"
            }
        }
    }
    
    // Бейдж таймера (приоритетнее секундомера)
    Rectangle {
        id: timerBadge
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: root.centerOffset
        anchors.verticalCenter: parent.verticalCenter
        width: timerVisible ? timerContent.implicitWidth + 12 : 0
        height: 20
        radius: 10
        color: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
        clip: true
        
        opacity: timerVisible ? 1 : 0
        scale: timerVisible ? 1 : 0.85
        
        Behavior on width { NumberAnimation { duration: 350; easing.type: Easing.InOutCubic } }
        Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.1 } }
        
        Row {
            id: timerContent
            anchors.centerIn: parent
            spacing: 4
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "\uf017"
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 12
                color: root.theme.colors.textSelected || "#FFF"
            }
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.countdownTimer ? root.countdownTimer.formatTime() : "00:00"
                font.family: "JetBrainsMono Nerd Font Mono"
                font.pixelSize: 11
                font.weight: Font.Black
                color: root.theme.colors.textSelected || "#FFF"
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