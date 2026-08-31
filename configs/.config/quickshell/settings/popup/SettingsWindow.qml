import QtQuick
import Quickshell
import Quickshell.Wayland

import "theme"

PanelWindow {
    id: root

    property var soundManager

    // ============================================================
    // МЕНЕДЖЕРЫ (передаются из shell.qml)
    // ============================================================
    property var theme: null
    property var themeManager: null

    // ============================================================
    // ОСНОВНЫЕ НАСТРОЙКИ ОКНА
    // ============================================================
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    // ============================================================
    // ФОКУС-СКОУП
    // ============================================================
    FocusScope {
        id: focusScope
        anchors.fill: parent
        focus: true

        // ========================================================
        // ESC — ЗАКРЫТИЕ
        // ========================================================
        Keys.onEscapePressed: function(event) {
            root.visible = false
            event.accepted = true
        }

        // ========================================================
        // ОСНОВНОЕ ОКНО
        // ========================================================
        Rectangle {
            id: settingsWindow
            width: 900
            height: 600
            anchors.centerIn: parent
            radius: 24
            // Защита от null: если тема не загружена, используем "#181818"
            color: root.theme && root.theme.colors ? root.theme.colors.background : "#181818"
            antialiasing: true

            // ====================================================
            // СТРАНИЦА ТЕМ (Занимает всё окно)
            // ====================================================
            ThemePage {
                anchors.fill: parent
                theme: root.theme
                themeManager: root.themeManager
            }
        }

        // ========================================================
        // ОБЛАСТЬ СВЕРХУ ОТ ОКНА
        // ========================================================
        MouseArea {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: settingsWindow.top
            }
            onClicked: root.visible = false
        }

        // ========================================================
        // ОБЛАСТЬ СНИЗУ ОТ ОКНА
        // ========================================================
        MouseArea {
            anchors {
                top: settingsWindow.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            onClicked: root.visible = false
        }

        // ========================================================
        // ОБЛАСТЬ СЛЕВА ОТ ОКНА
        // ========================================================
        MouseArea {
            anchors {
                top: settingsWindow.top
                left: parent.left
                bottom: settingsWindow.bottom
                right: settingsWindow.left
            }
            onClicked: root.visible = false
        }

        // ========================================================
        // ОБЛАСТЬ СПРАВА ОТ ОКНА
        // ========================================================
        MouseArea {
            anchors {
                top: settingsWindow.top
                left: settingsWindow.right
                right: parent.right
                bottom: settingsWindow.bottom
            }
            onClicked: root.visible = false
        }
    }

    // ============================================================
    // ФОКУС ПРИ ОТКРЫТИИ
    // ============================================================
    onVisibleChanged: {
        if (visible) {
            focusScope.forceActiveFocus()
        }
    }
}