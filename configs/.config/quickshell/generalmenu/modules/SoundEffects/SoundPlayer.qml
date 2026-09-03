import QtQuick
import Quickshell

Item {
    id: root

    // Директория со звуками (теперь можно переопределять извне)
    // По умолчанию указывает на ~/.config/quickshell/sounds/
    property string soundsDir: Quickshell.shellDir + "/../sounds"

    // Дебаунс для частых звуков (ползунки громкости/яркости)
    property bool _debounceActive: false
    
    Timer {
        id: debounceTimer
        interval: 50 // Чуть быстрее отклик, но всё еще спасает от спама звуками
        onTriggered: root._debounceActive = false
    }

    // Обычный звук (для кнопок, уведомлений, открытия/закрытия, смены темы)
    function play(filename) {
        if (!filename || filename === "") return
        
        // Формируем полный путь, проверяя наличие слэша
        const fullPath = root.soundsDir.endsWith("/") ? root.soundsDir + filename : root.soundsDir + "/" + filename

        try {
            // Цепочка fallback: PipeWire -> PulseAudio -> libcanberra
            // Добавили --volume, чтобы звуки были комфортной громкости
            const cmd = `pw-play --volume 0.5 '${fullPath}' 2>/dev/null || ` +
                        `paplay --volume=32768 '${fullPath}' 2>/dev/null || ` +
                        `canberra-gtk-play -f '${fullPath}' 2>/dev/null`
            
            // execDetached не блокирует UI поток
            Quickshell.execDetached(["sh", "-c", cmd])
        } catch(e) {
            console.warn("SoundPlayer: Failed to play", filename, e)
        }
    }

    // Звук с дебаунсом (для ползунков)
    function playDebounced(filename) {
        if (root._debounceActive) return
        root._debounceActive = true
        debounceTimer.restart()
        play(filename)
    }
}