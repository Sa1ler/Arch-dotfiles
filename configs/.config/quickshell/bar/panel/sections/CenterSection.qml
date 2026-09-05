import QtQuick

import "../../widgets"

Item {
    id: root

    property var theme: null
    property var soundManager: null
    
    implicitHeight: clockWidget.implicitHeight
    implicitWidth: clockWidget.implicitWidth

    Clock {
        id: clockWidget
        anchors.centerIn: parent
        
        theme: root.theme
        soundManager: root.soundManager
    }
}