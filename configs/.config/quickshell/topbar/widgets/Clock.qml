import QtQuick
import Quickshell

Item {
    id: root

    property var theme: null
    property var topbarManager: null
    property bool isVertical: false

    readonly property var colors: root.theme ? root.theme.colors : ({
        "background": "#181818",
        "surface": "#202020",
        "surfaceHover": "#282828",
        "accent": "#3675FF",
        "text": "#FFFFFF",
        "textSecondary": "#A0A0A0",
        "textSelected": "#000000"
    })

    readonly property string timeFormat: root.topbarManager ? root.topbarManager.timeFormat : "HH:mm"

    // Определяем, показывать ли секунды
    readonly property bool showSeconds: timeFormat.indexOf("ss") !== -1

    implicitWidth: root.isVertical ? 28 : horizontalClock.implicitWidth
    implicitHeight: root.isVertical ? verticalClock.implicitHeight : 28

    // ============================================================
    // ГОРИЗОНТАЛЬНЫЙ РЕЖИМ
    // ============================================================
    Row {
        id: horizontalClock
        visible: !root.isVertical
        anchors.fill: parent
        spacing: 6

        Text {
            id: timeText
            anchors.verticalCenter: parent.verticalCenter
            font.family: "Cascadia Code"
            font.pixelSize: 13
            font.weight: Font.Medium
            color: root.colors.text

            text: Qt.formatDateTime(new Date(), root.timeFormat)

            Timer {
                interval: 1000
                repeat: true
                running: true
                triggeredOnStart: true
                onTriggered: timeText.text = Qt.formatDateTime(new Date(), root.timeFormat)
            }
        }
    }

    // ============================================================
    // ВЕРТИКАЛЬНЫЙ РЕЖИМ
    // Часы, под ними минуты, под ними секунды (если нужны),
    // под ними день недели, под ним число
    // ============================================================
    Column {
        id: verticalClock
        visible: root.isVertical
        anchors.fill: parent
        spacing: 2

        // Часы
        Text {
            id: vHours
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: "Cascadia Code"
            font.pixelSize: 14
            font.weight: Font.Bold
            color: root.colors.text
            text: Qt.formatDateTime(new Date(), "HH")
        }

        // Минуты
        Text {
            id: vMinutes
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: "Cascadia Code"
            font.pixelSize: 14
            font.weight: Font.Bold
            color: root.colors.text
            text: Qt.formatDateTime(new Date(), "mm")
        }

        // Секунды (если включены в формате)
        Text {
            id: vSeconds
            visible: root.showSeconds
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: "Cascadia Code"
            font.pixelSize: 11
            font.weight: Font.Normal
            color: root.colors.textSecondary
            text: Qt.formatDateTime(new Date(), "ss")
        }

        // Разделитель
        Rectangle {
            width: 16
            height: 1
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.colors.surfaceHover
            visible: root.showSeconds
        }

        // День недели (сокращённо)
        Text {
            id: vDay
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: "Cascadia Code"
            font.pixelSize: 10
            font.weight: Font.Medium
            color: root.colors.textSecondary
            text: Qt.formatDateTime(new Date(), "ddd")
        }

        // Число
        Text {
            id: vDate
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: "Cascadia Code"
            font.pixelSize: 10
            font.weight: Font.Normal
            color: root.colors.textSecondary
            text: Qt.formatDateTime(new Date(), "dd")
        }

        // Таймер для обновления каждую секунду
        Timer {
            interval: 1000
            repeat: true
            running: root.isVertical
            triggeredOnStart: true
            onTriggered: {
                var now = new Date()
                vHours.text = Qt.formatDateTime(now, "HH")
                vMinutes.text = Qt.formatDateTime(now, "mm")
                vSeconds.text = Qt.formatDateTime(now, "ss")
                vDay.text = Qt.formatDateTime(now, "ddd")
                vDate.text = Qt.formatDateTime(now, "dd")
            }
        }
    }
}