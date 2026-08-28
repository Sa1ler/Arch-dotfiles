import QtQuick
import Quickshell
import Quickshell.Io
import "../base"

Item {
    id: root

    property int currentWorkspace: 1
    property int activeIndex: 0

    implicitWidth: 6 * 16 + 5 * 4
    implicitHeight: 16

    Row {
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: 6

            Rectangle {
                id: pill

                width: index === root.activeIndex ? 24 : 16
                height: 16
                radius: 8
                color: index === root.activeIndex ? "#3675ff" : "#778899"
                opacity: index === root.activeIndex ? 0.8 : (pill.hovered ? 0.55 : 0.4)

                property bool hovered: false

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: pill.hovered = true
                    onExited: pill.hovered = false
                    onClicked: switchToWorkspace(index + 1)
                }

                Behavior on width {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
        }
    }

    Process {
        id: getWorkspace
        command: [
            "bash",
            "-c",
            "hyprctl activeworkspace -j"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let data = JSON.parse(text)
                    root.currentWorkspace = data.id
                    root.activeIndex = data.id - 1
                    if (root.activeIndex < 0) root.activeIndex = 0
                } catch(e) {}
            }
        }
    }

    Process {
        id: hyprListener
        command: [
            "bash",
            "-c",
            "socat - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
        ]
        running: true
        stdout: SplitParser {
            onRead: function(line) {
                if(line.startsWith("workspace>>")) {
                    getWorkspace.running = true
                }
            }
        }
    }

    Process {
        id: switchWorkspace
    }

    Component.onCompleted: getWorkspace.running = true

    function switchToWorkspace(number) {
        switchWorkspace.command = [
            "hyprctl",
            "dispatch",
            "workspace",
            number.toString()
        ]
        switchWorkspace.running = true
        root.activeIndex = number - 1
    }
}
