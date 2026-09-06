import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root

    property var usageRanks: ({})
    property string usageRanksPath: Quickshell.shellDir + "/usage-ranks.json"

    FileView {
        id: usageRanksFile
        path: root.usageRanksPath
        watchChanges: false
        atomicWrites: true
        printErrors: false
        
        onLoaded: {
            try {
                var text = usageRanksFile.text().trim()
                if (text !== "") {
                    root.usageRanks = JSON.parse(text)
                }
            } catch(e) {
                console.warn("Failed to parse usage ranks:", e)
            }
        }
    }

    function saveUsageRanks() {
        try {
            usageRanksFile.setText(JSON.stringify(root.usageRanks))
        } catch(e) {
            console.warn("Failed to save usage ranks:", e)
        }
    }

    function logLaunch(appName) {
        if (!root.usageRanks[appName]) {
            root.usageRanks[appName] = 0
        }
        root.usageRanks[appName]++
        saveUsageRanks()
    }

    IpcHandler {
        target: "launcher"
        
        function launchApp(appName: string, execCmd: string) {
            root.logLaunch(appName)
            Quickshell.execDetached(["sh", "-c", execCmd])
            console.log("Launched:", appName)
        }
    }
}