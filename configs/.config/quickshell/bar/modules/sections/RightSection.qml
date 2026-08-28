import QtQuick 2.15
import QtQuick
import Quickshell
import "../base"
import "../widgets"

Item {
    width: modulesRow.implicitWidth
    height: 33

    Row {
        id: modulesRow
        anchors.centerIn: parent
        spacing: 0

        Keyboard { height: 33 }
        Item { width: 8 }
        Wifi { id: wifiWidget; height: 33 }
        Item { width: 8 }
        Volume { height: 33 }
        Item { width: 8 }
        Battery { height: 33 }
    }
}
