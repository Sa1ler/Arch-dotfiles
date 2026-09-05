import QtQuick

import "../../widgets"

Item {
    id: root

    property var theme: null
    property var soundManager: null
    
    implicitHeight: contentRow.implicitHeight
    implicitWidth: contentRow.implicitWidth

    Row {
        id: contentRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6
        
        // Заглушки для системных виджетов
        Rectangle {
            width: 26
            height: 26
            anchors.verticalCenter: parent.verticalCenter
            radius: 7
            color: "transparent"
            
            Text {
                anchors.centerIn: parent
                text: ""
                color: root.theme.colors.textSecondary || "#999"
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
            }
        }
        
        Rectangle {
            width: 26
            height: 26
            anchors.verticalCenter: parent.verticalCenter
            radius: 7
            color: "transparent"
            
            Text {
                anchors.centerIn: parent
                text: ""
                color: root.theme.colors.textSecondary || "#999"
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
            }
        }
        
        Rectangle {
            width: 26
            height: 26
            anchors.verticalCenter: parent.verticalCenter
            radius: 7
            color: "transparent"
            
            Text {
                anchors.centerIn: parent
                text: ""
                color: root.theme.colors.textSecondary || "#999"
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
            }
        }
        
        // Разделитель
        Rectangle {
            width: 1
            height: 18
            anchors.verticalCenter: parent.verticalCenter
            color: root.theme.colors.border || "#333"
            opacity: 0.5
        }
        
        SettingsButton {
            theme: root.theme
            soundManager: root.soundManager
        }
    }
}