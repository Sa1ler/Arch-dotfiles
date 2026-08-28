import QtQuick
import Quickshell
import Quickshell.Io
import "behaviors"

ShellRoot {
    id: root

    // ============================================================
    // МЕНЕДЖЕРЫ
    // ============================================================
    ThemeManager { id: themeManager }
    TopBarManager { id: topbarManager }

    property var theme: themeManager.theme

    property bool barVisible: topbarManager.enabled

    readonly property bool isHorizontal: topbarManager.position === "top" || topbarManager.position === "bottom"
    readonly property bool autoHideActive: topbarManager.autoHide && topbarManager.enabled

    readonly property int hiddenSize: 4
    readonly property int currentThickness: autoHideBehavior.hidden ? root.hiddenSize : topbarManager.barHeight

    // Расширение для скругления — максимум 4 пикселя
    readonly property int edgeRadiusOffset: topbarManager.attachToEdge ? Math.min(topbarManager.cornerRadius, -3) : 0

    // ============================================================
    // АВТОСКРЫТИЕ
    // ============================================================
    AutoHide {
        id: autoHideBehavior
        topbarManager: topbarManager

        onHideRequested: {
        }

        onShowRequested: {
        }
    }

    // ============================================================
    // HELPERS
    // ============================================================
    function currentHoverContainsMouse() {
        if (topbarManager.position === "top") return topHoverArea.containsMouse
        if (topbarManager.position === "bottom") return bottomHoverArea.containsMouse
        if (topbarManager.position === "left") return leftHoverArea.containsMouse
        if (topbarManager.position === "right") return rightHoverArea.containsMouse
        return false
    }

    // ============================================================
    // TOP WINDOW
    // ============================================================
    PanelWindow {
        id: topWindow

        visible: root.barVisible && topbarManager.position === "top"

        anchors {
            top: true
            left: true
            right: true
        }

        implicitWidth: 0
        implicitHeight: root.currentThickness + root.edgeRadiusOffset

        exclusiveZone: topbarManager.enabled && !autoHideBehavior.hidden ? topbarManager.barHeight : 0
        color: "transparent"

        TopBarContainer {
            id: topBarContainer

            width: Math.min(topbarManager.barLength, parent.width)
            height: parent.height

            // Привязываем к НИЖНЕМУ краю окна — панель расширяется вверх
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }

            theme: root.theme
            topbarManager: topbarManager
            isVertical: false

            opacity: autoHideBehavior.hidden ? 0 : 1

            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
        }

        MouseArea {
            id: topHoverArea
            anchors.fill: parent
            hoverEnabled: true

            onEntered: autoHideBehavior.onMouseEntered()
            onPositionChanged: autoHideBehavior.onMouseMoved()
            onExited: autoHideBehavior.onMouseExited()
        }
    }

    // ============================================================
    // BOTTOM WINDOW
    // ============================================================
    PanelWindow {
        id: bottomWindow

        visible: root.barVisible && topbarManager.position === "bottom"

        anchors {
            bottom: true
            left: true
            right: true
        }

        implicitWidth: 0
        implicitHeight: root.currentThickness + root.edgeRadiusOffset

        exclusiveZone: topbarManager.enabled && !autoHideBehavior.hidden ? topbarManager.barHeight : 0
        color: "transparent"

        TopBarContainer {
            id: bottomBarContainer

            width: Math.min(topbarManager.barLength, parent.width)
            height: parent.height

            // Привязываем к ВЕРХНЕМУ краю окна — панель расширяется вниз
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }

            theme: root.theme
            topbarManager: topbarManager
            isVertical: false

            opacity: autoHideBehavior.hidden ? 0 : 1

            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
        }

        MouseArea {
            id: bottomHoverArea
            anchors.fill: parent
            hoverEnabled: true

            onEntered: autoHideBehavior.onMouseEntered()
            onPositionChanged: autoHideBehavior.onMouseMoved()
            onExited: autoHideBehavior.onMouseExited()
        }
    }

    // ============================================================
    // LEFT WINDOW
    // ============================================================
    PanelWindow {
        id: leftWindow

        visible: root.barVisible && topbarManager.position === "left"

        anchors {
            top: true
            bottom: true
            left: true
        }

        implicitWidth: root.currentThickness + root.edgeRadiusOffset
        implicitHeight: topbarManager.screenMaxHeight ? topbarManager.screenMaxHeight : 1080

        exclusiveZone: topbarManager.enabled && !autoHideBehavior.hidden ? topbarManager.barHeight : 0
        color: "transparent"

        TopBarContainer {
            id: leftBarContainer

            width: parent.width
            height: Math.min(topbarManager.barLength, parent.height)

            // Привязываем к ПРАВОМУ краю окна — панель расширяется влево
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
            }

            theme: root.theme
            topbarManager: topbarManager
            isVertical: true

            opacity: autoHideBehavior.hidden ? 0 : 1

            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
        }

        MouseArea {
            id: leftHoverArea
            anchors.fill: parent
            hoverEnabled: true

            onEntered: autoHideBehavior.onMouseEntered()
            onPositionChanged: autoHideBehavior.onMouseMoved()
            onExited: autoHideBehavior.onMouseExited()
        }
    }

    // ============================================================
    // RIGHT WINDOW
    // ============================================================
    PanelWindow {
        id: rightWindow

        visible: root.barVisible && topbarManager.position === "right"

        anchors {
            top: true
            bottom: true
            right: true
        }

        implicitWidth: root.currentThickness + root.edgeRadiusOffset
        implicitHeight: topbarManager.screenMaxHeight ? topbarManager.screenMaxHeight : 1080

        exclusiveZone: topbarManager.enabled && !autoHideBehavior.hidden ? topbarManager.barHeight : 0
        color: "transparent"

        TopBarContainer {
            id: rightBarContainer

            width: parent.width
            height: Math.min(topbarManager.barLength, parent.height)

            // Привязываем к ЛЕВОМУ краю окна — панель расширяется вправо
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }

            theme: root.theme
            topbarManager: topbarManager
            isVertical: true

            opacity: autoHideBehavior.hidden ? 0 : 1

            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
        }

        MouseArea {
            id: rightHoverArea
            anchors.fill: parent
            hoverEnabled: true

            onEntered: autoHideBehavior.onMouseEntered()
            onPositionChanged: autoHideBehavior.onMouseMoved()
            onExited: autoHideBehavior.onMouseExited()
        }
    }

    // ============================================================
    // СБРОС СОСТОЯНИЯ ПРИ ИЗМЕНЕНИИ НАСТРОЕК
    // ============================================================
    Connections {
        target: topbarManager

        function onPositionChanged() {
            autoHideBehavior.forceShow()
        }

        function onEnabledChanged() {
            root.barVisible = topbarManager.enabled

            if (!topbarManager.enabled) {
                autoHideBehavior.forceShow()
            }
        }
    }

    // ============================================================
    // IPC
    // ============================================================
    IpcHandler {
        target: "topbar"

        function toggle(): void {
            root.barVisible = !root.barVisible
        }

        function show(): void {
            root.barVisible = true
        }

        function hide(): void {
            root.barVisible = false
        }
    }
}