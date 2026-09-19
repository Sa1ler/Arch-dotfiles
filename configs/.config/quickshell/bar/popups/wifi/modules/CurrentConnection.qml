import QtQuick

Item {
    id: root

    property var theme: null
    property bool wifiEnabled: true
    property string currentSSID: ""
    property int currentSignal: 0
    property bool isConnecting: false
    
    signal disconnect()
    signal toggleWifi()
    
    readonly property color textColor: root.theme && root.theme.colors ? root.theme.colors.text : "#FFFFFF"
    readonly property color textSecondary: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#888888"
    readonly property color accentColor: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
    
    Column {
        anchors.fill: parent
        spacing: 14
        
        // === Заголовок ===
        Row {
            width: root.width
            height: 28
            spacing: 10
            
            // Иконка в круге
            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.15)
                
                Text {
                    anchors.centerIn: parent
                    text: "\uf1eb"
                    font.family: "Font Awesome 6 Free Solid"
                    font.pixelSize: 14
                    color: root.accentColor
                }
            }
            
            Text {
                text: "Connection"
                font.pixelSize: 16
                font.weight: Font.Bold
                font.family: "JetBrains Mono"
                color: root.textColor
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        
        // === Карточка текущего подключения ===
        Rectangle {
            width: root.width
            height: 150
            radius: 16
            color: Qt.rgba(1, 1, 1, 0.04)
            border.width: 1
            border.color: {
                if (!root.wifiEnabled || root.currentSSID === "") return Qt.rgba(1, 1, 1, 0.08)
                return Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.4)
            }
            
            Behavior on border.color { ColorAnimation { duration: 400; easing.type: Easing.OutQuart } }
            
            // Свечение при подключении
            Rectangle {
                anchors.fill: parent
                radius: 16
                color: "transparent"
                border.width: 2
                border.color: root.accentColor
                opacity: root.currentSSID !== "" && root.wifiEnabled ? 0.3 : 0
                
                Behavior on opacity { NumberAnimation { duration: 400 } }
            }
            
            Column {
                anchors.centerIn: parent
                spacing: 12
                width: parent.width - 32
                
                // Большая иконка статуса
                Item {
                    width: parent.width
                    height: 48
                    
                    // Фоновый круг
                    Rectangle {
                        anchors.centerIn: parent
                        width: 56
                        height: 56
                        radius: 28
                        color: {
                            if (!root.wifiEnabled) return Qt.rgba(1, 1, 1, 0.05)
                            if (root.currentSSID === "") return Qt.rgba(1, 1, 1, 0.05)
                            return Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.12)
                        }
                        
                        Behavior on color { ColorAnimation { duration: 400 } }
                        
                        // Пульсация при активном соединении
                        SequentialAnimation on scale {
                            running: root.currentSSID !== "" && root.wifiEnabled && !root.isConnecting
                            loops: Animation.Infinite
                            
                            NumberAnimation { from: 1.0; to: 1.08; duration: 1500; easing.type: Easing.InOutSine }
                            NumberAnimation { from: 1.08; to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "\uf1eb"
                        font.family: "Font Awesome 6 Free Solid"
                        font.pixelSize: 32
                        color: {
                            if (!root.wifiEnabled) return "#444444"
                            if (root.currentSSID === "") return "#444444"
                            return root.accentColor
                        }
                        
                        Behavior on color { ColorAnimation { duration: 400 } }
                        
                        // Спиннер при подключении
                        RotationAnimator on rotation {
                            running: root.isConnecting
                            from: 0
                            to: 360
                            duration: 1200
                            loops: Animation.Infinite
                            easing.type: Easing.Linear
                        }
                    }
                }
                
                // Название сети
                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: {
                        if (!root.wifiEnabled) return "WiFi Off"
                        if (root.isConnecting) return "Connecting..."
                        if (root.currentSSID === "") return "Not Connected"
                        return root.currentSSID
                    }
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    font.family: "JetBrains Mono"
                    color: {
                        if (!root.wifiEnabled || root.currentSSID === "") return root.textSecondary
                        return root.textColor
                    }
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    
                    Behavior on color { ColorAnimation { duration: 300 } }
                }
                
                // Индикатор сигнала
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 4
                    visible: root.currentSSID !== "" && root.wifiEnabled
                    height: 28
                    
                    Repeater {
                        model: 5
                        
                        Rectangle {
                            width: 6
                            height: 8 + index * 5
                            radius: 3
                            anchors.bottom: parent.bottom
                            color: index < Math.ceil(root.currentSignal / 20) 
                                ? root.accentColor 
                                : Qt.rgba(1, 1, 1, 0.08)
                            
                            Behavior on color { ColorAnimation { duration: 300 } }
                            
                            // Анимация появления полосок
                            scale: index < Math.ceil(root.currentSignal / 20) ? 1 : 0.8
                            Behavior on scale { 
                                NumberAnimation { 
                                    duration: 300
                                    easing.type: Easing.OutBack
                                    easing.overshoot: 1.5
                                } 
                            }
                        }
                    }
                }
                
                // Процент сигнала
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.currentSignal + "%"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    font.family: "JetBrains Mono"
                    color: root.textSecondary
                    visible: root.currentSSID !== "" && root.wifiEnabled
                }
            }
        }
        
        // === Кнопка Disconnect ===
        Rectangle {
            width: root.width
            height: 40
            radius: 12
            color: disconnectMouse.pressed ? Qt.rgba(1, 0.3, 0.3, 0.25) :
                   disconnectMouse.containsMouse ? Qt.rgba(1, 0.3, 0.3, 0.15) : Qt.rgba(1, 0.3, 0.3, 0.08)
            border.width: 1
            border.color: Qt.rgba(1, 0.3, 0.3, 0.3)
            visible: root.currentSSID !== "" && root.wifiEnabled
            
            Behavior on color { ColorAnimation { duration: 200 } }
            
            scale: disconnectMouse.pressed ? 0.98 : 1.0
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuart } }
            
            Row {
                anchors.centerIn: parent
                spacing: 8
                
                Text {
                    text: "\uf057"
                    font.family: "Font Awesome 6 Free Solid"
                    font.pixelSize: 16
                    color: "#FF6B6B"
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    text: "Disconnect"
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    font.family: "JetBrains Mono"
                    color: "#FF6B6B"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            
            MouseArea {
                id: disconnectMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.disconnect()
            }
        }
        
        // Spacer
        Item { width: root.width; height: 1 }
        
        // === Переключатель WiFi ===
        Rectangle {
            width: root.width
            height: 40
            radius: 12
            color: toggleMouse.pressed ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.25) :
                   toggleMouse.containsMouse ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.15) : Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.08)
            border.width: 1
            border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.3)
            
            Behavior on color { ColorAnimation { duration: 200 } }
            
            scale: toggleMouse.pressed ? 0.98 : 1.0
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuart } }
            
            Row {
                anchors.centerIn: parent
                spacing: 8
                
                Text {
                    text: root.wifiEnabled ? "\uf205" : "\uf204"
                    font.family: "Font Awesome 6 Free Solid"
                    font.pixelSize: 18
                    color: root.wifiEnabled ? root.accentColor : root.textSecondary
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Behavior on color { ColorAnimation { duration: 300 } }
                }
                
                Text {
                    text: root.wifiEnabled ? "Turn Off" : "Turn On"
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    font.family: "JetBrains Mono"
                    color: root.wifiEnabled ? root.textColor : root.textSecondary
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Behavior on color { ColorAnimation { duration: 300 } }
                }
            }
            
            MouseArea {
                id: toggleMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggleWifi()
            }
        }
    }
}