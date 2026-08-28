import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root

    required property var notificationModel
    property var theme: null
    property int stackSpacing: 8

    // ============================================================
    // ПОЗИЦИЯ
    // ============================================================
    property string notificationPosition: "top-right"

    readonly property string positionFile:
        Quickshell.shellDir + "/../notification-position"

    FileView {
        id: positionReader
        path: root.positionFile
        watchChanges: true
        printErrors: false

        onFileChanged: reload()

        onLoaded: {
            var value = text().trim()
            if (value !== "" && value !== root.notificationPosition) {
                root.notificationPosition = value
            }
        }
    }

    // ============================================================
    // НАПРАВЛЕНИЕ АНИМАЦИИ
    // ============================================================
    property string slideDirection: {
        if (notificationPosition === "top-left" || notificationPosition === "bottom-left") return "left"
        if (notificationPosition === "top-right" || notificationPosition === "bottom-right") return "right"
        if (notificationPosition === "top-center") return "up"
        if (notificationPosition === "bottom-center") return "down"
        return "right"
    }

    // ============================================================
    // ОКНО ВСЕГДА РАСТЯНУТО НА ВЕСЬ ЭКРАН
    // ============================================================
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

    // ============================================================
    // КОЛОНКА УВЕДОМЛЕНИЙ
    // ============================================================
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

        x: {
            var margin = 20
            if (root.notificationPosition === "top-left" || root.notificationPosition === "bottom-left") {
                return margin
            }
            if (root.notificationPosition === "top-right" || root.notificationPosition === "bottom-right") {
                return parent.width - width - margin
            }
            return (parent.width - width) / 2
        }

        y: {
            var margin = 20
            if (root.notificationPosition.indexOf("top") !== -1) {
                return margin
            }
            return parent.height - height - margin
        }

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