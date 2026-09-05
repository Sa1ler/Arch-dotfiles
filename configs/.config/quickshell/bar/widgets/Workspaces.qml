import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null
    property var soundManager: null
    property int maxWorkspaces: 7
    property int currentWorkspace: 1
    property int activeIndex: 0

    // Размеры капсулы (УВЕЛИЧЕНО)
    property real inactiveSize: 18      // Было 8
    property real activeWidth: 30       // Было 28
    property real capsuleHeight: 18     // Было 8
    property real capsuleRadius: 10      // Половина высоты

    implicitWidth: contentRow.implicitWidth
    implicitHeight: capsuleHeight

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: root.maxWorkspaces

            Rectangle {
                id: pill

                property int wsIndex: index + 1
                property bool isActive: index === root.activeIndex
                property bool isHovered: pillMouse.containsMouse

                width: isActive ? root.activeWidth : 
                       (isHovered ? root.inactiveSize + 2 : root.inactiveSize)
                height: root.capsuleHeight
                radius: root.capsuleRadius

                color: isActive ? 
                       (root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF") : 
                       (root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#666")

                opacity: isActive ? 1.0 : (isHovered ? 0.6 : 0.4)

                Behavior on width {
                    NumberAnimation {
                        duration: 280
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
                    ColorAnimation {
                        duration: 200
                    }
                }

                MouseArea {
                    id: pillMouse
                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.soundManager) root.soundManager.play("quick_click.wav")
                        switchToWorkspace(pill.wsIndex)
                    }
                }
            }
        }
    }

    Process {
        id: getWorkspace
        command: ["bash", "-c", "hyprctl activeworkspace -j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    root.currentWorkspace = data.id
                    root.activeIndex = data.id - 1
                    if (root.activeIndex < 0) root.activeIndex = 0
                } catch(e) {
                    console.warn("Failed to parse workspace data:", e)
                }
            }
        }
    }

    Process {
        id: hyprListener
        command: ["bash", "-c", "socat - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"]
        running: true
        stdout: SplitParser {
            onRead: function(line) {
                if (line.startsWith("workspace>>")) {
                    getWorkspace.running = true
                }
            }
        }
    }

    Process {
        id: switchWorkspace
    }

    Component.onCompleted: {
        getWorkspace.running = true
    }

    function switchToWorkspace(number) {
        switchWorkspace.command = ["hyprctl", "dispatch", "workspace", number.toString()]
        switchWorkspace.running = true
        root.activeIndex = number - 1
    }
}