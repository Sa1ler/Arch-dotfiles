import QtQuick

Item {
    id: stopwatch
    
    property bool running: false
    property int elapsedSeconds: 0
    
    // === Кэширование форматированного времени ===
    property string formattedTime: formatTime()
    
    Timer {
        interval: 1000
        repeat: true
        running: stopwatch.running
        onTriggered: {
            stopwatch.elapsedSeconds++
            stopwatch.formattedTime = stopwatch.formatTime()
        }
    }
    
    function start() {
        running = true
    }
    
    function stop() {
        running = false
    }
    
    function reset() {
        running = false
        elapsedSeconds = 0
        formattedTime = "00:00"
    }
    
    function getHours() {
        return Math.floor(elapsedSeconds / 3600)
    }
    
    function getMinutes() {
        return Math.floor((elapsedSeconds % 3600) / 60)
    }
    
    function getSeconds() {
        return elapsedSeconds % 60
    }
    
    function formatTime() {
        var m = getMinutes()
        var s = getSeconds()
        return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
    }
}