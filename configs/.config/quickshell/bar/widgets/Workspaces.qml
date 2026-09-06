import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null
    property var soundManager: null
    property int maxWorkspaces: 6
    property int currentWorkspace: 1
    property int activeIndex: 0

    // Размеры капсулы
    property real inactiveSize: 18
    property real activeWidth: 30
    property real capsuleHeight: 18
    property real capsuleRadius: 10

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
                    NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }

                MouseArea {
                    id: pillMouse
                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: function(mouse) {
                        if (root.soundManager) root.soundManager.play("quick_click.wav")
                        if (mouse.button === Qt.LeftButton) {
                            switchToWorkspace(pill.wsIndex)
                        } else if (mouse.button === Qt.RightButton) {
                            moveWindowToWorkspace(pill.wsIndex)
                        }
                    }

                    onWheel: function(wheel) {
                        if (wheel.angleDelta.y > 0) {
                            switchToWorkspace(Math.max(1, root.currentWorkspace - 1))
                        } else {
                            switchToWorkspace(Math.min(root.maxWorkspaces, root.currentWorkspace + 1))
                        }
                    }
                }
            }
        }
    }

    // Точное чтение активного стола (для special workspace и т.п.)
    Process {
        id: getWorkspace
        command: ["bash", "-c", "hyprctl activeworkspace -j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    root.currentWorkspace = data.id
                    if (data.id > 0 && data.id <= root.maxWorkspaces) {
                        root.activeIndex = data.id - 1
                    }
                } catch(e) {
                    // ignore — события socket2 всё равно обновят полоску
                }
            }
        }
    }

    // Слушатель событий: обновляет полоску НАПРЯМУЮ из workspace>>
    Process {
        id: hyprListener
        command: ["bash", "-c",
            "socat - UNIX-CONNECT:$(ls -t /run/user/$(id -u)/hypr/*/.socket2.sock 2>/dev/null | head -n1)"]
        running: true
        stdout: SplitParser {
            onRead: function(line) {
                if (line.startsWith("workspace>>")) {
                    // Событие вида "workspace>>2" — обновляем мгновенно
                    var id = parseInt(line.split(">>")[1])
                    if (!isNaN(id) && id >= 1 && id <= root.maxWorkspaces) {
                        root.currentWorkspace = id
                        root.activeIndex = id - 1
                    }
                    getWorkspace.running = true
                } else if (line.startsWith("focusedmon>>") ||
                           line.startsWith("createworkspace>>") ||
                           line.startsWith("destroyworkspace>>")) {
                    getWorkspace.running = true
                }
            }
        }
    }

    Component.onCompleted: {
        getWorkspace.running = true
    }

    // НОВЫЙ синтаксис Hyprland 0.55+: сокет оборачивает в return hl.dispatch(...)
    function hyprCmd(luaDispatcher) {
        Quickshell.execDetached(["bash", "-c",
            "SOCK=$(ls -t /run/user/$(id -u)/hypr/*/.socket.sock 2>/dev/null | head -n1); " +
            "[ -S \"$SOCK\" ] && printf '%s\\n' 'dispatch " + luaDispatcher + "' | socat - UNIX-CONNECT:$SOCK"])
    }

    function switchToWorkspace(number) {
        hyprCmd("hl.dsp.focus({ workspace = " + number + " })")
        root.activeIndex = number - 1
    }

    function moveWindowToWorkspace(number) {
        hyprCmd("hl.dsp.window.move({ workspace = " + number + " })")
    }
}