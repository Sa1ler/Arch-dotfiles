import QtQuick
import Quickshell

// Динамический остров: чистый морф капсулы в плашку.
// Окно никогда не ресайзится. Верх плашки делается ровным не заплаткой,
// а тем, что скруглённые верхние углы утоплены за верхний край экрана.
PanelWindow {
    id: island

    // --- Состояние ----------------------------------------------------
    property bool expanded: false

    // --- Анимация -------------------------------------------------------
    property int animDuration: 450

    // --- Капсула ----------------------------------------------------------
    property int capsuleWidth: 125
    property int capsuleHeight: 35
    property int screenGap: 4        // отступ от верхнего края экрана, px
    property int windowGap: -4       // отступ окон от низа капсулы, px

    // --- Плашка -------------------------------------------------------------
    property int panelWidth: 360
    property int panelHeight: 112

    // Радиус скругления — общий и для капсулы, и для низа плашки
    readonly property int shapeRadius: capsuleHeight / 2

    // --- layer-shell -----------------------------------------------------------
    exclusiveZone: island.screenGap + island.capsuleHeight + island.windowGap
    anchors.top: true
    margins.top: 0

    // Размер окна ПОСТОЯННЫЙ — ресайза нет вообще
    implicitWidth: island.panelWidth
    implicitHeight: island.panelHeight

    color: "transparent"

    // Если твоя сборка знает mask — раскомментируй, клики мимо капсулы
    // перестанут проглатываться. Ругнётся — просто убери строку.
    // mask: Qt.rect(shape.x, shape.y, shape.width, shape.height)

    // --- Морфящаяся фигура -------------------------------------------------
    Rectangle {
        id: shape
        x: island.expanded ? 0 : (island.panelWidth - island.capsuleWidth) / 2

        // Раскрытый вид: уезжаем вверх на радиус, чтобы скруглённые
        // верхние углы оказались за экраном, а видимый верх стал ровным
        y: island.expanded ? -island.shapeRadius : island.screenGap

        width: island.expanded ? island.panelWidth : island.capsuleWidth

        // Компенсируем уход за экран, чтобы видимая высота была panelHeight
        height: island.expanded
            ? island.panelHeight + island.shapeRadius
            : island.capsuleHeight

        radius: island.shapeRadius
        color: "#000000"
        antialiasing: true

        Behavior on x      { PropertyAnimation { duration: island.animDuration; easing.type: Easing.InOutCubic } }
        Behavior on y      { PropertyAnimation { duration: island.animDuration; easing.type: Easing.InOutCubic } }
        Behavior on width  { PropertyAnimation { duration: island.animDuration; easing.type: Easing.InOutCubic } }
        Behavior on height { PropertyAnimation { duration: island.animDuration; easing.type: Easing.InOutCubic } }

        // Наведение — строго по силуэту
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: island.expanded = true
            onExited: island.expanded = false
        }
    }
}