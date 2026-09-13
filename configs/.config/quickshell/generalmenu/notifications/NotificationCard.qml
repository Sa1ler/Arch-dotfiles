import QtQuick
import Quickshell

Item {
    id: root

    property var notification: null
    property var theme: null
    property var soundPlayer: null
    property bool autoClose: true
    property real closeHeight: 0
    property bool closing: false
    property bool hovered: hoverArea.containsMouse
    property string slideDirection: "right"

    signal closed()

    width: 380
    height: closing ? closeHeight : card.height
    opacity: 0

    // === Определение категории из hints ===
    readonly property string category: {
        if (!notification || !notification.hints) return ""
        try {
            return notification.hints.category || notification.hints["category"] || ""
        } catch(e) { return "" }
    }
    
    readonly property int urgency: notification ? notification.urgency : 1
    readonly property bool isCritical: urgency === 2
    readonly property bool isLowPriority: urgency === 0
    
    // === Умный подбор иконки по категории (расширенный) ===
    readonly property string typeIcon: {
        // Медиа
        if (category.indexOf("music") !== -1) return "󰎆"
        if (category.indexOf("video") !== -1) return "󰕼"
        if (category.indexOf("media") !== -1) return "󰎇"
        
        // Сообщения
        if (category.indexOf("im") !== -1) return "󰍡"
        if (category.indexOf("message") !== -1) return "󰍡"
        if (category.indexOf("chat") !== -1) return "󰭹"
        if (category.indexOf("email") !== -1) return "󰇮"
        if (category.indexOf("mail") !== -1) return "󰇮"
        
        // Устройства
        if (category.indexOf("device.added") !== -1) return "󰐱"
        if (category.indexOf("device.removed") !== -1) return "󰋙"
        if (category.indexOf("device") !== -1) return "󰐱"
        if (category.indexOf("usb") !== -1) return "󰐱"
        if (category.indexOf("bluetooth") !== -1) return "󰂯"
        
        // Сеть
        if (category.indexOf("network.connected") !== -1) return "󰖩"
        if (category.indexOf("network.disconnected") !== -1) return "󰖪"
        if (category.indexOf("network") !== -1) return "󰖩"
        if (category.indexOf("wifi") !== -1) return "󰖩"
        
        // Питание
        if (category.indexOf("battery.low") !== -1) return "󰂃"
        if (category.indexOf("battery.full") !== -1) return "󰁹"
        if (category.indexOf("battery") !== -1) return "󰁹"
        if (category.indexOf("power") !== -1) return "󰚥"
        
        // Система
        if (category.indexOf("system.update") !== -1) return "󰚑"
        if (category.indexOf("system") !== -1) return "󰒓"
        if (category.indexOf("update") !== -1) return "󰚑"
        
        // Передача файлов
        if (category.indexOf("transfer.complete") !== -1) return "󰄴"
        if (category.indexOf("transfer") !== -1) return "󰈷"
        if (category.indexOf("download") !== -1) return "󰇚"
        if (category.indexOf("upload") !== -1) return "󰕛"
        
        // Скриншоты и камера
        if (category.indexOf("screenshot") !== -1) return "󰄀"
        if (category.indexOf("camera") !== -1) return "󰄀"
        if (category.indexOf("microphone") !== -1) return "󰍬"
        
        // Звук
        if (category.indexOf("volume") !== -1) return "󰕾"
        if (category.indexOf("sound") !== -1) return "󰕾"
        
        // Календарь и напоминания
        if (category.indexOf("calendar") !== -1) return "󰃭"
        if (category.indexOf("reminder") !== -1) return "󰥔"
        if (category.indexOf("alarm") !== -1) return "󰀪"
        
        // Безопасность
        if (category.indexOf("security") !== -1) return "󰒪"
        if (category.indexOf("auth") !== -1) return "󰌆"
        if (category.indexOf("password") !== -1) return "󰌆"
        
        // Погода
        if (category.indexOf("weather") !== -1) return "󰖙"
        
        // Принтер
        if (category.indexOf("printer") !== -1) return "󰐪"
        
        // Локация
        if (category.indexOf("location") !== -1) return "󰆤"
        
        // По приоритету (если категория не определена)
        if (isCritical) return "󰀨"
        if (isLowPriority) return "󰈣"
        return "󰂚"
    }
    
    // === Цвет по типу ===
    readonly property color typeColor: {
        if (isCritical) return "#FF453A"
        if (isLowPriority) return "#8E8E93"
        if (category.indexOf("power") !== -1 || category.indexOf("battery") !== -1) return "#32D74B"
        if (category.indexOf("network") !== -1 || category.indexOf("wifi") !== -1) return "#0A84FF"
        if (category.indexOf("music") !== -1 || category.indexOf("media") !== -1) return "#FF2D55"
        if (category.indexOf("email") !== -1 || category.indexOf("im") !== -1) return "#5E5CE6"
        if (category.indexOf("security") !== -1 || category.indexOf("auth") !== -1) return "#FF9F0A"
        return theme ? theme.colors.accent : "#5B9BFF"
    }
    
    // === Кэшированные данные ===
    readonly property string appName: notification ? (notification.appName || "Notification") : ""
    readonly property string summary: notification ? (notification.summary || "") : ""
    readonly property string body: notification ? (notification.body || "") : ""
    readonly property bool hasBody: body !== ""
    
    readonly property color surfaceColor: theme ? theme.colors.surface : "#202020"
    readonly property color textColor: theme ? theme.colors.text : "#FFFFFF"
    readonly property color textSecColor: theme ? theme.colors.textSecondary : "#A0A0A0"

    function closeCard() {
        if (closing) return
        if (soundPlayer) soundPlayer.play("tick.wav")
        closeHeight = height
        closing = true
        expireTimer.stop()
        closeAnimation.start()
    }

    Component.onCompleted: {
        appear.start()
        if (autoClose && notification) {
            var timeout = notification.expireTimeout > 0 
                ? notification.expireTimeout * 1000 
                : 5000
            expireTimer.interval = timeout
            expireTimer.start()
        }
    }

    // === Таймер автозакрытия ===
    Timer {
        id: expireTimer
        repeat: false
        onTriggered: {
            if (root.closing) return
            if (root.hovered) {
                restart()
                return
            }
            root.closeCard()
        }
    }

    // === Анимации появления/закрытия ===
    readonly property bool isVertical: slideDirection === "up" || slideDirection === "down"
    readonly property real slideOffset: (slideDirection === "left" || slideDirection === "up") ? -80 : 80

    Translate { id: slide }
    transform: slide

    ParallelAnimation {
        id: appear
        NumberAnimation { 
            target: root
            property: "opacity"
            from: 0
            to: 1
            duration: 220
            easing.type: Easing.OutCubic 
        }
        NumberAnimation {
            target: slide
            property: isVertical ? "y" : "x"
            from: slideOffset
            to: 0
            duration: 280
            easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: closeAnimation
        NumberAnimation { 
            target: root
            property: "opacity"
            from: 1
            to: 0
            duration: 220
            easing.type: Easing.InCubic 
        }
        NumberAnimation {
            target: slide
            property: isVertical ? "y" : "x"
            from: 0
            to: slideOffset
            duration: 260
            easing.type: Easing.InCubic
        }
        NumberAnimation { 
            target: root
            property: "closeHeight"
            from: root.closeHeight
            to: 0
            duration: 260
            easing.type: Easing.InCubic 
        }
        onFinished: root.closed()
    }

    // === ОСНОВНАЯ КАРТОЧКА (оригинальный дизайн) ===
    Rectangle {
        id: card
        width: parent.width
        height: contentRow.implicitHeight + 24
        radius: 18
        color: surfaceColor
        border.width: 1
        border.color: hovered ? Qt.lighter(typeColor, 1.15) : Qt.rgba(typeColor.r, typeColor.g, typeColor.b, 0.28)
        
        Behavior on border.color { ColorAnimation { duration: 180 } }

        // Внутренняя подсветка
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.width: 1
            border.color: typeColor
            opacity: hovered ? 0.16 : 0.06
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        Row {
            id: contentRow
            anchors { 
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 12 
            }
            spacing: 10

            // === Иконка типа (оригинальный вид) ===
            Rectangle {
                id: typeBox
                width: 42
                height: 42
                radius: 12
                color: Qt.rgba(typeColor.r, typeColor.g, typeColor.b, 0.10)
                border.width: 1
                border.color: Qt.rgba(typeColor.r, typeColor.g, typeColor.b, hovered ? 0.65 : 0.32)
                
                Behavior on border.color { ColorAnimation { duration: 180 } }

                Text {
                    anchors.centerIn: parent
                    text: typeIcon
                    color: typeColor
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 20
                    font.bold: true
                }

                // Индикатор
                Rectangle {
                    width: 5
                    height: 5
                    radius: 2.5
                    anchors { 
                        right: parent.right
                        bottom: parent.bottom
                        rightMargin: 5
                        bottomMargin: 5 
                    }
                    color: typeColor
                }
            }

            // === Контент справа ===
            Column {
                id: textColumn
                width: parent.width - typeBox.width - parent.spacing
                spacing: 4

                // Название приложения
                Text {
                    width: parent.width
                    text: appName
                    color: textSecColor
                    font.family: "Cascadia Code"
                    font.pixelSize: 10
                    font.bold: true
                    elide: Text.ElideRight
                }
                
                // === НОВОЕ: Категория ===
                Text {
                    width: parent.width
                    visible: category !== ""
                    text: category.replace(/[._]/g, " ")
                    color: Qt.rgba(typeColor.r, typeColor.g, typeColor.b, 0.75)
                    font.family: "Cascadia Code"
                    font.pixelSize: 8
                    font.letterSpacing: 0.3
                    elide: Text.ElideRight
                }

                // Заголовок
                Text {
                    width: parent.width
                    text: summary
                    color: textColor
                    font.family: "Cascadia Code"
                    font.pixelSize: 14
                    font.bold: true
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                // Тело уведомления
                Text {
                    width: parent.width
                    visible: hasBody
                    text: body
                    color: textSecColor
                    font.family: "Cascadia Code"
                    font.pixelSize: 11
                    wrapMode: Text.Wrap
                    maximumLineCount: 4
                    elide: Text.ElideRight
                }

                // Действия
                NotificationActions {
                    width: parent.width
                    notification: root.notification
                    theme: root.theme
                    visible: !root.closing
                    enabled: !root.closing
                    onActionTriggered: root.closeCard()
                }
            }
        }

        // === Кнопка закрытия ===
        Rectangle {
            id: closeButton
            anchors { 
                top: parent.top
                right: parent.right
                topMargin: 8
                rightMargin: 8 
            }
            width: 22
            height: 22
            radius: 11
            color: closeArea.containsMouse 
                ? Qt.rgba(textColor.r, textColor.g, textColor.b, 0.15) 
                : Qt.rgba(textColor.r, textColor.g, textColor.b, 0.07)

            Text {
                anchors.centerIn: parent
                text: "×"
                color: textColor
                font.family: "Cascadia Code"
                font.pixelSize: 16
            }

            MouseArea {
                id: closeArea
                anchors.fill: parent
                hoverEnabled: true
                onPressed: root.closeCard()
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}