import QtQuick

Rectangle {
    id: root

    // ============================================================
    // СВОЙСТВА
    // ============================================================
    property string themeName: "Theme Name"
    property bool isSelected: false

    property color bgColor: "#181818"
    property color surfaceColor: "#202020"
    property color accentColor: "#3675FF"
    property color textColor: "#FFFFFF"

    signal clicked()

    // ============================================================
    // РАЗМЕРЫ И ФОРМА
    // ============================================================
    implicitHeight: 52
    radius: 12

    color: isSelected ? Qt.lighter(bgColor, 1.15) : surfaceColor
    border.width: isSelected ? 2 : 1
    border.color: isSelected ? accentColor : (mouseArea.containsMouse ? Qt.lighter(surfaceColor, 1.3) : "#303030")
    antialiasing: true

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    // ============================================================
    // КОНТЕНТ
    // ============================================================
    Item {
        anchors {
            fill: parent
            leftMargin: 16
            rightMargin: 14
        }

        // Название темы (слева)
        Text {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            // Оставляем место для кружочков (4 кружка по 16px + 3 отступа по 8px = 88px + небольшой запас)
            width: parent.width - 96
            
            text: root.themeName
            font.family: "Cascadia Code"
            font.pixelSize: 13
            font.weight: root.isSelected ? Font.Bold : Font.Medium
            color: root.textColor
            elide: Text.ElideRight
        }

        // Кружочки цветов (справа)
        Row {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            spacing: 8

            Repeater {
                model: [root.bgColor, root.surfaceColor, root.accentColor, root.textColor]

                delegate: Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    color: modelData
                    
                    // Тонкая обводка, чтобы светлые кружочки не сливались
                    border.width: 1
                    border.color: Qt.darker(modelData, 1.2)
                }
            }
        }
    }

    // ============================================================
    // ВЗАИМОДЕЙСТВИЕ
    // ============================================================
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}