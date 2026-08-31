import QtQuick
import Quickshell
import Quickshell.Io

import "popup"

ShellRoot {
    id: root

    // ============================================================
    // МЕНЕДЖЕР ТЕМ
    // ============================================================
    ThemeManager {
        id: themeManager
    }

        // ============================================================
    // ОКНО НАСТРОЕК
    // ============================================================
    SettingsWindow {
        id: settingsWindow
        visible: false
        
        // Передаем сам объект темы, а не её имя
        theme: themeManager.theme
        themeManager: themeManager
    }

    // ============================================================
    // IPC
    // ============================================================
    IpcHandler {
        target: "settings"

        // ========================================================
        // TOGGLE
        // ========================================================
        function toggle(): void {
            settingsWindow.visible = !settingsWindow.visible
        }

        // ========================================================
        // OPEN
        // ========================================================
        function open(): void {
            settingsWindow.visible = true
        }

        // ========================================================
        // CLOSE
        // ========================================================
        function close(): void {
            settingsWindow.visible = false
        }
    }
}