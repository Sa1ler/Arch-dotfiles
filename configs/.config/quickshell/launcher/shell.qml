import QtQuick
import Quickshell
import Quickshell.Io

import "panel"

ShellRoot {
    id: root

    property var appList: []
    property var usageRanks: ({})
    property string usageRanksPath: Quickshell.shellDir + "/usage-ranks.json"

    ThemeManager {
        id: themeManager
    }

    SoundPlayer {
        id: soundManager
        soundsDir: Quickshell.shellDir + "/../sounds"
    }

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

    function playWindowSound(isOpen) {
        if (isOpen) {
            soundManager.play("list.wav")
        } else {
            soundManager.play("sfx.wav")
        }
    }

    IpcHandler {
        target: "launcher"
        
        function toggle() {
            var willOpen = !launcherWindow.windowVisible
            launcherWindow.windowVisible = willOpen
            
            if (willOpen && root.appList.length === 0) {
                loadApps.running = true
            }
            
            playWindowSound(willOpen)
        }
    }

    Process {
        id: loadApps
        command: ["sh", "-c", "for f in /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop; do [ -f \"$f\" ] && name=$(grep -m1 '^Name=' \"$f\" 2>/dev/null | cut -d= -f2-) && [ -n \"$name\" ] && nodisplay=$(grep -m1 '^NoDisplay=' \"$f\" 2>/dev/null | cut -d= -f2-) && [ \"$nodisplay\" != \"true\" ] && exec_cmd=$(grep -m1 '^Exec=' \"$f\" 2>/dev/null | cut -d= -f2- | sed 's/%[uUfFdD]//g') && icon=$(grep -m1 '^Icon=' \"$f\" 2>/dev/null | cut -d= -f2-) && echo \"$name|$icon|$exec_cmd\"; done 2>/dev/null | sort -u"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split('\n').filter(l => l.length > 0)
                var apps = []
                var unique = {}
                
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split('|')
                    if (parts.length >= 3 && parts[0] !== "") {
                        var appName = parts[0]
                        if (unique[appName]) continue
                        unique[appName] = true
                        
                        var usageScore = root.usageRanks[appName] || 0
                        
                        apps.push({
                            name: appName,
                            icon: parts[1] || "",
                            exec: parts[2],
                            usageScore: usageScore
                        })
                    }
                }
                
                apps.sort(function(a, b) {
                    if (b.usageScore !== a.usageScore) return b.usageScore - a.usageScore
                    return a.name.localeCompare(b.name)
                })
                
                root.appList = apps
                console.log("Loaded apps:", apps.length)
            }
        }
    }

    LauncherWindow {
        id: launcherWindow
        visible: false
        
        theme: themeManager.theme
        appList: root.appList
        soundManager: soundManager
        
        onLaunchApp: function(appName, execCmd) {
            soundManager.play("quick_click.wav")
            root.logLaunch(appName)
            Quickshell.execDetached(["sh", "-c", execCmd])
            launcherWindow.windowVisible = false
        }
    }
}