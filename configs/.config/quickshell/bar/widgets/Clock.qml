import QtQuick

Item {
    id: root

    property var theme: null
    property var soundManager: null
    
    readonly property var monthNames: [
        "января", "февраля", "марта", "апреля", "мая", "июня",
        "июля", "августа", "сентября", "октября", "ноября", "декабря"
    ]
    
    implicitWidth: contentRow.implicitWidth
    implicitHeight: contentRow.implicitHeight

    Row {
        id: contentRow
        spacing: 10
        anchors.verticalCenter: parent.verticalCenter
        
        // Часы (крупнее и жирнее)
        Text {
            id: timeText
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatTime(new Date(), "HH:mm")
            color: root.theme && root.theme.colors ? root.theme.colors.text : "#FFFFFF"
            font.pixelSize: 17
            font.weight: Font.Black
            font.family: "JetBrainsMono Nerd Font Mono"
        }
        
        // Точка-разделитель (чуть больше)
        Rectangle {
            width: 5
            height: 5
            anchors.verticalCenter: parent.verticalCenter
            radius: 2.5
            color: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#888"
            opacity: 0.7
        }
        
        // Дата (крупнее и жирнее)
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