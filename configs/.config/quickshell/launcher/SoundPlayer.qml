import QtQuick
import Quickshell

Item {
    id: root

    property string soundsDir: Quickshell.shellDir + "/../sounds"
    property bool _debounceActive: false
    
    Timer {
        id: debounceTimer
        interval: 50
        onTriggered: root._debounceActive = false
    }

    function play(filename) {
        if (!filename || filename === "") return
        
        const fullPath = root.soundsDir.endsWith("/") ? root.soundsDir + filename : root.soundsDir + "/" + filename

        try {
            const cmd = `pw-play --volume 0.5 '${fullPath}' 2>/dev/null || ` +
                        `paplay --volume=32768 '${fullPath}' 2>/dev/null || ` +
                        `canberra-gtk-play -f '${fullPath}' 2>/dev/null`
            
            Quickshell.execDetached(["sh", "-c", cmd])
        } catch(e) {
            console.warn("LauncherSoundPlayer: Failed to play", filename, e)
        }
    }

    function playDebounced(filename) {
        if (root._debounceActive) return
        root._debounceActive = true
        debounceTimer.restart()
        play(filename)
    }
}