import QtQuick

Item {
    id: root

    property var topbarManager: null
    property bool hidden: false
    property bool mouseInside: false

    signal hideRequested()
    signal showRequested()

    readonly property bool autoHideActive: root.topbarManager ? root.topbarManager.autoHide && root.topbarManager.enabled : false

    // ============================================================
    // ТАЙМЕР АВТОСКРЫТИЯ
    // ============================================================
    Timer {
        id: autoHideTimer

        interval: root.topbarManager ? root.topbarManager.hideDelay : 500
        repeat: false

        onTriggered: {
            if (root.autoHideActive && !root.mouseInside) {
                root.hidden = true
                root.hideRequested()
            }
        }
    }

    // ============================================================
    // РЕАКЦИЯ НА ИЗМЕНЕНИЕ НАСТРОЕК
    // ============================================================
    Connections {
        target: root.topbarManager

        function onAutoHideChanged() {
            if (!root.topbarManager.autoHide) {
                // Автоскрытие выключено — показываем панель
                root.hidden = false
                root.showRequested()
                autoHideTimer.stop()
            } else {
                // Автоскрытие включено — запускаем таймер, если мышь не внутри
                if (!root.mouseInside) {
                    autoHideTimer.restart()
                }
            }
        }

        function onEnabledChanged() {
            if (!root.topbarManager.enabled) {
                root.hidden = false
                autoHideTimer.stop()
            }
        }

        function onHideDelayChanged() {
            // Если таймер запущен, перезапускаем с новым интервалом
            if (autoHideTimer.running) {
                autoHideTimer.restart()
            }
        }
    }

    // ============================================================
    // ПУБЛИЧНЫЕ МЕТОДЫ (вызываются из shell.qml)
    // ============================================================
    function onMouseEntered() {
        root.mouseInside = true
        autoHideTimer.stop()

        if (root.hidden && root.autoHideActive) {
            root.hidden = false
            root.showRequested()
        }
    }

    function onMouseExited() {
        root.mouseInside = false

        if (root.autoHideActive && !root.hidden) {
            autoHideTimer.restart()
        }
    }

    function onMouseMoved() {
        // Мышь двигается внутри панели — сбрасываем таймер
        if (root.autoHideActive && !root.hidden) {
            autoHideTimer.stop()
        }
    }

    function forceShow() {
        root.hidden = false
        autoHideTimer.stop()
    }

    function forceHide() {
        if (root.autoHideActive) {
            root.hidden = true
            root.hideRequested()
        }
    }

    // ============================================================
    // ИНИЦИАЛИЗАЦИЯ
    // ============================================================
    Component.onCompleted: {
        if (root.autoHideActive && !root.mouseInside) {
            autoHideTimer.start()
        }
    }
}