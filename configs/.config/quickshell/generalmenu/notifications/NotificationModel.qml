import QtQuick
import Quickshell
import Quickshell.Io
import "../../common" as Common

Item {
    id: root
    ListModel { id: popupList }
    property var popupNotifications: popupList
    ListModel { id: centerList }
    property var centerNotifications: centerList

    readonly property string historyFile: "/home/graff/.config/quickshell/notification-history.json"

    Process {
        id: ensureHistory
        command: ["sh", "-c", "if [ ! -f '" + root.historyFile + "' ]; then printf '%s' '[]' > '" + root.historyFile + "'; fi"]
    }

    Process {
        id: writeHistory
        property string data: "[]"
        command: ["sh", "-c", "printf '%s' '" + data.replace(/'/g, "'\\''") + "' > '" + root.historyFile + "'"]
    }

    function saveHistory() {
        var history = []
        for (var i = 0; i < centerList.count; ++i) {
            var item = centerList.get(i)
            var notification = item.notification
            if (!notification) continue
            history.push({
                "appName": notification.appName || "Notification",
                "summary": notification.summary || "",
                "body": notification.body || "",
                "urgency": notification.urgency || 1,
                "timestamp": Date.now()
            })
        }
        writeHistory.data = JSON.stringify(history)
        writeHistory.running = true
    }

    function add(notification) {
        if (!notification) return
        popupList.insert(0, { "notification": notification })
        centerList.insert(0, { "notification": notification })
        notification.tracked = true
        saveHistory()
        playNotificationSound()
    }

    function addCenterOnly(notification) {
        if (!notification) return
        centerList.insert(0, { "notification": notification })
        notification.tracked = true
        saveHistory()
    }

    function clearPopup() { popupList.clear() }

    function removePopup(notification) {
        if (!notification) return
        for (var i = 0; i < popupList.count; ++i) {
            var item = popupList.get(i)
            if (item.notification === notification) { popupList.remove(i); return }
        }
    }

    function removeCenter(notification) {
        if (!notification) return
        for (var i = 0; i < centerList.count; ++i) {
            var item = centerList.get(i)
            if (item.notification === notification) {
                centerList.remove(i)
                notification.tracked = false
                saveHistory()
                return
            }
        }
    }

    function clearCenter() {
        for (var i = 0; i < centerList.count; ++i) {
            var item = centerList.get(i)
            if (item.notification) item.notification.tracked = false
        }
        centerList.clear()
        writeHistory.data = "[]"
        writeHistory.running = true
    }

    property bool dndEnabled: false
    property bool soundEnabled: true
    property string notificationSoundFile: "notification.wav"

    readonly property string soundEnabledFile: Quickshell.env("HOME") + "/.config/quickshell/notification-sound-enabled"
    readonly property string soundConfigFile: Quickshell.env("HOME") + "/.config/quickshell/notification-sound"
    readonly property string soundsDir: Quickshell.shellDir + "/sounds/notifications/"

    FileView {
        id: soundEnabledReader
        path: root.soundEnabledFile
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            var value = text().trim() // <-- ИСПРАВЛЕНО: text()
            root.soundEnabled = (value !== "0")
        }
    }

    FileView {
        id: soundConfigReader
        path: root.soundConfigFile
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            var value = text().trim() // <-- ИСПРАВЛЕНО: text()
            if (value !== "") root.notificationSoundFile = value
        }
    }

    function playNotificationSound() {
        if (root.dndEnabled || !root.soundEnabled) return
        var soundPath = root.soundsDir + root.notificationSoundFile
        Quickshell.execDetached(["sh", "-c", "pw-play '" + soundPath + "' 2>/dev/null || paplay '" + soundPath + "' 2>/dev/null || true"])
    }

    Component.onCompleted: { ensureHistory.running = true }
}