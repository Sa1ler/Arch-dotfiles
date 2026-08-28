import QtQuick
import Quickshell
import "../base"
import "../widgets"
import "../../popups/time"
import "../../popups/wifi"

Item {
    width: 200
    height: 33

    Clock {
        anchors.fill: parent
        onClicked: popup.open(clock)
    }

    TimePopup {
        id: popup
    }
}
