import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    ListModel { id: popupList }
    property var popupNotifications: popupList
    
    ListModel { id: centerList }
    property var centerNotifications: centerList

    readonly property string historyFile: Quickshell.shellDir + "/../notification-history.json"
    
    // Дебаунс сохранения
    property bool savePending: false

    Process {
        id: ensureHistory
        command: ["sh", "-c", 
            "FILE='" + root.historyFile + "'; " +
            "if [ ! -f \"$FILE\" ]; then printf '%s' '[]' > \"$FILE\"; fi"
        ]
    }

    Process {
        id: writeHistory
        property string data: "[]"
        command: ["sh", "-c", 
            "printf '%s' '" + data.replace(/'/g, "'\\''") + "' > '" + root.historyFile + "'"
        ]
        onExited: root.savePending = false
    }

    // Дебаунс: сохраняем не чаще чем раз в 500мс
    Timer {
        id: saveTimer
        interval: 500
        repeat: false
        onTriggered: {
            if (!root.savePending) return
            
            var history = []
            for (var i = 0; i < centerList.count; ++i) {
                var item = centerList.get(i)
                var notification = item.notification
                if (!notification) continue
                history.push({
                    appName: notification.appName || "Notification",
                    summary: notification.summary || "",
                    body: notification.body || "",
                    urgency: notification.urgency || 1,
                    timestamp: Date.now()
                })
            }
            
            writeHistory.data = JSON.stringify(history)
            writeHistory.running = true
        }
    }

    function scheduleSave() {
        root.savePending = true
        saveTimer.restart()
    }

    function add(notification) {
        if (!notification) return
        popupList.insert(0, { notification: notification })
        centerList.insert(0, { notification: notification })
        notification.tracked = true
        scheduleSave()
    }

    function addCenterOnly(notification) {
        if (!notification) return
        centerList.insert(0, { notification: notification })
        notification.tracked = true
        scheduleSave()
    }

    function clearPopup() {
        popupList.clear()
    }

    function removePopup(notification) {
        if (!notification) return
        for (var i = 0; i < popupList.count; ++i) {
            if (popupList.get(i).notification === notification) {
                popupList.remove(i)
                return
            }
        }
    }

    function removeCenter(notification) {
        if (!notification) return
        for (var i = 0; i < centerList.count; ++i) {
            if (centerList.get(i).notification === notification) {
                centerList.remove(i)
                notification.tracked = false
                scheduleSave()
                return
            }
        }
    }

    function clearCenter() {
        for (var i = 0; i < centerList.count; ++i) {
            var notification = centerList.get(i).notification
            if (notification) notification.tracked = false
        }
        centerList.clear()
        writeHistory.data = "[]"
        writeHistory.running = true
    }

    property bool dndEnabled: false

    Component.onCompleted: {
        ensureHistory.running = true
    }
}