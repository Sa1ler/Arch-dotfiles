import QtQuick
import Quickshell
import Quickshell.Io

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

    Component.onCompleted: { ensureHistory.running = true }
}