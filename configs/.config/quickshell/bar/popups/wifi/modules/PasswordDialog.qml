import QtQuick

Item {
    id: root

    property var theme: null
    property string ssid: ""
    property bool isConnecting: false

    signal connect(string password)
    signal cancel()

    readonly property color textColor: root.theme && root.theme.colors ? root.theme.colors.text : "#FFFFFF"
    readonly property color textSecondary: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#888888"
    readonly property color accentColor: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
    readonly property color bgColor: root.theme && root.theme.colors ? root.theme.colors.background : "#181818"

    // Затемнение фона
    Rectangle {
        anchors.fill: parent
        radius: 14
        color: Qt.rgba(0, 0, 0, 0.75)
        visible: root.visible
    }

    // === Диалог: высота увеличена, контент помещается ===
    Rectangle {
        anchors.centerIn: parent
        width: 360
        height: 280
        radius: 20
        color: root.bgColor
        border.width: 1.5
        border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.4)

        scale: root.visible ? 1 : 0.85
        opacity: root.visible ? 1 : 0

        Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.3 } }
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }

        Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            // Заголовок
            Column {
                width: parent.width
                spacing: 8

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 48
                    height: 48
                    radius: 24
                    color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.12)
                    border.width: 1
                    border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.3)

                    Text {
                        anchors.centerIn: parent
                        text: "\uf023"
                        font.family: "Font Awesome 6 Free Solid"
                        font.pixelSize: 22
                        color: root.accentColor
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Connect to"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    font.family: "JetBrains Mono"
                    color: root.textSecondary
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.ssid
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    font.family: "JetBrains Mono"
                    color: root.textColor
                    elide: Text.ElideRight
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // Поле ввода пароля
            Rectangle {
                width: parent.width
                height: 44
                radius: 12
                color: Qt.rgba(0, 0, 0, 0.35)
                border.width: passwordInput.activeFocus ? 2 : 1
                border.color: passwordInput.activeFocus ? root.accentColor : Qt.rgba(1, 1, 1, 0.12)

                Behavior on border.color { ColorAnimation { duration: 250 } }
                Behavior on border.width { NumberAnimation { duration: 200 } }

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: "transparent"
                    border.width: 3
                    border.color: root.accentColor
                    opacity: passwordInput.activeFocus ? 0.2 : 0

                    Behavior on opacity { NumberAnimation { duration: 250 } }
                }

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.margins: 14
                    color: root.textColor
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    font.family: "JetBrains Mono"
                    echoMode: TextInput.Password
                    clip: true

                    onAccepted: {
                        if (text.length > 0) {
                            root.connect(text)
                            text = ""
                        }
                    }

                    Keys.onEscapePressed: root.cancel()
                }

                Text {
                    anchors.fill: parent
                    anchors.margins: 14
                    text: "Enter password"
                    color: root.textSecondary
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    font.family: "JetBrains Mono"
                    visible: !passwordInput.text && !passwordInput.activeFocus
                    opacity: 0.5
                }
            }

            // Кнопки
            Row {
                width: parent.width
                height: 40
                spacing: 12

                Rectangle {
                    width: (parent.width - 12) / 2
                    height: 40
                    radius: 10
                    color: cancelMouse.pressed ? Qt.rgba(1, 1, 1, 0.15) :
                           cancelMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(1, 1, 1, 0.05)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.1)

                    Behavior on color { ColorAnimation { duration: 200 } }
                    scale: cancelMouse.pressed ? 0.97 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuart } }

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        font.family: "JetBrains Mono"
                        color: root.textSecondary
                    }

                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.cancel()
                    }
                }

                Rectangle {
                    width: (parent.width - 12) / 2
                    height: 40
                    radius: 10
                    color: {
                        if (root.isConnecting) return Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.5)
                        if (connectMouse.pressed) return Qt.darker(root.accentColor, 1.3)
                        if (connectMouse.containsMouse) return Qt.lighter(root.accentColor, 1.15)
                        return root.accentColor
                    }

                    Behavior on color { ColorAnimation { duration: 200 } }
                    scale: connectMouse.pressed && !root.isConnecting ? 0.97 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuart } }

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "\uf110"
                            font.family: "Font Awesome 6 Free Solid"
                            font.pixelSize: 14
                            color: "#000000"
                            visible: root.isConnecting

                            RotationAnimator on rotation {
                                running: root.isConnecting
                                from: 0; to: 360; duration: 800; loops: Animation.Infinite
                            }
                        }

                        Text {
                            text: root.isConnecting ? "..." : "Connect"
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            font.family: "JetBrains Mono"
                            color: "#000000"
                        }
                    }

                    MouseArea {
                        id: connectMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: !root.isConnecting

                        onClicked: {
                            if (passwordInput.text.length > 0) {
                                root.connect(passwordInput.text)
                                passwordInput.text = ""
                            }
                        }
                    }
                }
            }
        }
    }

    onVisibleChanged: {
        if (visible) focusTimer.restart()
    }

    Timer {
        id: focusTimer
        interval: 150
        onTriggered: passwordInput.forceActiveFocus()
    }
}