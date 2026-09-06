import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null
    
    property int batteryLevel: 100
    property bool charging: false
    
    // Низкий заряд: < 15% и не на зарядке
    property bool isLowBattery: batteryLevel < 15 && !charging
    
    implicitWidth: batteryCard.width
    implicitHeight: batteryCard.height

    // Иконка зарядки (молния)
    property string chargingIcon: ""
    
    // Иконка батареи в зависимости от уровня
    property string batteryIcon: {
        if (batteryLevel <= 10) return "󰁺"
        if (batteryLevel <= 30) return "󰁼"
        if (batteryLevel <= 60) return "󰁾"
        if (batteryLevel <= 90) return "󰂀"
        return "󰂀"
    }
    
    // Текущая иконка
    property string currentIcon: charging ? chargingIcon : batteryIcon

    // Получение данных о батарее
    Process {
        id: getBattery
        command: ["sh", "-c", "echo \"$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1) $(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1)\""]
        
        stdout: StdioCollector {
            onStreamFinished: {
                var output = text.trim()
                var parts = output.split(" ")
                
                if (parts.length >= 1 && parts[0].length > 0) {
                    var level = parseInt(parts[0])
                    if (!isNaN(level)) {
                        root.batteryLevel = level
                    }
                }
                
                if (parts.length >= 2) {
                    var status = parts[1].toLowerCase()
                    root.charging = (status === "charging")
                }
            }
        }
    }

    // Обновление каждые 5 секунд
    Timer {
        id: batteryTimer
        interval: 5000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if (!getBattery.running) {
                getBattery.running = true
            }
        }
    }

    // Анимация мигания красным при низком заряде
    SequentialAnimation {
        id: blinkAnimation
        loops: Animation.Infinite
        
        ColorAnimation { 
            target: batteryCard 
            property: "color" 
            to: "#FF3B3B" 
            duration: 500 
            easing.type: Easing.InOutQuad
        }
        ColorAnimation { 
            target: batteryCard 
            property: "color" 
            to: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
            duration: 500 
            easing.type: Easing.InOutQuad
        }
    }

    // Запуск/остановка мигания
    onIsLowBatteryChanged: {
        if (isLowBattery) {
            blinkAnimation.start()
        } else {
            blinkAnimation.stop()
            batteryCard.color = root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
        }
    }

    // Плашка
    Rectangle {
        id: batteryCard
        anchors.centerIn: parent
        
        width: contentRow.implicitWidth + 10
        height: 25
        radius: 8
        
        color: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
        
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.2)

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 6
            
            // Иконка батареи/зарядки
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.currentIcon
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 22
                font.weight: Font.Black
                color: root.theme && root.theme.colors && root.theme.colors.textSelected ? 
                       root.theme.colors.textSelected : "#FFF"
            }
            
            // Проценты
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.batteryLevel + "%"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                font.weight: Font.ExtraBold
                color: root.theme && root.theme.colors && root.theme.colors.textSelected ? 
                       root.theme.colors.textSelected : "#FFF"
            }
        }
    }
}