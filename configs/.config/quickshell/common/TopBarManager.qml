import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string configPath: Quickshell.shellDir + "/../topbar-config.json"

    // ============================================================
    // ОПРЕДЕЛЕНИЕ РАЗМЕРА МОНИТОРА
    // ============================================================
    readonly property var primaryScreen: {
        var screens = Quickshell.screens
        if (!screens) return null
        
        var len = screens.length !== undefined ? screens.length : (screens.count !== undefined ? screens.count : 0)
        
        // Ищем primary (основной) экран
        for (var i = 0; i < len; i++) {
            var s = screens[i] !== undefined ? screens[i] : (screens.at ? screens.at(i) : null)
            if (s && s.primary) return s
        }
        
        // Если primary не найден, берем первый доступный
        if (len > 0) {
            return screens[0] !== undefined ? screens[0] : (screens.at ? screens.at(0) : null)
        }
        
        return null
    }

    // Динамические максимальные размеры на основе текущего монитора
    // Если экран не найден (редкий кейс при загрузке), используем fallback 1920
    readonly property int screenMaxWidth: primaryScreen ? primaryScreen.width : 1920
    readonly property int screenMaxHeight: primaryScreen ? primaryScreen.height : 1080

    // ============================================================
    // СВОЙСТВА ТОПБАРА
    // ============================================================
    property bool enabled: true
    property bool attachToEdge: true
    property string barType: "common"
    property string position: "top"

    property bool autoHide: false
    property int hideDelay: 500

    property int barLength: 900
    property int cornerRadius: 12
    property string timeFormat: "HH:mm"
    property int barHeight: 36

    // ============================================================
    // МАКЕТ: все виджеты распределены по секциям
    // ============================================================
    property var layout: ({
        "left": ["workspaces"],
        "center": ["clock"],
        "right": ["wifi", "volume", "battery", "keyboard", "bluetooth", "cpu", "ram", "network"]
    })

    property var disabledWidgets: ["bluetooth", "cpu", "ram", "network"]

    readonly property var allWidgets: [
        { id: "workspaces", label: "Рабочие пространства", icon: "󰍜" },
        { id: "clock",      label: "Дата и время",         icon: "󰃭" },
        { id: "keyboard",   label: "Клавиатура",           icon: "󰌌" },
        { id: "wifi",       label: "Wi-Fi",                icon: "󰤨" },
        { id: "bluetooth",  label: "Bluetooth",            icon: "󰂯" },
        { id: "volume",     label: "Звук",                 icon: "󰕾" },
        { id: "battery",    label: "Батарея",              icon: "󰁹" },
        { id: "cpu",        label: "CPU",                  icon: "󰻠" },
        { id: "ram",        label: "Память",               icon: "󰍛" },
        { id: "network",    label: "Сеть",                 icon: "󰈀" }
    ]

    // ============================================================
    // FILE VIEW
    // ============================================================
    FileView {
        id: configFile

        path: root.configPath
        watchChanges: true
        atomicWrites: true
        printErrors: false

        onFileChanged: reload()
        onLoaded: root.parseConfig()
    }

    // ============================================================
    // HELPERS
    // ============================================================
    function clamp(value, minValue, maxValue) {
        if (isNaN(value)) return minValue;
        return Math.max(minValue, Math.min(maxValue, value))
    }

    function getWidgetInfo(widgetId) {
        for (var i = 0; i < allWidgets.length; i++) {
            if (allWidgets[i].id === widgetId) return allWidgets[i]
        }
        return { id: widgetId, label: widgetId, icon: "?" }
    }

    // ============================================================
    // LAYOUT FUNCTIONS
    // ============================================================
    function isWidgetEnabled(widgetId) {
        return disabledWidgets.indexOf(widgetId) === -1
    }

    function toggleWidget(widgetId) {
        var newDisabled = disabledWidgets.slice()
        var idx = newDisabled.indexOf(widgetId)

        if (idx === -1) {
            newDisabled.push(widgetId)
        } else {
            newDisabled.splice(idx, 1)
        }

        disabledWidgets = newDisabled
        saveConfig()
    }

    function getWidgetSection(widgetId) {
        for (var section in layout) {
            if (layout[section].indexOf(widgetId) !== -1) return section
        }
        return ""
    }

    function moveToSection(widgetId, section, index) {
        var newLayout = JSON.parse(JSON.stringify(layout))

        for (var sec in newLayout) {
            var idx = newLayout[sec].indexOf(widgetId)
            if (idx !== -1) newLayout[sec].splice(idx, 1)
        }

        if (newLayout[section] === undefined) newLayout[section] = []

        if (index >= 0 && index <= newLayout[section].length) {
            newLayout[section].splice(index, 0, widgetId)
        } else {
            newLayout[section].push(widgetId)
        }

        layout = newLayout
        saveConfig()
    }

    function reorderInSection(section, fromIndex, toIndex) {
        var newLayout = JSON.parse(JSON.stringify(layout))
        var arr = newLayout[section]

        if (fromIndex < 0 || fromIndex >= arr.length) return
        if (toIndex < 0) toIndex = 0
        if (toIndex > arr.length) toIndex = arr.length

        var widget = arr.splice(fromIndex, 1)[0]
        if (toIndex > fromIndex) toIndex--
        arr.splice(toIndex, 0, widget)

        layout = newLayout
        saveConfig()
    }

    // ============================================================
    // PARSE
    // ============================================================
    function parseConfig() {
        if (!configFile.loaded) return

        try {
            var raw = configFile.text().trim()

            if (raw === "") {
                saveConfig()
                return
            }

            var data = JSON.parse(raw)

            enabled = data.enabled !== undefined ? data.enabled : true
            attachToEdge = data.attachToEdge !== undefined ? data.attachToEdge : true
            barType = data.barType !== undefined ? data.barType : "common"
            position = data.position !== undefined ? data.position : "top"

            autoHide = data.autoHide !== undefined ? data.autoHide : false
            
            var parsedHideDelay = parseInt(data.hideDelay)
            hideDelay = !isNaN(parsedHideDelay) ? clamp(parsedHideDelay, 5, 5000) : 500

            // Адаптивная ширина: если в конфиге сохранилась ширина больше текущего монитора 
            // (например, ты перенес конфиг с ультраширокого монитора на ноутбук), 
            // она автоматически обрежется до ширины текущего экрана!
            var parsedBarLength = parseInt(data.barLength)
            barLength = !isNaN(parsedBarLength) ? clamp(parsedBarLength, 300, screenMaxWidth > 0 ? screenMaxWidth : 1920) : 900

            var parsedCornerRadius = parseInt(data.cornerRadius)
            cornerRadius = !isNaN(parsedCornerRadius) ? clamp(parsedCornerRadius, 0, 32) : 12
            
            timeFormat = data.timeFormat !== undefined ? data.timeFormat : "HH:mm"
            
            var parsedBarHeight = parseInt(data.barHeight)
            barHeight = !isNaN(parsedBarHeight) ? clamp(parsedBarHeight, 20, 96) : 36

            if (data.layout !== undefined) layout = data.layout
            if (data.disabledWidgets !== undefined) disabledWidgets = data.disabledWidgets
        } catch (e) {
            console.warn("TopBarManager: invalid JSON:", e)
            saveConfig()
        }
    }

    // ============================================================
    // SAVE
    // ============================================================
    function saveConfig() {
        var data = {
            "enabled": enabled,
            "attachToEdge": attachToEdge,
            "barType": barType,
            "position": position,
            "autoHide": autoHide,
            "hideDelay": hideDelay,
            "barLength": barLength,
            "cornerRadius": cornerRadius,
            "timeFormat": timeFormat,
            "barHeight": barHeight,
            "layout": layout,
            "disabledWidgets": disabledWidgets
        }

        configFile.setText(JSON.stringify(data, null, 4))
    }

    // ============================================================
    // SETTERS
    // ============================================================
    function setEnabled(value) {
        if (enabled === value) return
        enabled = value
        saveConfig()
    }

    function setAttachToEdge(value) {
        if (attachToEdge === value) return
        attachToEdge = value
        saveConfig()
    }

    function setBarType(value) {
        if (barType === value) return
        barType = value
        saveConfig()
    }

    function setPosition(value) {
        if (position === value) return
        position = value
        saveConfig()
    }

    function setAutoHide(value) {
        if (autoHide === value) return
        autoHide = value
        saveConfig()
    }

    function setHideDelay(value) {
        value = clamp(parseInt(value), 5, 5000)
        if (hideDelay === value) return
        hideDelay = value
        saveConfig()
    }

    function setBarLength(value) {
        // Используем screenMaxWidth с fallback на 1920 если он ещё не определился
        var maxWidth = screenMaxWidth > 0 ? screenMaxWidth : 1920
        value = clamp(parseInt(value), 300, maxWidth)
        if (barLength === value) return
        barLength = value
        saveConfig()
    }

    function setCornerRadius(value) {
        value = clamp(parseInt(value), 0, 32)
        if (cornerRadius === value) return
        cornerRadius = value
        saveConfig()
    }

    function setBarHeight(value) {
        value = clamp(parseInt(value), 20, 96)
        if (barHeight === value) return
        barHeight = value
        saveConfig()
    }

    function setTimeFormat(value) {
        if (timeFormat === value) return
        timeFormat = value
        saveConfig()
    }

    // ============================================================
    // INIT
    // ============================================================
    Process {
        id: ensureConfig

        command: [
            "sh", "-c",
            "if [ ! -f '" + root.configPath + "' ]; then " +
            "printf '%s\n' '{\"enabled\": true}' > '" + root.configPath + "'; " +
            "fi"
        ]

        onExited: configFile.reload()
    }

    Component.onCompleted: {
        ensureConfig.running = true
    }
}