import QtQuick

Item {
    id: root
    
    width: 400
    height: 380
    
    property int currentMonth: new Date().getMonth()
    property int currentYear: new Date().getFullYear()
    
    property int direction: 1
    property bool animating: false
    
    property int nextMonthValue: currentMonth
    property int nextYearValue: currentYear
    
    property var months: [
        "ЯНВАРЬ",
        "ФЕВРАЛЬ",
        "МАРТ",
        "АПРЕЛЬ",
        "МАЙ",
        "ИЮНЬ",
        "ИЮЛЬ",
        "АВГУСТ",
        "СЕНТЯБРЬ",
        "ОКТЯБРЬ",
        "НОЯБРЬ",
        "ДЕКАБРЬ"
    ]
    
    property var weekDays: [
        "ПН",
        "ВТ",
        "СР",
        "ЧТ",
        "ПТ",
        "СБ",
        "ВС"
    ]
    
    function daysInMonth(m, y) {
        return new Date(y, m + 1, 0).getDate()
    }
    
    function firstDay(m, y) {
        let d = new Date(y, m, 1).getDay()
        return d === 0 ? 6 : d - 1
    }
    
    function prepareNext() {
        nextMonthValue = currentMonth
        nextYearValue = currentYear
        
        if (direction === 1) {
            if (nextMonthValue === 11) {
                nextMonthValue = 0
                nextYearValue++
            } else {
                nextMonthValue++
            }
        } else {
            if (nextMonthValue === 0) {
                nextMonthValue = 11
                nextYearValue--
            } else {
                nextMonthValue--
            }
        }
    }
    
    function nextMonth() {
        if (animating) return
        direction = 1
        slideMonth()
    }
    
    function previousMonth() {
        if (animating) return
        direction = -1
        slideMonth()
    }
    
    function slideMonth() {
        animating = true
        prepareNext()
        
        nextCalendar.month = nextMonthValue
        nextCalendar.year = nextYearValue
        
        nextCalendar.x = direction === 1 ? root.width : -root.width
        nextCalendar.visible = true
        animation.restart()
    }
    
    // Полупрозрачный фон с закругленными краями
    Rectangle {
        anchors.fill: parent
        radius: 22
        color: "#cc15181f"
    }
    
    Item {
        anchors.fill: parent
        anchors.margins: 12
        clip: true
        
        CalendarPage {
            id: currentCalendar
            width: parent.width
            height: parent.height
            month: currentMonth
            year: currentYear
        }
        
        CalendarPage {
            id: nextCalendar
            width: parent.width
            height: parent.height
            visible: false
        }
    }
    
    ParallelAnimation {
        id: animation
        
        NumberAnimation {
            target: currentCalendar
            property: "x"
            to: direction === 1 ? -root.width : root.width
            duration: 250
            easing.type: Easing.OutCubic
        }
        
        NumberAnimation {
            target: nextCalendar
            property: "x"
            to: 0
            duration: 250
            easing.type: Easing.OutCubic
        }
        
        onFinished: {
            currentMonth = nextCalendar.month
            currentYear = nextCalendar.year
            
            currentCalendar.x = 0
            nextCalendar.x = 0
            
            nextCalendar.visible = false
            animating = false
        }
    }
    
    component CalendarPage: Item {
        property int month: 0
        property int year: 2026
        
        Column {
            anchors.fill: parent
            spacing: 8
            
            Row {
                width: parent.width
                height: 30
                spacing: 5
                
                Rectangle {
                    width: 30
                    height: 30
                    radius: 9
                    color: leftButton.containsMouse ? "#3355aaff" : "transparent"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "‹"
                        color: "#55aaff"
                        font.pixelSize: 24
                    }
                    
                    MouseArea {
                        id: leftButton
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            root.previousMonth()
                        }
                    }
                }
                
                Text {
                    width: parent.width - 70
                    height: 30
                    text: months[month] + " " + year
                    color: "#dddddd"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 13
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                Rectangle {
                    width: 30
                    height: 30
                    radius: 9
                    color: rightButton.containsMouse ? "#3355aaff" : "transparent"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "›"
                        color: "#55aaff"
                        font.pixelSize: 24
                    }
                    
                    MouseArea {
                        id: rightButton
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            root.nextMonth()
                        }
                    }
                }
            }
            
            Grid {
                width: parent.width
                columns: 7
                spacing: 4
                
                Repeater {
                    model: weekDays
                    
                    Text {
                        width: 28
                        height: 18
                        text: modelData
                        color: "#777777"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 10
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
                
                Repeater {
                    model: 42
                    
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 8
                        
                        property int day: index - firstDay(month, year) + 1
                        
                        visible: day > 0 && day <= daysInMonth(month, year)
                        
                        color: hoverArea.containsMouse ? "#3355aaff" : "transparent"
                        
                        Rectangle {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            radius: 8
                            visible: day === new Date().getDate() &&
                                     month === new Date().getMonth() &&
                                     year === new Date().getFullYear()
                            color: "#55aaff"
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: day
                            color: day === new Date().getDate() &&
                                   month === new Date().getMonth() &&
                                   year === new Date().getFullYear() ?
                                   "#111111" : "#dddddd"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 11
                            font.bold: true
                        }
                        
                        MouseArea {
                            id: hoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                        }
                    }
                }
            }
        }
    }
}
