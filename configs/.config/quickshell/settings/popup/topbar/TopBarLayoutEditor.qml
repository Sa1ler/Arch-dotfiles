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

    // ============================================================
    // DRAG STATE
    // ============================================================
    property string dragWidgetId: ""
    property bool dragging: false
    property real dragX: 0
    property real dragY: 0
    property real pressX: 0
    property real pressY: 0
    property bool dragStarted: false

    property string hoverSection: ""
    property int hoverIndex: -1

    readonly property int dragThreshold: 12

    // ============================================================
    // ЗВУКИ
    // ============================================================
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

    // ============================================================
    // LAYOUT DATA
    // ============================================================
    readonly property var barLayout: root.topbarManager ? root.topbarManager.layout : ({
        "left": [], "center": [], "right": []
    })

    readonly property var leftWidgets: barLayout.left || []
    readonly property var centerWidgets: barLayout.center || []
    readonly property var rightWidgets: barLayout.right || []

    // ============================================================
    // DRAG FUNCTIONS
    // ============================================================
    function handlePress(widgetId, mouseX, mouseY) {
        dragWidgetId = widgetId
        pressX = mouseX
        pressY = mouseY
        dragStarted = false
    }

    function handleMove(mouseX, mouseY) {
        if (dragWidgetId === "") return

        if (!dragStarted) {
            var dx = mouseX - pressX
            var dy = mouseY - pressY
            if (Math.abs(dx) > dragThreshold || Math.abs(dy) > dragThreshold) {
                dragStarted = true
                dragging = true
            }
        }

        if (dragging) {
            dragX = mouseX
            dragY = mouseY
            updateHover(mouseX, mouseY)
        }
    }

    function handleRelease(mouseX, mouseY) {
        if (dragWidgetId === "") return

        if (!dragStarted) {
            root.playClick()
            root.topbarManager.toggleWidget(dragWidgetId)
        } else if (dragging) {
            updateHover(mouseX, mouseY)

            if (hoverSection !== "") {
                root.playClicks()
                root.topbarManager.moveToSection(dragWidgetId, hoverSection, hoverIndex)
            }
        }

        cancelDrag()
    }

    function cancelDrag() {
        dragWidgetId = ""
        dragging = false
        dragStarted = false
        hoverSection = ""
        hoverIndex = -1
    }

    function updateHover(mouseX, mouseY) {
        hoverSection = ""
        hoverIndex = -1

        var sections = [
            { id: "left", item: leftArea },
            { id: "center", item: centerArea },
            { id: "right", item: rightArea }
        ]

        for (var i = 0; i < sections.length; i++) {
            var sec = sections[i]
            var secPos = sec.item.mapToItem(root, 0, 0)

            if (mouseX >= secPos.x && mouseX <= secPos.x + sec.item.width &&
                mouseY >= secPos.y && mouseY <= secPos.y + sec.item.height) {

                hoverSection = sec.id

                var sectionWidgets = getSectionWidgets(sec.id)
                hoverIndex = sectionWidgets.length

                for (var j = 0; j < sectionWidgets.length; j++) {
                    if (sectionWidgets[j] === dragWidgetId) continue

                    var blockItem = getBlockItem(sec.id, j)
                    if (blockItem) {
                        var blockPos = blockItem.mapToItem(root, 0, 0)
                        var blockCenter = blockPos.y + blockItem.height / 2

                        if (mouseY < blockCenter) {
                            hoverIndex = j
                            break
                        }
                    }
                }
                return
            }
        }
    }

    function getSectionWidgets(section) {
        if (section === "left") return leftWidgets
        if (section === "center") return centerWidgets
        if (section === "right") return rightWidgets
        return []
    }

    function getBlockItem(section, index) {
        if (section === "left") return leftRepeater.itemAt(index)
        if (section === "center") return centerRepeater.itemAt(index)
        if (section === "right") return rightRepeater.itemAt(index)
        return null
    }

    // ============================================================
    // CONTENT
    // ============================================================
    implicitHeight: contentCol.implicitHeight

    Column {
        id: contentCol
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        spacing: 0

        Text {
            text: "МАКЕТ ТОПБАРА"
            font.family: "Cascadia Code"
            font.pixelSize: 10
            font.weight: Font.Bold
            font.letterSpacing: 1.5
            color: root.textSec
            width: parent.width
            height: implicitHeight + 8
            verticalAlignment: Text.AlignBottom
        }

        Text {
            text: "Клик — вкл/выкл · Перетаскивание — смена позиции"
            font.family: "Cascadia Code"
            font.pixelSize: 10
            color: root.textSec
            opacity: 0.7
        }

        Item { width: parent.width; height: 16 }

        // ========================================================
        // ТРИ ОБЛАСТИ
        // ========================================================
        Row {
            width: parent.width
            spacing: 12

            // ЛЕВАЯ ОБЛАСТЬ
            Rectangle {
                id: leftArea
                width: (root.width - 24) / 3
                height: leftCol.implicitHeight + 48
                radius: 12

                color: root.hoverSection === "left"
                    ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.06)
                    : Qt.lighter(root.surface, 1.03)

                border.width: root.hoverSection === "left" ? 2 : 1
                border.color: root.hoverSection === "left" ? root.accent : root.border

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                Column {
                    id: leftCol
                    anchors {
                        fill: parent
                        margins: 8
                    }
                    spacing: 6

                    Text {
                        text: "Левая часть"
                        font.family: "Cascadia Code"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: root.textSec
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Repeater {
                        id: leftRepeater
                        model: root.leftWidgets

                        delegate: WidgetBlock {
                            widgetId: modelData
                            section: "left"
                            blockIndex: index
                        }
                    }

                    Item { width: parent.width; height: 4 }
                }
            }

            // ЦЕНТРАЛЬНАЯ ОБЛАСТЬ
            Rectangle {
                id: centerArea
                width: (root.width - 24) / 3
                height: centerCol.implicitHeight + 48
                radius: 12

                color: root.hoverSection === "center"
                    ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.06)
                    : Qt.lighter(root.surface, 1.03)

                border.width: root.hoverSection === "center" ? 2 : 1
                border.color: root.hoverSection === "center" ? root.accent : root.border

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                Column {
                    id: centerCol
                    anchors {
                        fill: parent
                        margins: 8
                    }
                    spacing: 6

                    Text {
                        text: "Центр"
                        font.family: "Cascadia Code"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: root.textSec
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Repeater {
                        id: centerRepeater
                        model: root.centerWidgets

                        delegate: WidgetBlock {
                            widgetId: modelData
                            section: "center"
                            blockIndex: index
                        }
                    }

                    Item { width: parent.width; height: 4 }
                }
            }

            // ПРАВАЯ ОБЛАСТЬ
            Rectangle {
                id: rightArea
                width: (root.width - 24) / 3
                height: rightCol.implicitHeight + 48
                radius: 12

                color: root.hoverSection === "right"
                    ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.06)
                    : Qt.lighter(root.surface, 1.03)

                border.width: root.hoverSection === "right" ? 2 : 1
                border.color: root.hoverSection === "right" ? root.accent : root.border

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                Column {
                    id: rightCol
                    anchors {
                        fill: parent
                        margins: 8
                    }
                    spacing: 6

                    Text {
                        text: "Правая часть"
                        font.family: "Cascadia Code"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: root.textSec
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Repeater {
                        id: rightRepeater
                        model: root.rightWidgets

                        delegate: WidgetBlock {
                            widgetId: modelData
                            section: "right"
                            blockIndex: index
                        }
                    }

                    Item { width: parent.width; height: 4 }
                }
            }
        }

        Item { width: parent.width; height: 32 }
    }

    // ============================================================
    // ПРИЗРАК ПЕРЕТАСКИВАНИЯ
    // ============================================================
    Rectangle {
        id: dragGhost

        visible: root.dragging
        width: 130
        height: 36
        radius: 10

        x: root.dragX - width / 2
        y: root.dragY - height / 2

        color: root.accent
        opacity: 0.9
        scale: 1.05
        z: 2000

        Row {
            anchors.centerIn: parent
            spacing: 6

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.topbarManager ? root.topbarManager.getWidgetInfo(root.dragWidgetId).icon : "?"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 13
                color: root.textSelected
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.topbarManager ? root.topbarManager.getWidgetInfo(root.dragWidgetId).label : ""
                font.family: "Cascadia Code"
                font.pixelSize: 9
                font.weight: Font.Bold
                color: root.textSelected
            }
        }
    }

    // ============================================================
    // ОБЛАСТЬ ПЕРЕТАСКИВАНИЯ (поверх всего)
    // ============================================================
    MouseArea {
        anchors.fill: parent
        enabled: root.dragging
        z: 1500

        preventStealing: true

        onPositionChanged: function(mouse) {
            root.handleMove(mouse.x, mouse.y)
        }

        onReleased: function(mouse) {
            root.handleRelease(mouse.x, mouse.y)
        }

        onCanceled: {
            root.cancelDrag()
        }
    }

    // ============================================================
    // COMPONENT: WIDGET BLOCK
    // ============================================================
    component WidgetBlock: Rectangle {
        id: block

        property string widgetId: ""
        property string section: ""
        property int blockIndex: 0

        readonly property var widgetInfo: root.topbarManager ? root.topbarManager.getWidgetInfo(widgetId) : ({ icon: "?", label: "?" })
        readonly property bool isWidgetEnabled: root.topbarManager ? root.topbarManager.isWidgetEnabled(widgetId) : true
        readonly property bool isDraggingThis: root.dragging && root.dragWidgetId === widgetId

        width: parent.width
        height: 36
        radius: 10

        color: isDraggingThis
            ? "transparent"
            : blockMa.containsMouse
                ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.12)
                : isWidgetEnabled
                    ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.12)
                    : Qt.rgba(0.5, 0.5, 0.5, 0.08)

        border.width: 1
        border.color: isWidgetEnabled
            ? (blockMa.containsMouse ? root.accent : Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.3))
            : (blockMa.containsMouse ? Qt.rgba(0.6, 0.6, 0.6, 0.5) : Qt.rgba(0.5, 0.5, 0.5, 0.15))

        opacity: isDraggingThis ? 0.3 : 1.0

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on opacity { NumberAnimation { duration: 150 } }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: block.widgetInfo.icon
                font.family: "Symbols Nerd Font"
                font.pixelSize: 15
                color: isWidgetEnabled ? root.accent : Qt.rgba(0.5, 0.5, 0.5, 0.6)
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 60
                text: block.widgetInfo.label
                font.family: "Cascadia Code"
                font.pixelSize: 10
                color: isWidgetEnabled ? root.text : Qt.rgba(0.5, 0.5, 0.5, 0.6)
                elide: Text.ElideRight
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: isWidgetEnabled ? "󰄯" : "󰅙"
                font.family: "Symbols Nerd Font"
                font.pixelSize: 12
                color: isWidgetEnabled ? root.accent : Qt.rgba(0.5, 0.5, 0.5, 0.4)
            }
        }

        MouseArea {
            id: blockMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            preventStealing: true

            onPressed: function(mouse) {
                var pos = mapToItem(root, mouse.x, mouse.y)
                root.handlePress(block.widgetId, pos.x, pos.y)
            }

            onPositionChanged: function(mouse) {
                if (pressed) {
                    var pos = mapToItem(root, mouse.x, mouse.y)
                    root.handleMove(pos.x, pos.y)
                }
            }

            onReleased: function(mouse) {
                var pos = mapToItem(root, mouse.x, mouse.y)
                root.handleRelease(pos.x, pos.y)
            }

            onCanceled: {
                root.cancelDrag()
            }
        }
    }
}