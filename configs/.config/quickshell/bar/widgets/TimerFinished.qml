import QtQuick

Item {
    id: root
    
    property var theme: null
    property var countdownTimer: null
    property bool active: false
    
    // === Кэширование цветов темы ===
    readonly property color textColor: root.theme && root.theme.colors ? root.theme.colors.text : "#FFFFFF"
    readonly property color textSecondaryColor: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#AAAAAA"
    readonly property color accentColor: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
    
    signal close()
    
    // Пульсация текста
    SequentialAnimation {
        id: pulseAnimation
        loops: Animation.Infinite
        running: root.active
        
        NumberAnimation { 
            target: finishedText 
            property: "opacity" 
            to: 0.35
            duration: 650 
            easing.type: Easing.InOutSine 
        }
        NumberAnimation { 
            target: finishedText 
            property: "opacity" 
            to: 1 
            duration: 650 
            easing.type: Easing.InOutSine 
        }
    }
    
    Column {
        anchors.centerIn: parent
        spacing: 12
        
        // Иконка колокольчика
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "\uf0f3"
            font.family: "Font Awesome 6 Free Solid"
            font.pixelSize: 28
            color: root.accentColor
            opacity: 0.8
        }
        
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Таймер завершён"
            font.family: "JetBrains Mono"
            font.pixelSize: 13
            font.weight: Font.DemiBold
            font.letterSpacing: 0.3
            color: root.textSecondaryColor
        }
        
        Text {
            id: finishedText
            anchors.horizontalCenter: parent.horizontalCenter
            text: countdownTimer ? countdownTimer.formatFullTime() : "00:00:00"
            font.family: "JetBrains Mono"
            font.pixelSize: 44
            font.weight: Font.Black
            font.letterSpacing: 1
            color: root.accentColor
        }
    }
    
    // Крестик закрытия
    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 12
        width: 28
        height: 28
        radius: 8
        color: closeMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
        scale: closeMouse.containsMouse ? 1.05 : 1.0
        
        Behavior on color { ColorAnimation { duration: 160 } }
        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack; easing.overshoot: 1.3 } }
        
        Text {
            anchors.centerIn: parent
            text: "✕"
            font.family: "JetBrains Mono"
            font.pixelSize: 11
            font.bold: true
            color: root.textColor
        }
        
        MouseArea {
            id: closeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.close()
        }
    }
}