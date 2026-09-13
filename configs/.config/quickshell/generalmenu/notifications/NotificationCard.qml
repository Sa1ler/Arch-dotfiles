import QtQuick
import Quickshell

Item {
    id: root

    property var notification: null
    property var theme: null
    property var soundPlayer: null
    property bool autoClose: true
    property real closeHeight: 0
    property bool closing: false
    property bool hovered: hoverArea.containsMouse
    property string slideDirection: "right"

    signal closed()

    width: 340   // ← БЫЛО 380
    height: closing ? closeHeight : card.height
    opacity: 0

    // === Кэшированные свойства уведомления ===
    readonly property bool isCritical: notification ? notification.urgency === 2 : false
    readonly property string typeIcon: isCritical ? "!" : "i"
    readonly property color typeColor: isCritical ? "#FF453A" : (theme ? theme.colors.accent : "#5B9BFF")
    
    readonly property string appName: notification ? (notification.appName || "Notification") : ""
    readonly property string summary: notification ? (notification.summary || "") : ""
    readonly property string body: notification ? (notification.body || "") : ""
    readonly property bool hasBody: body !== ""
    
    readonly property color surfaceColor: theme ? theme.colors.surface : "#202020"
    readonly property color textColor: theme ? theme.colors.text : "#FFFFFF"
    readonly property color textSecColor: theme ? theme.colors.textSecondary : "#A0A0A0"

    function closeCard() {
        if (closing) return
        if (soundPlayer) soundPlayer.play("tick.wav")
        closeHeight = height
        closing = true
        expireTimer.stop()
        closeAnimation.start()
    }

    Component.onCompleted: {
        appear.start()
        if (autoClose && notification) {
            expireTimer.interval = notification.expireTimeout > 0 
                ? notification.expireTimeout * 1000 
                : 5000
            expireTimer.start()
        }
    }

    Timer {
        id: expireTimer
        repeat: false
        onTriggered: {
            if (root.closing) return
            if (root.hovered) {
                restart()
                return
            }
            root.closeCard()
        }
    }

    // === Упрощённая анимация slide ===
    readonly property bool isVertical: slideDirection === "up" || slideDirection === "down"
    readonly property real slideOffset: (slideDirection === "left" || slideDirection === "up") ? -80 : 80

    Translate { id: slide }
    transform: slide

    ParallelAnimation {
        id: appear
        NumberAnimation { 
            target: root
            property: "opacity"
            from: 0
            to: 1
            duration: 220
            easing.type: Easing.OutCubic 
        }
        NumberAnimation {
            target: slide
            property: isVertical ? "y" : "x"
            from: slideOffset
            to: 0
            duration: 280
            easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: closeAnimation
        NumberAnimation { 
            target: root
            property: "opacity"
            from: 1
            to: 0
            duration: 220
            easing.type: Easing.InCubic 
        }
        NumberAnimation {
            target: slide
            property: isVertical ? "y" : "x"
            from: 0
            to: slideOffset
            duration: 260
            easing.type: Easing.InCubic
        }
        NumberAnimation { 
            target: root
            property: "closeHeight"
            from: root.closeHeight
            to: 0
            duration: 260
            easing.type: Easing.InCubic 
        }
        onFinished: root.closed()
    }

    Rectangle {
        id: card
        width: parent.width
        height: contentRow.implicitHeight + 24
        radius: 18
        color: surfaceColor
        border.width: 1
        border.color: hovered ? Qt.lighter(typeColor, 1.15) : Qt.rgba(typeColor.r, typeColor.g, typeColor.b, 0.28)
        
        Behavior on border.color { ColorAnimation { duration: 180 } }

        // Внутренняя подсветка
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 1
            border.color: typeColor
            opacity: hovered ? 0.16 : 0.06
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        Row {
            id: contentRow
            anchors { 
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 12 
            }
            spacing: 10

            // Иконка типа
            Rectangle {
                id: typeBox
                width: 42
                height: 42
                radius: 12
                color: Qt.rgba(typeColor.r, typeColor.g, typeColor.b, 0.10)
                border.width: 1
                border.color: Qt.rgba(typeColor.r, typeColor.g, typeColor.b, hovered ? 0.65 : 0.32)
                
                Behavior on border.color { ColorAnimation { duration: 180 } }

                Text {
                    anchors.centerIn: parent
                    text: typeIcon
                    color: typeColor
                    font.family: "Cascadia Code"
                    font.pixelSize: 20
                    font.bold: true
                }

                // Индикатор
                Rectangle {
                    width: 5
                    height: 5
                    radius: 2.5
                    anchors { 
                        right: parent.right
                        bottom: parent.bottom
                        rightMargin: 5
                        bottomMargin: 5 
                    }
                    color: typeColor
                }
            }

            // Текст и действия
            Column {
                id: textColumn
                width: parent.width - typeBox.width - parent.spacing
                spacing: 4

                Text {
                    width: parent.width
                    text: appName
                    color: textSecColor
                    font.family: "Cascadia Code"
                    font.pixelSize: 10
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: summary
                    color: textColor
                    font.family: "Cascadia Code"
                    font.pixelSize: 14
                    font.bold: true
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    visible: hasBody
                    text: body
                    color: textSecColor
                    font.family: "Cascadia Code"
                    font.pixelSize: 11
                    wrapMode: Text.Wrap
                    maximumLineCount: 4
                    elide: Text.ElideRight
                }

                NotificationActions {
                    width: parent.width
                    notification: root.notification
                    theme: root.theme
                    visible: !root.closing
                    enabled: !root.closing
                    onActionTriggered: root.closeCard()
                }
            }
        }

        // Кнопка закрытия
        Rectangle {
            id: closeButton
            anchors { 
                top: parent.top
                right: parent.right
                topMargin: 8
                rightMargin: 8 
            }
            width: 22
            height: 22
            radius: 11
            color: closeArea.containsMouse 
                ? Qt.rgba(textColor.r, textColor.g, textColor.b, 0.15) 
                : Qt.rgba(textColor.r, textColor.g, textColor.b, 0.07)

            Text {
                anchors.centerIn: parent
                text: "×"
                color: textColor
                font.family: "Cascadia Code"
                font.pixelSize: 16
            }

            MouseArea {
                id: closeArea
                anchors.fill: parent
                hoverEnabled: true
                onPressed: root.closeCard()
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}