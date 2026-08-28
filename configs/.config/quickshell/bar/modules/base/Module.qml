import QtQuick

Rectangle {

    id: root

    property int moduleWidth: 140
    property int moduleHeight: 35

    property int moduleRadius: 15

    property real moduleOpacity: 0.70

    property color backgroundColor: "transparent"

    // Если dynamicWidth не меняется, используется moduleWidth
    property int dynamicWidth: moduleWidth

    width: dynamicWidth
    height: moduleHeight

    radius: moduleRadius

    // Всегда прозрачный, фон рисуют только внутренние элементы виджетов
    color: "transparent"

    // Для одного большого контейнера это лучше оставить включенным
    clip: true

    Behavior on width {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutCubic
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    MouseArea {
        anchors.fill: parent

        hoverEnabled: true

        onEntered: root.scale = 1.03
        onExited: root.scale = 1.0
    }
}
