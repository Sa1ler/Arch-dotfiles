import QtQuick

Item {
    id: root

    property var theme: null

    property color backgroundColor: root.theme.colors.background
    property color surfaceColor: root.theme.colors.surface
    property color accentColor: root.theme.colors.accent
    property color textColor: root.theme.colors.text
    property color secondaryTextColor: root.theme.colors.textSecondary
    property color borderColor: root.theme.colors.border

    Text {
        id: title
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: 28
            topMargin: 28
        }
        text: "О сборке"
        font.family: "Cascadia Code"
        font.pixelSize: 25
        font.weight: Font.Bold
        color: root.textColor
    }

    Text {
        anchors {
            left: title.left
            top: title.bottom
            topMargin: 5
        }
        text: "Информация о системе и этой сборке"
        font.family: "Cascadia Code"
        font.pixelSize: 12
        color: root.secondaryTextColor
    }

    Rectangle {
        id: buildCard
        anchors {
            left: parent.left
            right: parent.right
            top: title.bottom
            leftMargin: 28
            rightMargin: 28
            topMargin: 40
        }
        height: 210
        radius: 22
        color: Qt.lighter(root.surfaceColor, 1.08)
        border.width: 1
        border.color: root.borderColor
        antialiasing: true

        Rectangle {
            id: archLogoBackground
            width: 112
            height: 112
            anchors {
                left: parent.left
                leftMargin: 25
                verticalCenter: parent.verticalCenter
            }
            radius: 28
            color: root.backgroundColor
            border.width: 1
            border.color: root.borderColor
            antialiasing: true

            Text {
                anchors.centerIn: parent
                text: "󰣇"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 64
                color: root.accentColor
            }
        }

        Text {
            id: buildName
            anchors {
                left: archLogoBackground.right
                top: parent.top
                leftMargin: 25
                topMargin: 32
            }
            text: "Arch Linux"
            font.family: "Cascadia Code"
            font.pixelSize: 22
            font.weight: Font.Bold
            color: root.textColor
        }

        Text {
            anchors {
                left: buildName.left
                top: buildName.bottom
                topMargin: 3
            }
            text: "Hyprland Desktop Environment"
            font.family: "Cascadia Code"
            font.pixelSize: 12
            color: root.secondaryTextColor
        }

        Column {
            anchors {
                left: buildName.left
                bottom: parent.bottom
                bottomMargin: 28
            }
            spacing: 6
            Text { text: "Сборка: Graff Hyprland Shell"; font.family: "Cascadia Code"; font.pixelSize: 11; color: root.secondaryTextColor }
            Text { text: "Интерфейс: Quickshell"; font.family: "Cascadia Code"; font.pixelSize: 11; color: root.secondaryTextColor }
            Text { text: "Год: 2026"; font.family: "Cascadia Code"; font.pixelSize: 11; color: root.secondaryTextColor }
        }
    }

    Rectangle {
        id: copyrightCard
        anchors {
            left: buildCard.left
            right: buildCard.right
            top: buildCard.bottom
            topMargin: 16
        }
        height: 68
        radius: 18
        color: Qt.lighter(root.surfaceColor, 1.04)
        border.width: 1
        border.color: root.borderColor
        antialiasing: true

        Rectangle {
            id: copyrightIcon
            width: 40
            height: 40
            radius: 20
            anchors {
                left: parent.left
                leftMargin: 16
                verticalCenter: parent.verticalCenter
            }
            color: root.accentColor

            Text {
                anchors.centerIn: parent
                text: "©"
                font.family: "Cascadia Code"
                font.pixelSize: 17
                font.weight: Font.Bold
                color: root.theme.colors.textSelected
            }
        }

        Text {
            anchors {
                left: copyrightIcon.right
                leftMargin: 14
                verticalCenter: parent.verticalCenter
            }
            text: "Graff • 2026"
            font.family: "Cascadia Code"
            font.pixelSize: 11
            color: root.textColor
        }

        Text {
            anchors {
                right: parent.right
                rightMargin: 18
                verticalCenter: parent.verticalCenter
            }
            text: "Personal Linux Build"
            font.family: "Cascadia Code"
            font.pixelSize: 10
            color: root.secondaryTextColor
        }
    }
}