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
        spacing: 8
        anchors.verticalCenter: parent.verticalCenter
        
        // Индикатор раскладки клавиатуры
        KeyboardLayout {
            id: keyboardLayout
            anchors.verticalCenter: parent.verticalCenter
            
            theme: root.theme
        }
        
        // Индикатор WiFi
        WifiIndicator {
            id: wifiIndicator
            anchors.verticalCenter: parent.verticalCenter
            
            theme: root.theme
        }
    }
}