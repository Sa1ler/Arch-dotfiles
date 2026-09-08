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
        
        KeyboardLayout { anchors.verticalCenter: parent.verticalCenter; theme: root.theme }
        WifiIndicator { anchors.verticalCenter: parent.verticalCenter; theme: root.theme }
        VolumeIndicator { anchors.verticalCenter: parent.verticalCenter; theme: root.theme }
        BatteryIndicator { anchors.verticalCenter: parent.verticalCenter; theme: root.theme }
    }
}