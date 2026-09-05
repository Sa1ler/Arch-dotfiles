import QtQuick

Item {
    id: root

    property var theme: null
    property var soundManager: null
    
    implicitWidth: 30
    implicitHeight: 30

    Rectangle {
        id: buttonBg
        anchors.fill: parent
        radius: 8
        color: mouseArea.containsMouse ? 
               (root.theme.colors.surfaceHover || "#252C36") : 
               "transparent"
        
        Behavior on color { ColorAnimation { duration: 150 } }
        
        Text {
            anchors.centerIn: parent
            text: ""
            color: root.theme.colors.accent || "#5B9BFF"
            font.pixelSize: 15
            font.family: "JetBrainsMono Nerd Font"
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.soundManager) root.soundManager.play("quick_click.wav")
            Quickshell.execDetached(["qs", "-c", "launcher", "ipc", "call", "launcher", "toggle"])
        }
    }
}