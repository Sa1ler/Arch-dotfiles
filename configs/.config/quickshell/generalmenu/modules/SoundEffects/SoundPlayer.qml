import QtQuick
import Quickshell

Item {
    id: root

    // Базовая директория со звуками
    readonly property string soundsDir: Quickshell.shellDir + "/sounds/"

    // Дебаунс для частых звуков (ползунки)
    property bool _debounceActive: false
    Timer {
        id: debounceTimer
        interval: 80
        onTriggered: root._debounceActive = false
    }

    // Обычный звук (для кнопок)
    function play(filename) {
        try {
            let cmd = "pw-play '" + root.soundsDir + filename + "' 2>/dev/null || paplay '" + root.soundsDir + filename + "' 2>/dev/null || canberra-gtk-play -f '" + root.soundsDir + filename + "' 2>/dev/null"
            Quickshell.execDetached(["sh", "-c", cmd])
        } catch(e) {}
    }

    // Звук с дебаунсом (для ползунков)
    function playDebounced(filename) {
        if (root._debounceActive) return
        root._debounceActive = true
        debounceTimer.restart()
        play(filename)
    }
}