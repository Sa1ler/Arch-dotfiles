import QtQuick

Item {
    id: stopwatch
    
    property bool running: false
    property int elapsedSeconds: 0
    
    // Таймер работает даже когда попап закрыт
    Timer {
        interval: 1000
        repeat: true
        running: stopwatch.running
        onTriggered: stopwatch.elapsedSeconds++
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