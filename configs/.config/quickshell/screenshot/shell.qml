import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root

    Process {
        id: screenshot

        command: [
            "/home/graff/.config/quickshell/screenshot/scripts/screenshot.sh"
        ]

        onExited: {
            if (exitCode === 0) {
                notification.running = true
            }
        }
    }

    Process {
        id: notification

        command: [
            "/usr/bin/notify-send",
            "-a",
            "Screenshot",
            "-i",
            "camera-photo",
            "Скриншот сделан",
            "Снимок экрана скопирован в буфер обмена"
        ]
    }

    IpcHandler {
        target: "screenshot"

        function show() {
            if (!screenshot.running) {
                screenshot.running = true
            }
        }

        function hide() {
        }

        function toggle() {
            if (!screenshot.running) {
                screenshot.running = true
            }
        }
    }
}