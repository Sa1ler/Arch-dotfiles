import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null

    property string username: ""
    property string displayName: ""
    property string avatarPath: ""

    readonly property color backgroundColor: root.theme.colors.surface
    readonly property color borderColor: root.theme.colors.border
    readonly property color textColor: root.theme.colors.text
    readonly property color secondaryTextColor: root.theme.colors.textSecondary
    readonly property color selectedColor: root.theme.colors.surfaceSelected
    readonly property color dangerColor: "#FF453A"

    readonly property int cardHeight: 64
    readonly property int horizontalPadding: 14
    readonly property int avatarSize: 40
    readonly property int logoutSize: 40

    implicitHeight: cardHeight

    Process {
        id: getUsername
        command: ["sh", "-c", "printf '%s' \"$USER\""]
        stdout: StdioCollector {
            onStreamFinished: {
                var name = text.trim()
                if (name !== "") {
                    root.username = name
                    if (root.displayName === "") root.displayName = name
                }
            }
        }
    }

    Process {
        id: getDisplayName
        command: ["sh", "-c", "getent passwd \"$USER\" | cut -d: -f5 | cut -d, -f1"]
        stdout: StdioCollector {
            onStreamFinished: {
                var result = text.trim()
                if (result !== "" && result !== root.username) root.displayName = result
            }
        }
    }

    Process {
        id: getAvatar
        command: ["sh", "-c", "if [ -f \"$HOME/.face\" ]; then printf '%s' \"$HOME/.face\"; elif [ -f \"$HOME/.face.icon\" ]; then printf '%s' \"$HOME/.face.icon\"; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                var path = text.trim()
                if (path !== "") root.avatarPath = path
            }
        }
    }

    Process {
        id: logoutProcess
        command: ["hyprctl", "dispatch", "exit"]
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 16
        color: root.backgroundColor
        border.width: 1
        border.color: root.borderColor

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: root.horizontalPadding
            anchors.rightMargin: root.horizontalPadding
            spacing: 12

            Rectangle {
                id: avatarBackground
                Layout.preferredWidth: root.avatarSize
                Layout.preferredHeight: root.avatarSize
                radius: width / 2
                color: root.selectedColor
                clip: true

                Image {
                    id: avatar
                    anchors.fill: parent
                    source: root.avatarPath !== "" ? "file://" + root.avatarPath : ""
                    sourceSize.width: root.avatarSize * 2
                    sourceSize.height: root.avatarSize * 2
                    fillMode: Image.PreserveAspectCrop
                    smooth: false
                    visible: status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent
                    text: root.displayName !== "" ? root.displayName.charAt(0).toUpperCase() : (root.username !== "" ? root.username.charAt(0).toUpperCase() : "?")
                    color: root.textColor
                    font.pixelSize: 18
                    font.bold: true
                    visible: avatar.status !== Image.Ready
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    Layout.fillWidth: true
                    text: root.displayName !== "" ? root.displayName : root.username
                    color: root.textColor
                    font.pixelSize: 14
                    font.bold: true
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
                Text {
                    Layout.fillWidth: true
                    text: root.username !== "" ? "@" + root.username : ""
                    color: root.secondaryTextColor
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
            }

            Rectangle {
                id: logoutButton
                Layout.preferredWidth: root.logoutSize
                Layout.preferredHeight: root.logoutSize
                radius: 12
                color: logoutMouseArea.containsMouse ? Qt.rgba(root.dangerColor.r, root.dangerColor.g, root.dangerColor.b, 0.15) : "transparent"
                border.width: 1
                border.color: logoutMouseArea.containsMouse ? root.dangerColor : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
                scale: logoutMouseArea.pressed ? 0.9 : (logoutMouseArea.containsMouse ? 1.05 : 1.0)
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                Text {
                    anchors.centerIn: parent
                    text: "󰍃"
                    color: logoutMouseArea.containsMouse ? root.dangerColor : root.secondaryTextColor
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    id: logoutMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: logoutProcess.running = true
                }
            }
        }
    }

    Component.onCompleted: {
        getUsername.running = true
        getDisplayName.running = true
        getAvatar.running = true
    }
}