import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string soundsDir: Quickshell.shellDir + "/../sounds"
    property bool _debounceActive: false
    
    // === Кэш найденного плеера ===
    property string _player: ""
    property var _playerArgs: []
    property bool _playerReady: false
    
    Timer {
        id: debounceTimer
        interval: 50
        onTriggered: root._debounceActive = false
    }

    // === Асинхронный поиск плеера при старте ===
    Process {
        id: playerFinder
        command: ["sh", "-c", "command -v pw-play && echo pw-play || command -v paplay && echo paplay || command -v canberra-gtk-play && echo canberra-gtk-play || echo none"]
        
        stdout: StdioCollector { id: collector }
        
        // Читаем данные в момент завершения процесса
        onExited: (exitCode) => {
            var found = collector.data ? collector.data.trim() : ""
            if (found === "pw-play") {
                root._player = "pw-play"
                root._playerArgs = ["--volume", "0.5"]
            } else if (found === "paplay") {
                root._player = "paplay"
                root._playerArgs = ["--volume=32768"]
            } else if (found === "canberra-gtk-play") {
                root._player = "canberra-gtk-play"
                root._playerArgs = []
            } else {
                console.warn("[SoundPlayer] No supported audio player found!")
            }
            root._playerReady = true
            console.debug(`[SoundPlayer] Initialized player: ${root._player}`)
        }
        
        Component.onCompleted: start()
    }

    function play(filename) {
        if (!filename || filename === "") return
        
        const fullPath = root.soundsDir + (root.soundsDir.endsWith("/") ? "" : "/") + filename

        try {
            if (root._playerReady && root._player !== "") {
                // 🚀 БЫСТРЫЙ ПУТЬ: Прямой вызов бинарника БЕЗ `sh -c`
                var args = root._playerArgs.slice() 
                args.push(fullPath)
                Quickshell.execDetached([root._player].concat(args))
            } else {
                // 🛡 FALLBACK: Если звук вызван в первые миллисекунды после старта
                const cmd = `pw-play --volume 0.5 '${fullPath}' 2>/dev/null || ` +
                            `paplay --volume=32768 '${fullPath}' 2>/dev/null || ` +
                            `canberra-gtk-play -f '${fullPath}' 2>/dev/null`
                Quickshell.execDetached(["sh", "-c", cmd])
            }
        } catch(e) {
            console.warn("[SoundPlayer] Failed to play", filename, e)
        }
    }

    function playDebounced(filename) {
        if (root._debounceActive) return
        root._debounceActive = true
        debounceTimer.restart()
        play(filename)
    }
}