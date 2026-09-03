import QtQuick

// Часы и дата: обновляются ровно по границе минуты
Item {
    id: clock

    property string currentTime: Qt.formatTime(new Date(), "hh:mm")
    property date today: new Date()

    property int currentDay: today.getDate()
    property int daysInMonth: new Date(today.getFullYear(), today.getMonth() + 1, 0).getDate()
    property string weekdayName: {
        // "ddd" — сокращённый день недели: в русской локали это две буквы
        var name = today.toLocaleDateString(Qt.locale("ru_RU"), "ddd");
        return name.charAt(0).toUpperCase() + name.slice(1);
    }

    function refresh() {
        var now = new Date();
        currentTime = Qt.formatTime(now, "hh:mm");
        today = now;
    }

    // Миллисекунды до начала следующей минуты
    function msUntilNextMinute() {
        var now = new Date();
        return (60 - now.getSeconds()) * 1000 - now.getMilliseconds();
    }

    Timer {
        id: minuteTimer
        running: true
        repeat: false
        interval: clock.msUntilNextMinute()
        onTriggered: {
            clock.refresh();
            minuteTimer.interval = clock.msUntilNextMinute();
            minuteTimer.restart();
        }
    }
}