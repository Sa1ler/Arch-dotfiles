import QtQuick

Item {
    id: root
    
    property var theme: null
    property date currentTime: new Date()
    
    property int displayYear: currentTime.getFullYear()
    property int displayMonth: currentTime.getMonth()
    
    property int slideDirection: 1
    property bool isAnimating: false
    
    property var dayNamesShort: ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    property var monthNames: ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    
    property bool isCurrentMonth: displayYear === currentTime.getFullYear() && displayMonth === currentTime.getMonth()
    
    implicitWidth: calendarCard.width
    implicitHeight: calendarCard.height
    
    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.currentTime = new Date()
    }
    
    function prevMonth() {
        if (isAnimating) return
        slideDirection = -1
        displayMonth--
        if (displayMonth < 0) {
            displayMonth = 11
            displayYear--
        }
        slideAnimation.start()
    }
    
    function nextMonth() {
        if (isAnimating) return
        slideDirection = 1
        displayMonth++
        if (displayMonth > 11) {
            displayMonth = 0
            displayYear++
        }
        slideAnimation.start()
    }
    
    function goToToday() {
        if (isAnimating) return
        var now = new Date()
        if (now.getFullYear() === displayYear && now.getMonth() === displayMonth) return
        slideDirection = (now.getFullYear() > displayYear || (now.getFullYear() === displayYear && now.getMonth() > displayMonth)) ? 1 : -1
        displayYear = now.getFullYear()
        displayMonth = now.getMonth()
        slideAnimation.start()
    }
    
    function getDaysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate()
    }
    
    function getFirstDayOffset(year, month) {
        return (new Date(year, month, 1).getDay() + 6) % 7
    }
    
    function isToday(day) {
        return day === currentTime.getDate() && displayMonth === currentTime.getMonth() && displayYear === currentTime.getFullYear()
    }
    
    Rectangle {
        id: calendarCard
        width: 280
        height: 320
        radius: 14
        color: root.theme && root.theme.colors ? root.theme.colors.surface : "#1A1F26"
        border.width: 1
        border.color: root.theme && root.theme.colors ? root.theme.colors.border : "#2A2A2A"
        
        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8
            
            // Заголовок
            Row {
                width: parent.width
                spacing: 8
                
                Rectangle {
                    width: 28
                    height: 28
                    radius: 8
                    color: prevMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                    
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "‹"
                        font.pixelSize: 18
                        font.bold: true
                        color: root.theme.colors.text || "#FFF"
                    }
                    
                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.prevMonth()
                    }
                }
                
                Text {
                    width: parent.width - 72
                    height: 28
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: monthNames[displayMonth] + " " + displayYear
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    color: root.theme.colors.text || "#FFF"
                }
                
                Rectangle {
                    width: 28
                    height: 28
                    radius: 8
                    color: nextMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                    
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "›"
                        font.pixelSize: 18
                        font.bold: true
                        color: root.theme.colors.text || "#FFF"
                    }
                    
                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.nextMonth()
                    }
                }
            }
            
            // Дни недели
            Row {
                width: parent.width
                spacing: 4
                
                Repeater {
                    model: dayNamesShort
                    delegate: Text {
                        width: 32
                        height: 20
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: index >= 5 ? (root.theme.colors.accent || "#5B9BFF") : (root.theme.colors.textSecondary || "#AAA")
                    }
                }
            }
            
            // Сетка дней
            Item {
                width: parent.width
                height: 180
                clip: true
                
                Grid {
                    id: prevGrid
                    anchors.fill: parent
                    columns: 7
                    spacing: 4
                    opacity: 0
                    
                    Repeater {
                        model: getFirstDayOffset(displayYear, displayMonth)
                        delegate: Item { width: 32; height: 28 }
                    }
                    
                    Repeater {
                        model: getDaysInMonth(displayYear, displayMonth)
                        delegate: Rectangle {
                            id: prevDayCell
                            width: 32
                            height: 28
                            radius: 8
                            property int day: index + 1
                            property bool isCurrentDay: isToday(day)
                            
                            color: isCurrentDay ? (root.theme.colors.accent || "#5B9BFF") : "transparent"
                            
                            Text {
                                anchors.centerIn: parent
                                text: prevDayCell.day
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                font.weight: prevDayCell.isCurrentDay ? Font.Black : Font.DemiBold
                                color: {
                                    if (prevDayCell.isCurrentDay) return root.theme.colors.textSelected || "#FFF"
                                    var dow = new Date(displayYear, displayMonth, prevDayCell.day).getDay()
                                    if (dow === 0 || dow === 6) return root.theme.colors.accent || "#5B9BFF"
                                    return root.theme.colors.text || "#FFF"
                                }
                            }
                        }
                    }
                }
                
                Grid {
                    id: daysGrid
                    anchors.fill: parent
                    columns: 7
                    spacing: 4
                    
                    Repeater {
                        model: getFirstDayOffset(displayYear, displayMonth)
                        delegate: Item { width: 32; height: 28 }
                    }
                    
                    Repeater {
                        model: getDaysInMonth(displayYear, displayMonth)
                        delegate: Rectangle {
                            id: dayCell
                            width: 32
                            height: 28
                            radius: 8
                            property int day: index + 1
                            property bool isCurrentDay: isToday(day)
                            property bool isHovered: dayMouse.containsMouse
                            
                            color: {
                                if (isCurrentDay) return root.theme.colors.accent || "#5B9BFF"
                                if (isHovered) return Qt.rgba(1, 1, 1, 0.08)
                                return "transparent"
                            }
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: dayCell.day
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                font.weight: dayCell.isCurrentDay ? Font.Black : Font.DemiBold
                                color: {
                                    if (dayCell.isCurrentDay) return root.theme.colors.textSelected || "#FFF"
                                    var dow = new Date(displayYear, displayMonth, dayCell.day).getDay()
                                    if (dow === 0 || dow === 6) return root.theme.colors.accent || "#5B9BFF"
                                    return root.theme.colors.text || "#FFF"
                                }
                            }
                            
                            MouseArea {
                                id: dayMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }
                
                // Анимация перелистывания
                SequentialAnimation {
                    id: slideAnimation
                    
                    onStarted: root.isAnimating = true
                    
                    ScriptAction {
                        script: {
                            prevGrid.opacity = 0
                            prevGrid.x = -root.slideDirection * daysGrid.width * 1.2
                            prevGrid.scale = 0.9
                            prevGrid.rotation = -root.slideDirection * 3
                        }
                    }
                    
                    ParallelAnimation {
                        SequentialAnimation {
                            ParallelAnimation {
                                NumberAnimation { 
                                    target: daysGrid 
                                    property: "x" 
                                    to: root.slideDirection * daysGrid.width * 1.2 
                                    duration: 280 
                                    easing.type: Easing.InOutCubic 
                                }
                                NumberAnimation { 
                                    target: daysGrid 
                                    property: "opacity" 
                                    to: 0 
                                    duration: 200 
                                }
                                NumberAnimation { 
                                    target: daysGrid 
                                    property: "scale" 
                                    to: 0.92 
                                    duration: 280 
                                    easing.type: Easing.InCubic 
                                }
                                NumberAnimation { 
                                    target: daysGrid 
                                    property: "rotation" 
                                    to: root.slideDirection * 4 
                                    duration: 280 
                                    easing.type: Easing.InCubic 
                                }
                            }
                        }
                        
                        SequentialAnimation {
                            PauseAnimation { duration: 60 }
                            ParallelAnimation {
                                NumberAnimation { 
                                    target: prevGrid 
                                    property: "x" 
                                    to: 0 
                                    duration: 280 
                                    easing.type: Easing.OutBack 
                                    easing.overshoot: 1.15 
                                }
                                NumberAnimation { 
                                    target: prevGrid 
                                    property: "opacity" 
                                    to: 1 
                                    duration: 220 
                                    easing.type: Easing.OutCubic 
                                }
                                NumberAnimation { 
                                    target: prevGrid 
                                    property: "scale" 
                                    to: 1.0 
                                    duration: 280 
                                    easing.type: Easing.OutBack 
                                    easing.overshoot: 1.1 
                                }
                                NumberAnimation { 
                                    target: prevGrid 
                                    property: "rotation" 
                                    to: 0 
                                    duration: 280 
                                    easing.type: Easing.OutBack 
                                    easing.overshoot: 0.8 
                                }
                            }
                        }
                    }
                    
                    ScriptAction {
                        script: {
                            daysGrid.x = 0
                            daysGrid.opacity = 1
                            daysGrid.scale = 1.0
                            daysGrid.rotation = 0
                        }
                    }
                    
                    onFinished: root.isAnimating = false
                }
            }
            
            // Кнопка "Сегодня"
            Rectangle {
                width: parent.width
                height: 28
                radius: 8
                color: todayMouse.containsMouse ? (root.theme.colors.accent || "#5B9BFF") : Qt.rgba(1, 1, 1, 0.05)
                opacity: root.isCurrentMonth ? 0.4 : 1
                
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on opacity { NumberAnimation { duration: 200 } }
                
                Text {
                    anchors.centerIn: parent
                    text: "Сегодня"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    color: root.theme.colors.text || "#FFF"
                }
                
                MouseArea {
                    id: todayMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: root.isCurrentMonth ? Qt.ArrowCursor : Qt.PointingHandCursor
                    onClicked: {
                        if (!root.isCurrentMonth) root.goToToday()
                    }
                }
            }
        }
    }
}