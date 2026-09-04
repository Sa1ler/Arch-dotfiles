import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Io

import "panel"
import "notifications"
import "modules/SoundEffects"

ShellRoot {
    id: root

    ThemeManager { 
        id: themeManager 
        onThemeChanging: soundPlayer.play("switch.wav")
    }

    property var theme: themeManager.theme

    SoundPlayer {
        id: soundPlayer
        soundsDir: Quickshell.shellDir + "/../sounds"
    }

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

    NotificationModel { 
        id: notificationModel 
        dndEnabled: root.dndEnabled
    }

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

    NotificationPopup {
        notificationModel: notificationModel
        theme: root.theme
        soundPlayer: soundPlayer
    }

    PanelWindow {
        id: panel
        theme: root.theme
        themeManager: themeManager
        soundPlayer: soundPlayer
        opened: false
        panelVisible: false1
        notificationModel: notificationModel
        notificationList: notificationModel.centerNotifications
    }

    

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