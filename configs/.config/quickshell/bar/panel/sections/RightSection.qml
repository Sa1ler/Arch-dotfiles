import QtQuick
import "../../widgets"

Item {
    id: root

    property var theme: null
    property var soundManager: null
    property var wifiPopup: null

    implicitHeight: contentRow.implicitHeight
    implicitWidth: contentRow.implicitWidth

    Row {
        id: contentRow
        spacing: 8
        anchors.verticalCenter: parent.verticalCenter

        KeyboardLayout {
            anchors.verticalCenter: parent.verticalCenter
            theme: root.theme
        }

        WifiIndicator {
            anchors.verticalCenter: parent.verticalCenter
            theme: root.theme
            wifiPopup: root.wifiPopup
        }

        VolumeIndicator {
            anchors.verticalCenter: parent.verticalCenter
            theme: root.theme
        }

        BatteryIndicator {
            anchors.verticalCenter: parent.verticalCenter
            theme: root.theme
        }
    }
}