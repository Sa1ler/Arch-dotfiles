import QtQuick

Item {
    id: root
    
    property var theme: null
    property var countdownTimer: null
    property bool active: false
    
    signal close()
    
    // Пульсация текста
    SequentialAnimation {
        id: pulseAnimation
        loops: Animation.Infinite
        running: root.active
        
        NumberAnimation { 
            target: finishedText 
            property: "opacity" 
            to: 0.3 
            duration: 700 
            easing.type: Easing.InOutSine 
        }
        NumberAnimation { 
            target: finishedText 
            property: "opacity" 
            to: 1 
            duration: 700 
            easing.type: Easing.InOutSine 
        }
    }
    
    Column {
        anchors.centerIn: parent
        spacing: 8
        
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Таймер завершён"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            font.weight: Font.DemiBold
            color: root.theme.colors.textSecondary || "#AAA"
        }
        
        Text {
            id: finishedText
            anchors.horizontalCenter: parent.horizontalCenter
            text: "00:00:00"
            font.family: "JetBrainsMono Nerd Font Mono"
            font.pixelSize: 48
            font.weight: Font.Black
            color: root.theme.colors.accent || "#5B9BFF"
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
        color: closeMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
        
        Behavior on color { ColorAnimation { duration: 150 } }
        
        Text {
            anchors.centerIn: parent
            text: "\uf00d"
            font.family: "JetBrainsMono Nerd Font Mono"
            font.pixelSize: 14
            color: root.theme.colors.text || "#FFF"
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