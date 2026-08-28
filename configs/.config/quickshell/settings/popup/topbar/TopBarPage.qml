import QtQuick
import Quickshell

Item {
    id: root

    property var theme: null
    property var topbarManager: null

    readonly property var colors: root.theme ? root.theme.colors : ({
        "background": "#181818",
        "surface": "#202020",
        "surfaceHover": "#282828",
        "accent": "#3675FF",
        "text": "#FFFFFF",
        "textSecondary": "#A0A0A0",
        "textSelected": "#000000",
        "border": "#303030"
    })

    readonly property color bg: colors.background
    readonly property color surface: colors.surface
    readonly property color surfaceHover: colors.surfaceHover
    readonly property color accent: colors.accent
    readonly property color text: colors.text
    readonly property color textSec: colors.textSecondary
    readonly property color border: colors.border
    readonly property color textSelected: colors.textSelected

    readonly property bool topbarEnabled: root.topbarManager ? root.topbarManager.enabled : true
    readonly property bool attachToEdge: root.topbarManager ? root.topbarManager.attachToEdge : true
    readonly property string barType: root.topbarManager ? root.topbarManager.barType : "common"
    readonly property string positionValue: root.topbarManager ? root.topbarManager.position : "top"
    readonly property bool autoHideEnabled: root.topbarManager ? root.topbarManager.autoHide : false
    readonly property int hideDelayValue: root.topbarManager ? root.topbarManager.hideDelay : 500
    readonly property int barLengthValue: root.topbarManager ? root.topbarManager.barLength : 900 // <-- Добавили readonly
    readonly property int cornerRadiusValue: root.topbarManager ? root.topbarManager.cornerRadius : 12
    readonly property string timeFormatValue: root.topbarManager ? root.topbarManager.timeFormat : "HH:mm"


    property string openedDropdown: ""
    

    readonly property string clickSoundPath: Quickshell.shellDir + "/../generalmenu/sounds/click.wav"
    readonly property string clicksSoundPath: Quickshell.shellDir + "/../generalmenu/sounds/clicks.wav"

    function playClick() {
        Quickshell.execDetached([
            "sh", "-c",
            "pw-play '" + clickSoundPath + "' 2>/dev/null || paplay '" + clickSoundPath + "' 2>/dev/null || true"
        ])
    }

    function playClicks() {
        Quickshell.execDetached([
            "sh", "-c",
            "pw-play '" + clicksSoundPath + "' 2>/dev/null || paplay '" + clicksSoundPath + "' 2>/dev/null || true"
        ])
    }

    function formatMs(ms) {
        if (ms < 1000) return ms + " мс"
        var seconds = ms / 1000
        if (seconds === Math.floor(seconds)) return seconds.toFixed(0) + " с"
        return seconds.toFixed(1) + " с"
    }

    function formatPx(px) {
        return px + " px"
    }

    readonly property var barTypeOptions: [
        { v: "modular", l: "Модульный" },
        { v: "common",  l: "Общий" }
    ]

    readonly property var positionOptions: [
        { v: "top",    l: "Сверху" },
        { v: "bottom", l: "Снизу" },
        { v: "left",   l: "Слева" },
        { v: "right",  l: "Справа" }
    ]

    readonly property var timeFormatOptions: [
        { v: "HH:mm",        l: "ЧЧ:ММ" },
        { v: "HH:mm:ss",     l: "ЧЧ:ММ:СС" },
        { v: "dd.MM HH:mm",  l: "Дата + время" },
        { v: "hh:mm AP",     l: "12-часовой" }
    ]

    function barTypeLabel(v) {
        var item = barTypeOptions.find(function(o) { return o.v === v })
        return item ? item.l : "Общий"
    }

    function positionLabel(v) {
        var item = positionOptions.find(function(o) { return o.v === v })
        return item ? item.l : "Сверху"
    }

    function timeFormatLabel(v) {
        var item = timeFormatOptions.find(function(o) { return o.v === v })
        return item ? item.l : "ЧЧ:ММ"
    }

    Column {
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: 32
            topMargin: 32
        }
        spacing: 6

        Text {
            text: "Топбар"
            font.family: "Cascadia Code"
            font.pixelSize: 26
            font.weight: Font.Bold
            color: root.text
        }

        Text {
            text: "Настройка верхней панели и виджетов"
            font.family: "Cascadia Code"
            font.pixelSize: 13
            color: root.textSec
        }
    }

    Item {
        id: page
        anchors.fill: parent

        Flickable {
            id: contentFlick
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                leftMargin: 32
                rightMargin: 32
                topMargin: 110
                bottomMargin: 32
            }
            clip: true
            contentWidth: width
            contentHeight: contentColumn.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: contentColumn
                width: parent.width
                spacing: 0

                Text {
                    text: "ОТОБРАЖЕНИЕ"
                    font.family: "Cascadia Code"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    font.letterSpacing: 1.5
                    color: root.textSec
                    width: parent.width
                    height: implicitHeight + 32
                    verticalAlignment: Text.AlignBottom
                }

                SettingRow {
                    title: "Показывать топбар"
                    subtitle: "Верхняя панель с виджетами"
                    rowHeight: 44
                    rowEnabled: true

                    SegmentedToggle {
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        value: root.topbarEnabled

                        onToggled: function(val) {
                            root.playClick()
                            if (root.topbarManager) root.topbarManager.setEnabled(val)
                        }
                    }
                }

                Divider {}

                SettingRow {
                    title: "Прикрепить к краю экрана"
                    subtitle: "Панель прилегает к границе экрана"
                    rowHeight: 44
                    rowEnabled: root.topbarEnabled

                    SegmentedToggle {
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        value: root.attachToEdge

                        onToggled: function(val) {
                            root.playClick()
                            if (root.topbarManager) root.topbarManager.setAttachToEdge(val)
                        }
                    }
                }

                Divider {}

                SettingRow {
                    title: "Тип топбара"
                    subtitle: "Стиль отображения панели"
                    rowHeight: 44
                    rowEnabled: root.topbarEnabled

                    DropdownButton {
                        id: barTypeBtn
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 180
                        label: root.barTypeLabel(root.barType)
                        isOpen: root.openedDropdown === "barType"

                        onClicked: {
                            root.playClicks()
                            root.openedDropdown = root.openedDropdown === "barType" ? "" : "barType"
                        }
                    }
                }

                Divider {}

                Text {
                    text: "РАСПОЛОЖЕНИЕ"
                    font.family: "Cascadia Code"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    font.letterSpacing: 1.5
                    color: root.textSec
                    width: parent.width
                    height: implicitHeight + 32
                    verticalAlignment: Text.AlignBottom
                }

                SettingRow {
                    title: "Положение"
                    subtitle: "Расположение панели на экране"
                    rowHeight: 44
                    rowEnabled: root.topbarEnabled

                    DropdownButton {
                        id: positionBtn
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 180
                        label: root.positionLabel(root.positionValue)
                        isOpen: root.openedDropdown === "position"

                        onClicked: {
                            root.playClicks()
                            root.openedDropdown = root.openedDropdown === "position" ? "" : "position"
                        }
                    }
                }

                Divider {}

                Text {
                    text: "ПОВЕДЕНИЕ"
                    font.family: "Cascadia Code"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    font.letterSpacing: 1.5
                    color: root.textSec
                    width: parent.width
                    height: implicitHeight + 32
                    verticalAlignment: Text.AlignBottom
                }

                SettingRow {
                    title: "Автоскрытие"
                    subtitle: "Скрывать панель при бездействии"
                    rowHeight: 44
                    rowEnabled: root.topbarEnabled

                    SegmentedToggle {
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        value: root.autoHideEnabled

                        onToggled: function(val) {
                            root.playClick()
                            if (root.topbarManager) root.topbarManager.setAutoHide(val)
                        }
                    }
                }

                Divider {}

                SettingRow {
                    title: "Задержка скрытия"
                    subtitle: "Время до автоскрытия панели"
                    rowHeight: 70
                    rowEnabled: root.topbarEnabled && root.autoHideEnabled

                    FancySlider {
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 260
                        height: 42
                        enabled: root.topbarEnabled && root.autoHideEnabled

                        minValue: 5
                        maxValue: 5000
                        step: 5
                        value: root.hideDelayValue
                        tooltipText: root.formatMs(root.hideDelayValue)

                        onEdited: function(newValue) {
                            if (root.topbarManager) root.topbarManager.setHideDelay(newValue)
                        }
                    }
                }

                Divider {}

                Text {
                    text: "ВНЕШНИЙ ВИД"
                    font.family: "Cascadia Code"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    font.letterSpacing: 1.5
                    color: root.textSec
                    width: parent.width
                    height: implicitHeight + 32
                    verticalAlignment: Text.AlignBottom
                }

                SettingRow {
                    title: "Длина топбара"
                    subtitle: "Ширина панели в пикселях"
                    rowHeight: 70
                    rowEnabled: root.topbarEnabled

                    FancySlider {
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 260
                        height: 42
                        enabled: root.topbarEnabled

                        minValue: 300
                        maxValue: root.topbarManager ? root.topbarManager.screenMaxWidth : 1920
                        step: 10
                        value: root.barLengthValue
                        tooltipText: root.formatPx(root.barLengthValue)

                        onEdited: function(newValue) {
                            if (root.topbarManager) root.topbarManager.setBarLength(newValue)
                        }
                    }
                }

                Divider {}

            SettingRow {
                    title: "Скругление углов"
                    subtitle: "Радиус закругления панели"
                    rowHeight: 70
                    rowEnabled: root.topbarEnabled

                    FancySlider {
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 260
                        height: 42
                        enabled: root.topbarEnabled

                        minValue: 0
                        maxValue: 32
                        step: 2
                        value: root.cornerRadiusValue
                        tooltipText: root.formatPx(root.cornerRadiusValue)

                        onEdited: function(newValue) {
                            if (root.topbarManager) root.topbarManager.setCornerRadius(newValue)
                        }
                    }
                }

                Divider {}

                SettingRow {
                    title: "Формат времени"
                    subtitle: "Отображение часов в панели"
                    rowHeight: 44
                    rowEnabled: root.topbarEnabled

                    DropdownButton {
                        id: timeFormatBtn
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 180
                        label: root.timeFormatLabel(root.timeFormatValue)
                        isOpen: root.openedDropdown === "timeFormat"

                        onClicked: {
                            root.playClicks()
                            root.openedDropdown = root.openedDropdown === "timeFormat" ? "" : "timeFormat"
                        }
                    }
                }

                Divider {}

                TopBarLayoutEditor {
                    id: layoutEditor
                    width: parent.width
                    theme: root.theme
                    topbarManager: root.topbarManager
                    visible: root.topbarEnabled
                    opacity: root.topbarEnabled ? 1.0 : 0.35
                    enabled: root.topbarEnabled
                }

                Item { width: parent.width; height: 32 }
            }

            WheelHandler {
                property: "vertical"
                onWheel: function(event) {
                    contentFlick.contentY -= event.angleDelta.y * 5
                    contentFlick.returnToBounds()
                    event.accepted = true
                }
            }
        }

        Rectangle {
            visible: contentFlick.contentHeight > contentFlick.height
            width: 4
            radius: 2
            anchors {
                right: parent.right
                rightMargin: 32
                top: contentFlick.top
                bottom: contentFlick.bottom
            }
            color: root.surface

            Rectangle {
                width: parent.width
                radius: width / 2
                height: Math.max(40, parent.height * (contentFlick.height / contentFlick.contentHeight))
                y: (contentFlick.contentHeight > contentFlick.height)
                   ? (contentFlick.contentY / (contentFlick.contentHeight - contentFlick.height)) * (parent.height - height)
                   : 0
                color: root.accent

                Behavior on y {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }
            }
        }

        DropdownList {
            id: barTypeList
            anchorButton: barTypeBtn
            page: page
            options: root.barTypeOptions
            currentValue: root.barType
            isOpen: root.openedDropdown === "barType"

            onSelected: function(value) {
                root.playClick()
                if (root.topbarManager) root.topbarManager.setBarType(value)
                root.openedDropdown = ""
            }
        }

        DropdownList {
            id: positionList
            anchorButton: positionBtn
            page: page
            options: root.positionOptions
            currentValue: root.positionValue
            isOpen: root.openedDropdown === "position"

            onSelected: function(value) {
                root.playClick()
                if (root.topbarManager) root.topbarManager.setPosition(value)
                root.openedDropdown = ""
            }
        }

        DropdownList {
            id: timeFormatList
            anchorButton: timeFormatBtn
            page: page
            options: root.timeFormatOptions
            currentValue: root.timeFormatValue
            isOpen: root.openedDropdown === "timeFormat"

            onSelected: function(value) {
                root.playClick()
                if (root.topbarManager) root.topbarManager.setTimeFormat(value)
                root.openedDropdown = ""
            }
        }

        MouseArea {
            anchors.fill: parent
            visible: root.openedDropdown !== ""
            z: 500
            onClicked: root.openedDropdown = ""
        }
    }

    component SettingRow: Item {
        id: row

        property string title: ""
        property string subtitle: ""
        property int rowHeight: 44
        property bool rowEnabled: true

        width: parent.width
        height: rowHeight
        enabled: rowEnabled
        opacity: rowEnabled ? 1.0 : 0.35

        Behavior on opacity {
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }

        Column {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text: row.title
                font.family: "Cascadia Code"
                font.pixelSize: 13
                font.weight: Font.Medium
                color: root.text
            }

            Text {
                text: row.subtitle
                font.family: "Cascadia Code"
                font.pixelSize: 10
                color: root.textSec
            }
        }
    }

    component Divider: Rectangle {
        width: parent ? parent.width : 0
        height: 1
        color: root.border
        opacity: 0.3
    }

    component DropdownButton: Rectangle {
        id: ddBtn

        property string label: ""
        property bool isOpen: false

        signal clicked()

        width: 180
        height: 32
        radius: 8

        color: ddBtnMa.containsMouse ? Qt.lighter(root.surface, 1.16) : Qt.lighter(root.surface, 1.08)
        border.width: 1
        border.color: ddBtn.isOpen ? root.accent : root.border

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: ddBtn.label
            font.family: "Cascadia Code"
            font.pixelSize: 11
            color: ddBtn.isOpen ? root.accent : root.text

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: "󰅀"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 11
            color: root.textSec
            rotation: ddBtn.isOpen ? 180 : 0

            Behavior on rotation {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
        }

        MouseArea {
            id: ddBtnMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            enabled: ddBtn.enabled
            preventStealing: true
            onClicked: ddBtn.clicked()
        }
    }

    component DropdownList: Rectangle {
        id: ddList

        property var anchorButton: null
        property var page: null
        property var options: []
        property string currentValue: ""
        property bool isOpen: false

        signal selected(string value)

        readonly property int listHeight: options.length * 32 + 8

        width: anchorButton ? anchorButton.width : 180
        height: listHeight

        x: {
            root.openedDropdown
            if (anchorButton && page) {
                return anchorButton.mapToItem(page, 0, 0).x
            }
            return 0
        }

        y: {
            root.openedDropdown
            if (anchorButton && page) {
                var btnPos = anchorButton.mapToItem(page, 0, 0)
                var btnY = btnPos.y

                if (btnY + anchorButton.height + 4 + listHeight > page.height) {
                    return btnY - listHeight - 4
                }
                return btnY + anchorButton.height + 4
            }
            return 0
        }

        radius: 8
        color: root.bg
        border.width: 1
        border.color: root.border

        visible: ddList.isOpen
        opacity: ddList.isOpen ? 1.0 : 0.0
        scale: ddList.isOpen ? 1.0 : 0.96
        transformOrigin: ddList.isOpen ? Item.Top : Item.Bottom

        z: 1000

        Behavior on opacity {
            NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
        }

        Behavior on scale {
            NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
        }

        Column {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 1

            Repeater {
                model: ddList.options

                delegate: Rectangle {
                    required property var modelData

                    width: ddList.width - 8
                    height: 30
                    radius: 6

                    color: optMa.containsMouse
                        ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.1)
                        : "transparent"

                    Behavior on color { ColorAnimation { duration: 100 } }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.l
                        font.family: "Cascadia Code"
                        font.pixelSize: 11
                        color: ddList.currentValue === modelData.v ? root.accent : root.text
                    }

                    Text {
                        visible: ddList.currentValue === modelData.v
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: "✓"
                        font.family: "Cascadia Code"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: root.accent
                    }

                    MouseArea {
                        id: optMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ddList.selected(modelData.v)
                    }
                }
            }
        }
    }

    component SegmentedToggle: Rectangle {
        id: toggle

        property bool value: true
        signal toggled(bool val)

        width: 130
        height: 32
        radius: 8
        color: root.surface
        border.width: 1
        border.color: root.border

        Rectangle {
            id: toggleSlider
            width: parent.width / 2 - 2
            height: parent.height - 4
            y: 2
            x: toggle.value ? 2 : parent.width / 2
            radius: 6
            color: root.accent

            Behavior on x {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
        }

        Row {
            anchors.fill: parent

            Item {
                width: parent.width / 2
                height: parent.height

                Text {
                    anchors.centerIn: parent
                    text: "Вкл"
                    font.family: "Cascadia Code"
                    font.pixelSize: 11
                    font.weight: toggle.value ? Font.Bold : Font.Normal
                    color: toggle.value ? root.textSelected : root.text

                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: toggle.enabled
                    preventStealing: true
                    onClicked: {
                        if (!toggle.value) toggle.toggled(true)
                    }
                }
            }

            Item {
                width: parent.width / 2
                height: parent.height

                Text {
                    anchors.centerIn: parent
                    text: "Выкл"
                    font.family: "Cascadia Code"
                    font.pixelSize: 11
                    font.weight: !toggle.value ? Font.Bold : Font.Normal
                    color: !toggle.value ? root.textSelected : root.text

                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: toggle.enabled
                    preventStealing: true
                    onClicked: {
                        if (toggle.value) toggle.toggled(false)
                    }
                }
            }
        }
    }

    component FancySlider: Item {
        id: sliderRoot

        property int minValue: 0
        property int maxValue: 100
        property int step: 1
        property int value: 0
        property string tooltipText: ""

        property bool dragging: false

        signal edited(int newValue)

        // ============================================================
        // ФИКС "КАРМАНА": Половина ширины ручки (9 пикселей).
        // Это создаст "безопасную зону", чтобы ручка не вылезала за края трека.
        // ============================================================
        readonly property real handlePadding: 9

        readonly property real ratio: {
            var range = maxValue - minValue
            if (range <= 0) return 0
            return Math.max(0, Math.min(1, (value - minValue) / range))
        }

        function valueFromMouse(mouseX) {
            // Вычитаем отступы ручки из доступной ширины трека
            var effectiveWidth = width - handlePadding * 2
            if (effectiveWidth <= 0) return minValue
            
            var r = Math.max(0, Math.min(1, (mouseX - handlePadding) / effectiveWidth))
            var raw = minValue + r * (maxValue - minValue)
            var stepped = Math.round(raw / step) * step
            return Math.max(minValue, Math.min(maxValue, stepped))
        }

        Rectangle {
            id: track
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 6
            radius: 3
            color: root.surface
            border.width: 1
            border.color: root.border
        }

        Rectangle {
            id: fill
            anchors.left: track.left
            anchors.verticalCenter: track.verticalCenter
            // Заполнение теперь доходит ровно до центра ручки
            width: sliderRoot.handlePadding + (track.width - sliderRoot.handlePadding * 2) * sliderRoot.ratio
            height: track.height
            radius: track.radius
            color: root.accent

            Behavior on width {
                NumberAnimation {
                    duration: sliderRoot.dragging ? 0 : 150
                    easing.type: Easing.OutCubic
                }
            }
        }

        Rectangle {
            id: handle
            width: 18
            height: 18
            radius: 9
            // Позиционируем ручку строго в пределах "безопасной зоны"
            x: track.x + sliderRoot.handlePadding + (track.width - sliderRoot.handlePadding * 2) * sliderRoot.ratio - width / 2
            anchors.verticalCenter: track.verticalCenter
            color: root.accent
            border.width: 2
            border.color: root.bg

            scale: sliderArea.pressed ? 1.25 : sliderArea.containsMouse ? 1.1 : 1.0

            Behavior on x {
                NumberAnimation {
                    duration: sliderRoot.dragging ? 0 : 150
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on scale {
                NumberAnimation { duration: 120; easing.type: Easing.OutBack }
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: -5
                radius: parent.radius + 5
                color: "transparent"
                border.width: 2
                border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.3)
                opacity: sliderArea.containsMouse || sliderRoot.dragging ? 1.0 : 0.0

                Behavior on opacity { NumberAnimation { duration: 150 } }
            }
        }

        Rectangle {
            id: tooltip
            width: tooltipTextItem.implicitWidth + 16
            height: 26
            radius: 8
            color: root.accent

            x: Math.max(0, Math.min(sliderRoot.width - width, handle.x + handle.width / 2 - width / 2))
            y: handle.y - 36

            opacity: sliderRoot.dragging || sliderArea.containsMouse ? 1.0 : 0.0
            scale: sliderRoot.dragging || sliderArea.containsMouse ? 1.0 : 0.85
            transformOrigin: Item.Bottom

            Behavior on opacity {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }

            Behavior on scale {
                NumberAnimation { duration: 150; easing.type: Easing.OutBack }
            }

            Rectangle {
                width: 8
                height: 8
                radius: 2
                rotation: 45
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -4
                color: root.accent
            }

            Text {
                id: tooltipTextItem
                anchors.centerIn: parent
                text: sliderRoot.tooltipText
                color: root.textSelected
                font.family: "Cascadia Code"
                font.pixelSize: 11
                font.weight: Font.Bold
            }
        }

        MouseArea {
            id: sliderArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: sliderRoot.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            enabled: sliderRoot.enabled
            preventStealing: true

            onPressed: function(mouse) {
                sliderRoot.dragging = true
                var newValue = sliderRoot.valueFromMouse(mouse.x)
                if (newValue !== sliderRoot.value) {
                    sliderRoot.edited(newValue)
                }
            }

            onPositionChanged: function(mouse) {
                if (!pressed) return
                var newValue = sliderRoot.valueFromMouse(mouse.x)
                if (newValue !== sliderRoot.value) {
                    sliderRoot.edited(newValue)
                }
            }

            onReleased: {
                sliderRoot.dragging = false
            }

            onCanceled: {
                sliderRoot.dragging = false
            }
        }
    }

}