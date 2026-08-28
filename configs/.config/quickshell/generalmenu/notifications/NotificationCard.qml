import QtQuick
import Quickshell

Item {
    id: root

    readonly property string clickSoundPath: Quickshell.shellDir + "/sounds/clicks.wav"

    function playClick() {
        Quickshell.execDetached([
            "sh", "-c",
            "pw-play '" + clickSoundPath + "' 2>/dev/null || paplay '" + clickSoundPath + "' 2>/dev/null || true"
        ])
    }

    property var notification: null
    property var theme: null
    property bool autoClose: true
    property real closeHeight: 0
    property bool closing: false
    property bool hovered: hoverArea.containsMouse
    property string slideDirection: "right"

    signal closed()

    property color backgroundColor: root.theme.colors.background
    property color surfaceColor: root.theme.colors.surface
    property color surfaceHoverColor: root.theme.colors.surfaceHover
    property color accentColor: root.theme.colors.accent
    property color textColor: root.theme.colors.text
    property color secondaryTextColor: root.theme.colors.textSecondary
    property color borderColor: root.theme.colors.border
    property color selectedTextColor: root.theme.colors.textSelected

    width: 380
    height: closing ? closeHeight : card.height
    opacity: 0

    property string notificationType: !notification ? "info" : (notification.urgency === 2 ? "critical" : "info")
    property string typeIcon: notificationType === "critical" ? "!" : "i"
    property color typeColor: notificationType === "critical" ? "#FF453A" : root.accentColor

    function closeCard() {
        if (closing) return
        closeHeight = height
        closing = true
        expireTimer.stop()
        closeAnimation.start()
    }

    Component.onCompleted: {
        appear.start()
        if (root.autoClose) {
            if (notification && notification.expireTimeout > 0) {
                expireTimer.interval = notification.expireTimeout * 1000
            } else {
                expireTimer.interval = 5000
            }
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

    Translate { id: slide }
    transform: slide

    ParallelAnimation {
        id: appear
        NumberAnimation { target: root; property: "opacity"; from: 0; to: 1; duration: 220; easing.type: Easing.OutCubic }
        PropertyAnimation {
            target: slide
            property: (slideDirection === "up" || slideDirection === "down") ? "y" : "x"
            from: (slideDirection === "left" || slideDirection === "up") ? -80 : 80
            to: 0
            duration: 280
            easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: closeAnimation
        NumberAnimation { target: root; property: "opacity"; from: 1; to: 0; duration: 220; easing.type: Easing.InCubic }
        PropertyAnimation {
            target: slide
            property: (slideDirection === "up" || slideDirection === "down") ? "y" : "x"
            from: 0
            to: (slideDirection === "left" || slideDirection === "up") ? -80 : 80
            duration: 260
            easing.type: Easing.InCubic
        }
        NumberAnimation { target: root; property: "closeHeight"; from: root.closeHeight; to: 0; duration: 260; easing.type: Easing.InCubic }
        onFinished: root.closed()
    }

    Rectangle {
        id: card
        width: parent.width
        height: contentRow.implicitHeight + 24
        radius: 18
        color: root.surfaceColor
        antialiasing: true

        border.width: 1
        border.color: root.hovered ? Qt.lighter(root.typeColor, 1.15) : Qt.rgba(root.typeColor.r, root.typeColor.g, root.typeColor.b, 0.28)

        Behavior on border.color { ColorAnimation { duration: 180 } }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 1
            border.color: root.typeColor
            opacity: root.hovered ? 0.16 : 0.06
            antialiasing: true
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        Row {
            id: contentRow
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
            spacing: 10

            Rectangle {
                id: typeBox
                width: 42
                height: 42
                radius: 12
                color: Qt.rgba(root.typeColor.r, root.typeColor.g, root.typeColor.b, 0.10)
                border.width: 1
                border.color: Qt.rgba(root.typeColor.r, root.typeColor.g, root.typeColor.b, root.hovered ? 0.65 : 0.32)
                anchors.top: parent.top
                antialiasing: true

                Text {
                    anchors.centerIn: parent
                    text: root.typeIcon
                    color: root.typeColor
                    font.family: "Cascadia Code"
                    font.pixelSize: 20
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Rectangle {
                    width: 5
                    height: 5
                    radius: 2.5
                    anchors { right: parent.right; bottom: parent.bottom; rightMargin: 5; bottomMargin: 5 }
                    color: root.typeColor
                    antialiasing: true
                }

                Behavior on border.color { ColorAnimation { duration: 180 } }
            }

            Column {
                id: textColumn
                width: parent.width - typeBox.width - parent.spacing
                spacing: 4

                Text {
                    width: parent.width
                    text: !root.notification ? "" : root.notification.appName || "Notification"
                    color: root.secondaryTextColor
                    font.family: "Cascadia Code"
                    font.pixelSize: 10
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: !root.notification ? "" : root.notification.summary || ""
                    color: root.textColor
                    font.family: "Cascadia Code"
                    font.pixelSize: 14
                    font.bold: true
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    visible: !root.notification ? false : root.notification.body !== ""
                    text: !root.notification ? "" : root.notification.body || ""
                    color: root.secondaryTextColor
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

        Rectangle {
            id: closeButton
            anchors { top: parent.top; right: parent.right; topMargin: 8; rightMargin: 8 }
            width: 22
            height: 22
            radius: 11
            color: closeArea.containsMouse ? Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.15) : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.07)
            antialiasing: true

            Text {
                anchors.centerIn: parent
                text: "×"
                color: root.textColor
                font.family: "Cascadia Code"
                font.pixelSize: 16
            }

            MouseArea {
                id: closeArea
                anchors.fill: parent
                hoverEnabled: true
                onPressed: {
                    root.playClick()
                    root.closeCard()
                }
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