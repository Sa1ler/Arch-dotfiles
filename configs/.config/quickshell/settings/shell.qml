import QtQuick
import Quickshell
import Quickshell.Io

import "popup"

ShellRoot {
    id: root

    // ============================================================
    // МЕНЕДЖЕРЫ
    // ============================================================
    ThemeManager { id: themeManager }
    TopBarManager { id: topbarManager }

    property var theme: themeManager.theme

    // ============================================================
    // ОКНО НАСТРОЕК
    // ============================================================
    SettingsWindow {
        id: settingsWindow
        visible: false
        theme: root.theme
        themeManager: themeManager
        topbarManager: topbarManager
    }

    // ============================================================
    // IPC
    // ============================================================
    IpcHandler {
        target: "settings"

        function toggle(): void {
            settingsWindow.visible = !settingsWindow.visible
        }

        function open(): void {
            settingsWindow.visible = true
        }

        function close(): void {
            settingsWindow.visible = false
        }
    }
}