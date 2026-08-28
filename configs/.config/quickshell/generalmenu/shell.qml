import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Io

import "panel"
import "notifications"

ShellRoot {
    id: root

    // ============================================================
    // THEME MANAGER
    // ============================================================
    ThemeManager { id: themeManager }

    property var theme: themeManager.theme

    // ============================================================
    // DND STATE
    // ============================================================
    property bool dndEnabled: false
    readonly property string dndFile: Quickshell.shellDir + "/../notification-dnd"

    FileView {
        id: dndFileView
        path: root.dndFile
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            var value = text().trim()
            root.dndEnabled = (value === "1")
        }
    }

    // ============================================================
    // NOTIFICATION MODEL
    // ============================================================
    NotificationModel { 
        id: notificationModel 
        dndEnabled: root.dndEnabled
    }

    // ============================================================
    // NOTIFICATION SERVER
    // ============================================================
    NotificationServer {
        id: notificationServer
        bodySupported: true
        bodyMarkupSupported: true
        bodyImagesSupported: true
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: true
        persistenceSupported: true
        keepOnReload: true

        onNotification: function(notification) {
            if (panel.opened || root.dndEnabled) {
                notificationModel.addCenterOnly(notification)
            } else {
                notificationModel.add(notification)
            }
        }
    }

    // ============================================================
    // POPUP
    // ============================================================
    NotificationPopup {
        notificationModel: notificationModel
        theme: root.theme
    }

    // ============================================================
    // MAIN PANEL
    // ============================================================
    PanelWindow {
        id: panel
        theme: root.theme
        opened: false
        panelVisible: false
        notificationModel: notificationModel
        notificationList: notificationModel.centerNotifications
    }

    // ============================================================
    // IPC HANDLER
    // ============================================================
    IpcHandler {
        target: "panel"

        function toggle() {
            if (panel.opened) { panel.close() }
            else { panel.open(); notificationModel.clearPopup() }
        }
        function open() { panel.open(); notificationModel.clearPopup() }
        function close() { panel.close() }
    }
}