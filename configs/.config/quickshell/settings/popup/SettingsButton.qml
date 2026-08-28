import QtQuick
import Quickshell

Rectangle {
    id: root

    // ============================================================
    // СВОЙСТВА
    // ============================================================
    property string title: ""
    property string icon: ""
    property bool selected: false

    // ============================================================
    // ЦВЕТА
    // ============================================================
    property color accentColor: "#3675FF"
    property color selectedTextColor: "#000000"
    property color textColor: "#FFFFFF"
    property color hoverColor: "#282828"

    // ============================================================
    // ЗВУК
    // ============================================================
    readonly property string clickSoundPath: Quickshell.shellDir + "/../generalmenu/sounds/clicks.wav"

    function playClick() {
        Quickshell.execDetached([
            "sh", "-c",
            "pw-play '" + clickSoundPath + "' 2>/dev/null || paplay '" + clickSoundPath + "' 2>/dev/null || true"
        ])
    }

    // ============================================================
    // РАЗМЕР
    // ============================================================
    width: 145
    height: 42
    radius: 21

    color: root.selected
        ? root.accentColor
        : mouseArea.containsMouse
          ? root.hoverColor
          : "transparent"

    // ============================================================
    // АНИМАЦИЯ ЦВЕТА
    // ============================================================
    Behavior on color {
        ColorAnimation {
            duration: 160
        }
    }

    // ============================================================
    // ИКОНКА
    // ============================================================
    Text {
        id: iconText
        anchors {
            left: parent.left
            leftMargin: 15
            verticalCenter: parent.verticalCenter
        }
        text: root.icon
        font.family: "Symbols Nerd Font"
        font.pixelSize: 18
        color: root.selected ? root.selectedTextColor : root.textColor
    }

    // ============================================================
    // ТЕКСТ
    // ============================================================
    Text {
        id: titleText
        anchors {
            left: iconText.right
            leftMargin: 9
            verticalCenter: parent.verticalCenter
        }
        text: root.title
        font.family: "Cascadia Code"
        font.pixelSize: 13
        font.weight: Font.Medium
        color: root.selected ? root.selectedTextColor : root.textColor
    }

    // ============================================================
    // НАЖАТИЕ
    // ============================================================
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.playClick()  // <-- ЗВУК ПРИ НАЖАТИИ НА КНОПКУ
            root.clicked()
        }
    }

    // ============================================================
    // СИГНАЛ
    // ============================================================
    signal clicked()
}