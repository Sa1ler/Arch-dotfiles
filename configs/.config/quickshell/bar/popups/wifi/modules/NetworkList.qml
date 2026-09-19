import QtQuick
import QtQuick.Controls

Item {
    id: root

    property var theme: null
    property var networksModel: null
    property string currentSSID: ""
    property bool isConnecting: false
    property string connectingSSID: ""
    property bool wifiEnabled: true

    // === НОВОЕ: передаём saved ===
    signal networkSelected(string ssid, bool secured, bool saved)
    signal scan()
    signal back()

    readonly property color textColor: root.theme && root.theme.colors ? root.theme.colors.text : "#FFFFFF"
    readonly property color textSecondary: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#888888"
    readonly property color accentColor: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"

    Column {
        anchors.fill: parent
        spacing: 10

        // === Заголовок ===
        Row {
            width: root.width
            height: 30
            spacing: 10

            Rectangle {
                width: 30
                height: 30
                radius: 10
                color: backMouse.pressed ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.25) :
                       backMouse.containsMouse ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.12) : "transparent"
                border.width: 1
                border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.25)
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color { ColorAnimation { duration: 180 } }
                scale: backMouse.pressed ? 0.92 : 1.0
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuart } }

                Text {
                    anchors.centerIn: parent
                    text: "\uf060"
                    font.family: "Font Awesome 6 Free Solid"
                    font.pixelSize: 13
                    color: root.accentColor
                }

                MouseArea {
                    id: backMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.back()
                }
            }

            Text {
                text: "Networks"
                font.pixelSize: 16
                font.weight: Font.Bold
                font.family: "JetBrains Mono"
                color: root.textColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Item { width: 1; height: 1 }

            Text {
                text: root.networksModel ? root.networksModel.count + "" : "0"
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.family: "JetBrains Mono"
                color: root.textSecondary
                anchors.verticalCenter: parent.verticalCenter
                opacity: 0.6
            }

            Rectangle {
                width: 30
                height: 30
                radius: 10
                color: scanMouse.pressed ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.25) :
                       scanMouse.containsMouse ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.12) : "transparent"
                border.width: 1
                border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.25)
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color { ColorAnimation { duration: 180 } }
                scale: scanMouse.pressed ? 0.92 : 1.0
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuart } }

                Text {
                    anchors.centerIn: parent
                    text: "\uf021"
                    font.family: "Font Awesome 6 Free Solid"
                    font.pixelSize: 13
                    color: root.accentColor

                    RotationAnimator on rotation {
                        running: root.isConnecting
                        from: 0; to: 360; duration: 900; loops: Animation.Infinite
                    }
                }

                MouseArea {
                    id: scanMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.scan()
                }
            }
        }

        // === Пустые состояния ===
        Item {
            width: root.width
            height: 100
            visible: !root.wifiEnabled || (root.networksModel && root.networksModel.count === 0)

            Column {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: !root.wifiEnabled ? "\uf1eb" : "\uf128"
                    font.family: "Font Awesome 6 Free Solid"
                    font.pixelSize: 34
                    color: "#3A3A3A"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: !root.wifiEnabled ? "WiFi is disabled" : "No networks found"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    font.family: "JetBrains Mono"
                    color: root.textSecondary
                }
            }
        }

        // === Список ===
        ListView {
            id: networkListView
            width: root.width
            height: root.height - 40
            visible: root.wifiEnabled && root.networksModel && root.networksModel.count > 0

            model: root.networksModel
            clip: true
            spacing: 5

            add: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 280 }
                NumberAnimation { property: "scale"; from: 0.92; to: 1; duration: 280; easing.type: Easing.OutBack }
            }

            ScrollBar.vertical: ScrollBar {
                width: 4
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle { radius: 2; color: root.accentColor; opacity: 0.5 }
            }

            delegate: Rectangle {
                id: networkItem
                width: networkListView.width
                height: 48
                radius: 13

                property bool isHovered: networkMouse.containsMouse
                property bool isCurrent: model.isCurrent === true
                property bool isSaved: model.isSaved === true
                property bool isThisConnecting: root.isConnecting && root.connectingSSID === model.ssid

                color: {
                    if (isCurrent) return Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.12)
                    if (isHovered) return Qt.rgba(1, 1, 1, 0.05)
                    return "transparent"
                }
                border.width: isCurrent ? 1.5 : 0
                border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.35)

                Behavior on color { ColorAnimation { duration: 180 } }
                Behavior on border.width { NumberAnimation { duration: 180 } }

                scale: isHovered && !isCurrent ? 1.015 : 1.0
                Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutQuart } }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 12

                    // Иконка сигнала
                    Text {
                        text: "\uf012"
                        font.family: "Font Awesome 6 Free Solid"
                        font.pixelSize: 17
                        color: isCurrent ? root.accentColor : root.textSecondary
                        anchors.verticalCenter: parent.verticalCenter

                        Behavior on color { ColorAnimation { duration: 250 } }
                    }

                    // Название + статус
                    Column {
                        width: networkListView.width - 185
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: model.ssid
                            font.pixelSize: 13
                            font.weight: isCurrent ? Font.Bold : Font.DemiBold
                            font.family: "JetBrains Mono"
                            color: isCurrent ? root.accentColor : root.textColor
                            elide: Text.ElideRight
                            width: parent.width

                            Behavior on color { ColorAnimation { duration: 250 } }
                        }

                        Text {
                            text: {
                                if (isThisConnecting) return "Connecting..."
                                if (isCurrent) return "Connected"
                                if (isSaved) return "Saved"
                                return model.security !== "" ? model.security : "Open"
                            }
                            font.pixelSize: 9
                            font.weight: Font.Medium
                            font.family: "JetBrains Mono"
                            color: isSaved && !isCurrent ? root.accentColor : root.textSecondary
                            opacity: isSaved && !isCurrent ? 0.8 : 0.7

                            Behavior on color { ColorAnimation { duration: 250 } }
                        }
                    }

                    // Звёздочка для сохранённых
                    Text {
                        text: "\uf005"
                        font.family: "Font Awesome 6 Free Solid"
                        font.pixelSize: 11
                        color: root.accentColor
                        anchors.verticalCenter: parent.verticalCenter
                        visible: isSaved && !isCurrent
                        opacity: 0.8
                    }

                    // Замок
                    Rectangle {
                        width: 22
                        height: 22
                        radius: 7
                        color: Qt.rgba(1, 1, 1, 0.04)
                        anchors.verticalCenter: parent.verticalCenter
                        visible: model.isSecured

                        Text {
                            anchors.centerIn: parent
                            text: "\uf023"
                            font.family: "Font Awesome 6 Free Solid"
                            font.pixelSize: 11
                            color: root.textSecondary
                        }
                    }

                    // Полоски сигнала
                    Row {
                        spacing: 3
                        anchors.verticalCenter: parent.verticalCenter

                        Repeater {
                            model: 4
                            Rectangle {
                                width: 4
                                height: 5 + index * 4
                                radius: 2
                                anchors.bottom: parent.bottom
                                color: index < Math.ceil(model.signal / 25)
                                    ? (isCurrent ? root.accentColor : root.textSecondary)
                                    : Qt.rgba(1, 1, 1, 0.06)

                                Behavior on color { ColorAnimation { duration: 250 } }
                            }
                        }
                    }
                }

                MouseArea {
                    id: networkMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: model.isCurrent ? Qt.ArrowCursor : Qt.PointingHandCursor
                    onClicked: {
                        if (!model.isCurrent && !root.isConnecting) {
                            root.networkSelected(model.ssid, model.isSecured, model.isSaved)
                        }
                    }
                }
            }
        }
    }
}