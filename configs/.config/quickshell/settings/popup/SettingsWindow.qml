import QtQuick
import Quickshell
import Quickshell.Wayland

import "theme"
import "about"
import "notifications"
import "topbar"

PanelWindow {
    id: root

    property var soundManager
    property string currentPage: "themes"

    // ============================================================
    // МЕНЕДЖЕРЫ (передаются из shell.qml)
    // ============================================================
    property var theme: null
    property var themeManager: null
    property var topbarManager: null

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
            color: root.theme.colors.background
            antialiasing: true

            // ====================================================
            // ЛЕВАЯ ПАНЕЛЬ
            // ====================================================
            Rectangle {
                id: sidebar
                width: 185
                height: parent.height
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                color: "transparent"

                // Разделитель
                Rectangle {
                    id: separator
                    width: 1
                    height: parent.height - 50
                    anchors {
                        right: parent.right
                        rightMargin: 8
                        verticalCenter: parent.verticalCenter
                    }
                    color: root.theme.colors.separator
                }

                // ================================================
                // ТЕМЫ
                // ================================================
                SettingsButton {
                    id: themesButton
                    anchors {
                        top: parent.top
                        topMargin: 24
                        horizontalCenter: parent.horizontalCenter
                    }
                    title: "Темы"
                    icon: "󰏘"
                    selected: root.currentPage === "themes"
                    accentColor: root.theme.colors.accent
                    selectedTextColor: root.theme.colors.textSelected
                    textColor: root.theme.colors.text
                    hoverColor: root.theme.colors.surfaceHover
                    onClicked: root.currentPage = "themes"
                }

                // ================================================
                // ТОПБАР
                // ================================================
                SettingsButton {
                    id: topbarButton
                    anchors {
                        top: themesButton.bottom
                        topMargin: 10
                        horizontalCenter: parent.horizontalCenter
                    }
                    title: "Топбар"
                    icon: "󰍛"
                    selected: root.currentPage === "topbar"
                    accentColor: root.theme.colors.accent
                    selectedTextColor: root.theme.colors.textSelected
                    textColor: root.theme.colors.text
                    hoverColor: root.theme.colors.surfaceHover
                    onClicked: root.currentPage = "topbar"
                }

                // ================================================
                // УВЕДОМЛЕНИЯ
                // ================================================
                SettingsButton {
                    id: notificationsButton
                    anchors {
                        top: topbarButton.bottom
                        topMargin: 10
                        horizontalCenter: parent.horizontalCenter
                    }
                    title: "Уведомления"
                    icon: "󰂚"
                    selected: root.currentPage === "notifications"
                    accentColor: root.theme.colors.accent
                    selectedTextColor: root.theme.colors.textSelected
                    textColor: root.theme.colors.text
                    hoverColor: root.theme.colors.surfaceHover
                    onClicked: root.currentPage = "notifications"
                }

                // ================================================
                // О СИСТЕМЕ
                // ================================================
                SettingsButton {
                    id: aboutButton
                    anchors {
                        top: notificationsButton.bottom
                        topMargin: 10
                        horizontalCenter: parent.horizontalCenter
                    }
                    title: "О системе"
                    icon: "󰋼"
                    selected: root.currentPage === "about"
                    accentColor: root.theme.colors.accent
                    selectedTextColor: root.theme.colors.textSelected
                    textColor: root.theme.colors.text
                    hoverColor: root.theme.colors.surfaceHover
                    onClicked: root.currentPage = "about"
                }
            }

            // ====================================================
            // ОБЛАСТЬ КОНТЕНТА
            // ====================================================
            Item {
                id: content
                anchors {
                    left: sidebar.right
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }

                // ================================================
                // ТЕМЫ
                // ================================================
                ThemePage {
                    anchors.fill: parent
                    visible: root.currentPage === "themes"
                    theme: root.theme
                    themeManager: root.themeManager
                }

                // ================================================
                // ТОПБАР
                // ================================================
                TopBarPage {
                    anchors.fill: parent
                    visible: root.currentPage === "topbar"
                    theme: root.theme
                    topbarManager: root.topbarManager
                }

                // ================================================
                // УВЕДОМЛЕНИЯ
                // ================================================
                NotificationsPage {
                    anchors.fill: parent
                    visible: root.currentPage === "notifications"
                    theme: root.theme
                }

                // ================================================
                // О СИСТЕМЕ
                // ================================================
                AboutPage {
                    anchors.fill: parent
                    visible: root.currentPage === "about"
                    theme: root.theme
                }
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