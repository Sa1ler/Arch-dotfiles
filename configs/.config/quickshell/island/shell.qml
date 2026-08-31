import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: capsule
    width: 140
    height: 48
    radius: 24
    color: "#CC000000"
    border.color: "#33FFFFFF"
    
    // Свойства состояний
    property string currentView: "main" // main | expanded | menu

    anchors.top: parent.top
    anchors.topMargin: 20
    anchors.horizontalCenter: parent.horizontalCenter

    // ---- Базовое состояние (Свернуто) ----
    Row {
        id: collapsedView
        anchors.centerIn: parent
        spacing: 8
        visible: capsule.currentView === "main"
        
        Text { 
            id: timeText
            text: Qt.formatTime(new Date(), "HH:mm")
            color: "white"
            font.bold: true
            font.pixelSize: 16
        }
        
        Rectangle {
            width: 1
            height: 20
            color: "#44FFFFFF"
            visible: playerActive.visible
        }
        
        Text {
            id: playerActive
            text: "▶" // Иконка плеера, если что-то играет
            color: "#88FFFFFF"
            font.pixelSize: 14
            visible: false // Меняй через скрипт
        }
    }

    // ---- Раскрытое состояние (Уровень 1) ----
    Row {
        id: expandedView
        anchors.fill: parent
        anchors.margins: 8
        spacing: 12
        visible: capsule.currentView === "expanded"
        
        // Время и дата
        Column {
            spacing: 2
            Text { 
                text: Qt.formatTime(new Date(), "HH:mm")
                color: "white"
                font.bold: true
                font.pixelSize: 14
            }
            Text {
                text: Qt.formatDate(new Date(), "dd MMM")
                color: "#AAFFFFFF"
                font.pixelSize: 10
            }
        }
        
        Rectangle { width: 1; height: 30; color: "#44FFFFFF" }
        
        // Контролы плеера
        Row {
            spacing: 8
            anchors.verticalCenter: parent.verticalCenter
            
            Text { text: "⏮"; color: "white"; font.pixelSize: 14 }
            Text { text: "▶"; color: "white"; font.pixelSize: 16 }
            Text { text: "⏭"; color: "white"; font.pixelSize: 14 }
        }
        
        Rectangle { width: 1; height: 30; color: "#44FFFFFF" }
        
        // Кнопка "Показать всё"
        Text {
            text: "⚡"
            color: "#88FFFFFF"
            font.pixelSize: 16
            anchors.verticalCenter: parent.verticalCenter
            
            MouseArea {
                anchors.fill: parent
                onClicked: capsule.currentView = "menu"
            }
        }
    }

    // ---- Меню (Уровень 2) - дропдаун вниз ----
    Rectangle {
        id: menuView
        anchors.top: capsule.bottom
        anchors.topMargin: 8
        anchors.left: capsule.left
        anchors.leftMargin: -20
        width: 440
        height: 280
        radius: 16
        color: "#EE1A1A1A"
        border.color: "#33FFFFFF"
        visible: capsule.currentView === "menu"
        
        // Вкладки
        Row {
            id: tabs
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            spacing: 6
            
            property string currentTab: "time"
            
            Repeater {
                model: ["🕐 Время", "🎵 Плеер", "🎨 Темы", "⚙️ Система"]
                
                Rectangle {
                    width: 90
                    height: 32
                    radius: 16
                    color: (index === tabs.currentTab) ? "#44FFFFFF" : "transparent"
                    
                    Text {
                        text: modelData
                        anchors.centerIn: parent
                        color: (index === tabs.currentTab) ? "white" : "#88FFFFFF"
                        font.pixelSize: 11
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: tabs.currentTab = index
                    }
                }
            }
        }
        
        // Контент вкладок
        StackLayout {
            anchors.top: tabs.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 12
            currentIndex: tabs.currentTab
            
            // Вкладка 1: Время и дата
            Rectangle { color: "transparent"
                Column {
                    Text { text: Qt.formatTime(new Date(), "HH:mm:ss"); color: "white"; font.pixelSize: 28 }
                    Text { text: Qt.formatDate(new Date(), "dd MMMM yyyy"); color: "#AAFFFFFF"; font.pixelSize: 14 }
                    Text { text: "🌡 22°C  ☀️ Ясно"; color: "#88FFFFFF"; font.pixelSize: 12 }
                }
            }
            
            // Вкладка 2: Плеер
            Rectangle { color: "transparent"
                Column {
                    Text { text: "🎵 Сейчас играет"; color: "white"; font.pixelSize: 14 }
                    Text { text: "Artist - Track Name"; color: "#AAFFFFFF"; font.pixelSize: 12 }
                    Row { spacing: 20
                        Text { text: "⏮"; color: "white"; font.pixelSize: 20 }
                        Text { text: "▶"; color: "white"; font.pixelSize: 26 }
                        Text { text: "⏭"; color: "white"; font.pixelSize: 20 }
                    }
                }
            }
            
            // Вкладка 3: Темы и обои
            Rectangle { color: "transparent"
                Grid {
                    columns: 3
                    spacing: 8
                    Repeater { model: 6
                        Rectangle {
                            width: 60; height: 40; radius: 8
                            color: ["#FF6B6B","#4ECDC4","#45B7D1","#96CEB4","#FFEAA7","#DDA0DD"][index]
                            Text { text: index + 1; anchors.centerIn: parent; color: "white"; font.pixelSize: 10 }
                            MouseArea { anchors.fill: parent; onClicked: print("Apply theme", index) }
                        }
                    }
                }
            }
            
            // Вкладка 4: Системные переключатели
            Rectangle { color: "transparent"
                Grid {
                    columns: 2
                    spacing: 10
                    Repeater { model: ["Wi-Fi", "Bluetooth", "Темная тема", "Не беспокоить"]
                        Rectangle {
                            width: 160; height: 36; radius: 12
                            color: "#22FFFFFF"
                            Row {
                                anchors.centerIn: parent
                                spacing: 8
                                Text { text: "●"; color: "#4ECDC4"; font.pixelSize: 12 }
                                Text { text: modelData; color: "white"; font.pixelSize: 12 }
                            }
                            MouseArea { anchors.fill: parent; onClicked: print("Toggle", modelData) }
                        }
                    }
                }
            }
        }
    }

    // ---- Клик по капсуле для переключения состояний ----
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (capsule.currentView === "main") {
                capsule.currentView = "expanded"
                capsule.width = 420 // Расширяем
            } else if (capsule.currentView === "expanded") {
                capsule.currentView = "main"
                capsule.width = 140 // Сворачиваем
            } else {
                capsule.currentView = "main" // Если меню открыто — закрываем всё
                capsule.width = 140
            }
        }
    }
    
    // ---- Анимации на всё ----
    Behavior on width { PropertyAnimation { duration: 200; easing.type: Easing.OutCubic } }
    Behavior on height { PropertyAnimation { duration: 200; easing.type: Easing.OutCubic } }
}