import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root

    required property var notificationModel
    property var theme: null
    property var soundPlayer: null
    property int stackSpacing: 8

    property string notificationPosition: "top-right"
    property string slideDirection: "right"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    focusable: false
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    mask: Region { item: notificationColumn }

    Item {
        id: notificationColumn
        width: 380

        height: {
            var total = 0
            for (var i = 0; i < notificationRepeater.count; ++i) {
                var item = notificationRepeater.itemAt(i)
                if (item) total += item.height
                if (i < notificationRepeater.count - 1) total += root.stackSpacing
            }
            return Math.max(1, total)
        }

        x: parent.width - 380 - 20
        y: 20

        Behavior on x {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        Behavior on y {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        Repeater {
            id: notificationRepeater
            model: root.notificationModel.popupNotifications

            delegate: Item {
                id: delegateRoot
                required property int index
                required property var notification

                width: 380
                height: card.height

                Behavior on height {
                    NumberAnimation { duration: 260; easing.type: Easing.InCubic }
                }

                y: {
                    var position = 0
                    for (var i = 0; i < index; ++i) {
                        var previous = notificationRepeater.itemAt(i)
                        if (previous) position += previous.height
                        position += root.stackSpacing
                    }
                    return position
                }

                Behavior on y {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }

                NotificationCard {
                    id: card
                    notification: delegateRoot.notification
                    theme: root.theme
                    soundPlayer: root.soundPlayer
                    width: 380
                    autoClose: true
                    slideDirection: root.slideDirection

                    onClosed: {
                        root.notificationModel.removePopup(delegateRoot.notification)
                    }
                }
            }
        }
    }
}