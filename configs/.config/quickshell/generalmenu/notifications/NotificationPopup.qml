import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var notificationModel
    property var theme: null
    property var soundPlayer: null
    property int stackSpacing: 8

    property string notificationPosition: "top-right"
    property string slideDirection: "right"
    
    // === Единая точка управления шириной ===
    readonly property int cardWidth: 340
    readonly property int edgeMargin: 20

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

    Column {
        id: notificationColumn
        width: root.cardWidth
        spacing: root.stackSpacing
        
        x: parent.width - root.cardWidth - root.edgeMargin
        y: root.edgeMargin

        Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        
        // === ПЛАВНОЕ СМЕЩЕНИЕ существующих карточек ===
        // Срабатывает когда:
        // 1. Появилась новая карточка → существующие съезжают вниз
        // 2. Карточка исчезла → существующие поднимаются вверх
        move: Transition {
            NumberAnimation { 
                properties: "y"
                duration: 300
                easing.type: Easing.OutCubic 
            }
        }
        
        // === ПЛАВНОЕ ПОЯВЛЕНИЕ новых карточек (позиция) ===
        add: Transition {
            NumberAnimation {
                properties: "y"
                from: -50
                duration: 280
                easing.type: Easing.OutCubic
            }
        }

        Repeater {
            model: root.notificationModel.popupNotifications

            delegate: Item {
                id: delegateRoot
                required property int index
                required property var notification

                width: root.cardWidth
                height: card.height

                Behavior on height {
                    NumberAnimation { duration: 260; easing.type: Easing.InCubic }
                }

                NotificationCard {
                    id: card
                    notification: delegateRoot.notification
                    theme: root.theme
                    soundPlayer: root.soundPlayer
                    width: root.cardWidth
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