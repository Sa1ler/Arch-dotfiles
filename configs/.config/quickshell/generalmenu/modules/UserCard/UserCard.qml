import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null
    property var soundPlayer: null

    property string username: Quickshell.env("USER") || "user"
    property string displayName: ""
    property string avatarPath: ""

    readonly property int cardHeight: 64
    readonly property int horizontalPadding: 14
    readonly property int avatarSize: 40
    readonly property int logoutSize: 40

    implicitHeight: cardHeight

    Process {
        id: getUserInfo
        command: ["sh", "-c", "getent passwd \"$USER\" 2>/dev/null | cut -d: -f5 | cut -d, -f1; if [ -f \"$HOME/.face\" ]; then echo \"$HOME/.face\"; elif [ -f \"$HOME/.face.icon\" ]; then echo \"$HOME/.face.icon\"; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n")
                if (lines.length >= 1 && lines[0] !== "") {
                    root.displayName = lines[0]
                }
                if (lines.length >= 2 && lines[1] !== "") {
                    root.avatarPath = lines[1]
                }
            }
        }
    }

    Process {
        id: logoutProcess
        command: ["hyprctl", "dispatch", "exit"]
    }

    function logout() {
        if (root.soundPlayer) root.soundPlayer.play("disconnect.wav")
        Qt.callLater(function() {
            logoutProcess.running = true
        })
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 16
        color: root.theme ? root.theme.colors.surface : "#1A1F26"
        border.width: 1
        border.color: root.theme ? root.theme.colors.border : "#2A323D"

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
                color: root.theme ? root.theme.colors.surfaceSelected : "#2C3A50"
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
                    color: root.theme ? root.theme.colors.text : "#F0F4F8"
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
                    color: root.theme ? root.theme.colors.text : "#F0F4F8"
                    font.pixelSize: 14
                    font.bold: true
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
                Text {
                    Layout.fillWidth: true
                    text: root.username !== "" ? "@" + root.username : ""
                    color: root.theme ? root.theme.colors.textSecondary : "#9AA9B9"
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
                color: logoutMouseArea.containsMouse ? Qt.rgba(1.0, 0.27, 0.23, 0.15) : "transparent"
                border.width: 1
                border.color: logoutMouseArea.containsMouse ? "#FF453A" : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }
                scale: logoutMouseArea.pressed ? 0.9 : (logoutMouseArea.containsMouse ? 1.05 : 1.0)
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                Text {
                    anchors.centerIn: parent
                    text: "󰍃"
                    color: logoutMouseArea.containsMouse ? "#FF453A" : (root.theme ? root.theme.colors.textSecondary : "#9AA9B9")
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    id: logoutMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.logout()
                }
            }
        }
    }

    Component.onCompleted: {
        getUserInfo.running = true
    }
}