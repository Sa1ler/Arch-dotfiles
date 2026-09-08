import QtQuick

Item {
    id: root

    property var theme: null
    property var soundManager: null
    property var stopwatch: null
    property var countdownTimer: null
    
    readonly property color textColor: root.theme && root.theme.colors ? root.theme.colors.text : "#FFFFFF"
    readonly property color accentColor: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
    readonly property color textSecondaryColor: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#888888"
    readonly property color badgeTextColor: root.theme && root.theme.colors && root.theme.colors.textSelected ? root.theme.colors.textSelected : "#FFFFFF"
    
    readonly property var monthNames: [
        "января", "февраля", "марта", "апреля", "мая", "июня",
        "июля", "августа", "сентября", "октября", "ноября", "декабря"
    ]
    
    property bool stopwatchRunning: root.stopwatch && root.stopwatch.running
    property bool timerRunning: root.countdownTimer && root.countdownTimer.running
    property bool anyTimerActive: stopwatchRunning || timerRunning
    
    property bool stopwatchVisible: stopwatchRunning
    property bool timerVisible: timerRunning
    
    property string currentTime: ""
    property string currentDate: ""
    
    // === ВОЗВРАЩАЕМ расчет смещения для правильного позиционирования точки ===
    property real centerOffset: (timeText.implicitWidth - dateText.implicitWidth) / 2
    
    Component.onCompleted: updateTime()
    
    function updateTime() {
        var now = new Date()
        currentTime = Qt.formatTime(now, "HH:mm")
        currentDate = now.getDate() + " " + monthNames[now.getMonth()]
    }
    
    height: 20

    // Время (слева)
    Text {
        id: timeText
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.currentTime
        color: root.textColor
        font.pixelSize: 17
        font.weight: Font.Black
        font.family: "JetBrains Mono"
    }
    
    // Точка-разделитель (теперь с правильным offset)
    Rectangle {
        id: dot
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: root.centerOffset
        anchors.verticalCenter: parent.verticalCenter
        width: root.anyTimerActive ? 0 : 5
        height: 5
        radius: 2.5
        color: root.textSecondaryColor
        opacity: root.anyTimerActive ? 0 : 0.7
        
        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutQuart } }
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuart } }
    }
    
    // Бейдж секундомера
    Rectangle {
        id: stopwatchBadge
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: root.centerOffset
        anchors.verticalCenter: parent.verticalCenter
        width: root.stopwatchVisible && !root.timerVisible ? stopwatchContent.implicitWidth + 12 : 0
        height: 20
        radius: 10
        color: root.accentColor
        clip: true
        opacity: root.stopwatchVisible && !root.timerVisible ? 1 : 0
        scale: root.stopwatchVisible && !root.timerVisible ? 1 : 0.9
        
        Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutQuart } }
        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
        
        Row {
            id: stopwatchContent
            anchors.centerIn: parent
            spacing: 4
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "\uf253"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                color: root.badgeTextColor
            }
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.stopwatch ? root.stopwatch.formatTime() : "00:00"
                font.family: "JetBrains Mono"
                font.pixelSize: 11
                font.weight: Font.Black
                color: root.badgeTextColor
            }
        }
    }
    
    // Бейдж таймера
    Rectangle {
        id: timerBadge
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: root.centerOffset
        anchors.verticalCenter: parent.verticalCenter
        width: root.timerVisible ? timerContent.implicitWidth + 12 : 0
        height: 20
        radius: 10
        color: root.accentColor
        clip: true
        opacity: root.timerVisible ? 1 : 0
        scale: root.timerVisible ? 1 : 0.9
        
        Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutQuart } }
        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
        
        Row {
            id: timerContent
            anchors.centerIn: parent
            spacing: 4
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "\uf017"
                font.family: "Font Awesome 6 Free Solid"
                font.pixelSize: 12
                color: root.badgeTextColor
            }
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.countdownTimer ? root.countdownTimer.formatTime() : "00:00"
                font.family: "Font Awesome 6 Free Solid"
                font.pixelSize: 11
                font.weight: Font.Black
                color: root.badgeTextColor
            }
        }
    }
    
    // Дата (справа)
    Text {
        id: dateText
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: root.currentDate
        color: root.accentColor
        font.pixelSize: 15
        font.weight: Font.Black
        font.family: "Font Awesome 6 Free Solid"
    }
    
    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.updateTime()
    }
}