import QtQuick

Item {
    id: root
    
    property var theme: null
    property date currentTime: new Date()
    
    property int displayYear: currentTime.getFullYear()
    property int displayMonth: currentTime.getMonth()
    
    property int slideDirection: 1
    property bool isAnimating: false
    
    // === Кэширование цветов темы ===
    readonly property color surfaceColor: root.theme && root.theme.colors ? root.theme.colors.surface : "#1A1F26"
    readonly property color textColor: root.theme && root.theme.colors ? root.theme.colors.text : "#FFFFFF"
    readonly property color textSelectedColor: root.theme && root.theme.colors ? root.theme.colors.textSelected : "#FFFFFF"
    readonly property color textSecondaryColor: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#AAAAAA"
    readonly property color accentColor: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
    readonly property color borderColor: root.theme && root.theme.colors ? root.theme.colors.border : "#2A2A2A"
    
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
        color: root.surfaceColor
        border.width: 1
        border.color: root.borderColor
        
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
                    scale: prevMouse.containsMouse ? 1.08 : 1.0
                    
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuart } }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "‹"
                        font.pixelSize: 18
                        font.bold: true
                        color: root.textColor
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
                    font.family: "JetBrains Mono"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: root.textColor
                }
                
                Rectangle {
                    width: 28
                    height: 28
                    radius: 8
                    color: nextMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                    scale: nextMouse.containsMouse ? 1.08 : 1.0
                    
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuart } }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "›"
                        font.pixelSize: 18
                        font.bold: true
                        color: root.textColor
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
                        font.family: "JetBrains Mono"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: index >= 5 ? root.accentColor : root.textSecondaryColor
                    }
                }
            }
            
            // Сетка дней
            Item {
                width: parent.width
                height: 180
                clip: true
                
                // Предыдущая сетка (для анимации)
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
                            color: isCurrentDay ? root.accentColor : "transparent"
                            
                            Text {
                                anchors.centerIn: parent
                                text: prevDayCell.day
                                font.family: "JetBrains Mono"
                                font.pixelSize: 12
                                font.weight: prevDayCell.isCurrentDay ? Font.Black : Font.DemiBold
                                color: {
                                    if (prevDayCell.isCurrentDay) return root.textSelectedColor
                                    var dow = new Date(displayYear, displayMonth, prevDayCell.day).getDay()
                                    if (dow === 0 || dow === 6) return root.accentColor
                                    return root.textColor
                                }
                            }
                        }
                    }
                }
                
                // Текущая сетка
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
                                if (isCurrentDay) return root.accentColor
                                if (isHovered) return Qt.rgba(1, 1, 1, 0.08)
                                return "transparent"
                            }
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: dayCell.day
                                font.family: "JetBrains Mono"
                                font.pixelSize: 12
                                font.weight: dayCell.isCurrentDay ? Font.Black : Font.DemiBold
                                color: {
                                    if (dayCell.isCurrentDay) return root.textSelectedColor
                                    var dow = new Date(displayYear, displayMonth, dayCell.day).getDay()
                                    if (dow === 0 || dow === 6) return root.accentColor
                                    return root.textColor
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
                
                // === УПРОЩЁННАЯ анимация перелистывания ===
                // Убраны rotation и scale (замедляли рендеринг) — только x + opacity
                SequentialAnimation {
                    id: slideAnimation
                    
                    onStarted: root.isAnimating = true
                    
                    ScriptAction {
                        script: {
                            prevGrid.opacity = 0
                            prevGrid.x = -root.slideDirection * daysGrid.width * 1.2
                        }
                    }
                    
                    ParallelAnimation {
                        // Старая сетка уезжает
                        NumberAnimation { 
                            target: daysGrid 
                            property: "x" 
                            to: root.slideDirection * daysGrid.width * 1.2 
                            duration: 260 
                            easing.type: Easing.InQuart 
                        }
                        NumberAnimation { 
                            target: daysGrid 
                            property: "opacity" 
                            to: 0 
                            duration: 180 
                        }
                    }
                    
                    ScriptAction {
                        script: {
                            daysGrid.x = 0
                            daysGrid.opacity = 0
                        }
                    }
                    
                    ParallelAnimation {
                        // Новая сетка въезжает
                        NumberAnimation { 
                            target: prevGrid 
                            property: "x" 
                            to: 0 
                            duration: 300 
                            easing.type: Easing.OutQuart 
                        }
                        NumberAnimation { 
                            target: prevGrid 
                            property: "opacity" 
                            to: 1 
                            duration: 280 
                            easing.type: Easing.OutQuart 
                        }
                    }
                    
                    ScriptAction {
                        script: {
                            daysGrid.opacity = 1
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
                color: todayMouse.containsMouse && !root.isCurrentMonth ? root.accentColor : Qt.rgba(1, 1, 1, 0.05)
                opacity: root.isCurrentMonth ? 0.4 : 1
                scale: todayMouse.containsMouse && !root.isCurrentMonth ? 1.02 : 1.0
                
                Behavior on color { ColorAnimation { duration: 180 } }
                Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutQuart } }
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuart } }
                
                Text {
                    anchors.centerIn: parent
                    text: "Сегодня"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: root.textColor
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