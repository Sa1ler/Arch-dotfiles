import QtQuick

Item {
    id: countdown
    
    property bool running: false
    property bool finished: false
    property int remainingSeconds: 0
    property bool paused: false
    
    // Выставленные значения (когда не запущен)
    property int setHours: 0
    property int setMinutes: 5
    property int setSeconds: 0
    
    // === Кэширование форматированного времени ===
    property string formattedTime: "05:00"
    property string formattedFullTime: "00:05:00"
    
    Timer {
        interval: 1000
        repeat: true
        running: countdown.running && countdown.remainingSeconds > 0
        onTriggered: {
            countdown.remainingSeconds--
            countdown.formattedTime = countdown.formatTime()
            countdown.formattedFullTime = countdown.formatFullTime()
            
            if (countdown.remainingSeconds <= 0) {
                countdown.remainingSeconds = 0
                countdown.running = false
                countdown.paused = false
                countdown.finished = true
            }
        }
    }
    
    function start() {
        if (remainingSeconds === 0) {
            remainingSeconds = setHours * 3600 + setMinutes * 60 + setSeconds
            formattedTime = formatTime()
            formattedFullTime = formatFullTime()
        }
        if (remainingSeconds > 0) {
            running = true
            paused = false
            finished = false
        }
    }
    
    function pause() {
        if (running) {
            running = false
            paused = true
        }
    }
    
    function reset() {
        running = false
        paused = false
        finished = false
        remainingSeconds = 0
        formattedTime = "05:00"
        formattedFullTime = "00:05:00"
    }
    
    function dismiss() {
        finished = false
    }
    
    function getHours() {
        return Math.floor(remainingSeconds / 3600)
    }
    
    function getMinutes() {
        return Math.floor((remainingSeconds % 3600) / 60)
    }
    
    function getSeconds() {
        return remainingSeconds % 60
    }
    
    function formatTime() {
        var m = getMinutes()
        var s = getSeconds()
        return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
    }
    
    function formatFullTime() {
        var h = getHours()
        var m = getMinutes()
        var s = getSeconds()
        return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
    }
    
    // Увеличить/уменьшить разряды
    function incrementHours() { setHours = (setHours + 1) % 24 }
    function decrementHours() { setHours = (setHours - 1 + 24) % 24 }
    function incrementMinutes() { setMinutes = (setMinutes + 1) % 60 }
    function decrementMinutes() { setMinutes = (setMinutes - 1 + 60) % 60 }
    function incrementSeconds() { setSeconds = (setSeconds + 1) % 60 }
    function decrementSeconds() { setSeconds = (setSeconds - 1 + 60) % 60 }
}