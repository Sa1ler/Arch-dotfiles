import QtQuick

Item {
    id: root

    property var theme: null
    property var topbarManager: null
    property string sectionFilter: ""
    property bool isVertical: false

    readonly property var colors: root.theme ? root.theme.colors : ({
        "background": "#181818",
        "surface": "#202020",
        "surfaceHover": "#282828",
        "accent": "#3675FF",
        "text": "#FFFFFF",
        "textSecondary": "#A0A0A0",
        "textSelected": "#000000",
        "border": "#303030",
        "separator": "#383838"
    })

    readonly property var barLayout: root.topbarManager ? root.topbarManager.layout : ({
        "left": [], "center": [], "right": []
    })

    // ============================================================
    // ФИЛЬТРАЦИЯ ВИДЖЕТОВ ПО СЕКЦИЯМ
    // ============================================================
    readonly property var leftWidgets: {
        if (root.sectionFilter === "") return barLayout.left || []
        return root.sectionFilter === "left" ? (barLayout.left || []) : []
    }
    
    readonly property var centerWidgets: {
        if (root.sectionFilter === "") return barLayout.center || []
        return root.sectionFilter === "center" ? (barLayout.center || []) : []
    }
    
    readonly property var rightWidgets: {
        if (root.sectionFilter === "") return barLayout.right || []
        return root.sectionFilter === "right" ? (barLayout.right || []) : []
    }

    // ============================================================
    // ЛЕВАЯ ЧАСТЬ — ГОРИЗОНТАЛЬНЫЙ РЕЖИМ
    // ============================================================
    Row {
        id: leftRow
        visible: !root.isVertical && root.leftWidgets.length > 0
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        spacing: 4

        Repeater {
            model: root.leftWidgets
            delegate: WidgetLoader {
                widgetId: modelData
            }
        }
    }

    // ============================================================
    // ЛЕВАЯ ЧАСТЬ — ВЕРТИКАЛЬНЫЙ РЕЖИМ (СТАНОВИТСЯ ВЕРХНЕЙ)
    // ============================================================
    Column {
        id: leftColumn
        visible: root.isVertical && root.leftWidgets.length > 0
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 4

        Repeater {
            model: root.leftWidgets
            delegate: WidgetLoader {
                widgetId: modelData
            }
        }
    }

    // ============================================================
    // ЦЕНТРАЛЬНАЯ ЧАСТЬ — ГОРИЗОНТАЛЬНЫЙ РЕЖИМ
    // ============================================================
    Row {
        id: centerRow
        visible: !root.isVertical && root.centerWidgets.length > 0
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        spacing: 4

        Repeater {
            model: root.centerWidgets
            delegate: WidgetLoader {
                widgetId: modelData
            }
        }
    }

    // ============================================================
    // ЦЕНТРАЛЬНАЯ ЧАСТЬ — ВЕРТИКАЛЬНЫЙ РЕЖИМ
    // ============================================================
    Column {
        id: centerColumn
        visible: root.isVertical && root.centerWidgets.length > 0
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        spacing: 4

        Repeater {
            model: root.centerWidgets
            delegate: WidgetLoader {
                widgetId: modelData
            }
        }
    }

    // ============================================================
    // ПРАВАЯ ЧАСТЬ — ГОРИЗОНТАЛЬНЫЙ РЕЖИМ
    // ============================================================
    Row {
        id: rightRow
        visible: !root.isVertical && root.rightWidgets.length > 0
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        spacing: 4

        Repeater {
            model: root.rightWidgets
            delegate: WidgetLoader {
                widgetId: modelData
            }
        }
    }

    // ============================================================
    // ПРАВАЯ ЧАСТЬ — ВЕРТИКАЛЬНЫЙ РЕЖИМ (СТАНОВИТСЯ НИЖНЕЙ)
    // ============================================================
    Column {
        id: rightColumn
        visible: root.isVertical && root.rightWidgets.length > 0
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 4

        Repeater {
            model: root.rightWidgets
            delegate: WidgetLoader {
                widgetId: modelData
            }
        }
    }

    // ============================================================
    // ЗАГРУЗЧИК ВИДЖЕТОВ
    // ============================================================
    component WidgetLoader: Loader {
        id: widgetLoader

        property string widgetId: ""
        property var theme: root.theme
        property var topbarManager: root.topbarManager
        property bool isVertical: root.isVertical

        active: root.topbarManager ? root.topbarManager.isWidgetEnabled(widgetId) : true
        visible: active

        source: {
            switch (widgetId) {
                case "workspaces": return "widgets/Workspaces.qml"
                case "clock":      return "widgets/Clock.qml"
                case "keyboard":   return "widgets/Keyboard.qml"
                case "wifi":       return "widgets/Wifi.qml"
                case "bluetooth":  return "widgets/Bluetooth.qml"
                case "volume":     return "widgets/Volume.qml"
                case "battery":    return "widgets/Battery.qml"
                case "cpu":        return "widgets/Cpu.qml"
                case "ram":        return "widgets/Ram.qml"
                case "network":    return "widgets/Network.qml"
                default:           return ""
            }
        }

        onLoaded: {
            if (item) {
                item.theme = root.theme
                item.topbarManager = root.topbarManager
                // Передаём isVertical если виджет поддерживает это свойство
                if (item.hasOwnProperty("isVertical")) {
                    item.isVertical = root.isVertical
                }
            }
        }
    }
}