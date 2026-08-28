import QtQuick

Item {
    id: root
    property var theme: null
    property var topbarManager: null
    implicitWidth: 40
    implicitHeight: 28

    Text {
        anchors.centerIn: parent
        text: "󰈀"
        font.family: "Symbols Nerd Font"
        font.pixelSize: 14
        color: theme ? theme.colors.text : "#FFFFFF"
    }
}