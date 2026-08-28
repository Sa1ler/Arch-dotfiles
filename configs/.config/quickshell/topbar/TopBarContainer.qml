import QtQuick

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
        "textSelected": "#000000",
        "border": "#303030",
        "separator": "#383838"
    })

    readonly property int cornerRadius: root.topbarManager ? root.topbarManager.cornerRadius : 12
    readonly property bool isAttached: root.topbarManager ? root.topbarManager.attachToEdge : true
    readonly property string position: root.topbarManager ? root.topbarManager.position : "top"
    readonly property string barType: root.topbarManager ? root.topbarManager.barType : "common"

    // ============================================================
    // ВСЕ УГЛЫ ВСЕГДА СКРУГЛЕНЫ
    // При прикреплении к краю панель сдвигается за край экрана,
    // создавая эффект "овала"
    // ============================================================
    readonly property int effectiveRadius: root.cornerRadius

    // ============================================================
    // КОМПОНЕНТ: ПРЯМОУГОЛЬНИК С РАЗНЫМИ РАДИУСАМИ УГЛОВ
    // ============================================================
    component RoundedRectangle: Item {
        id: roundedRect

        property int topLeftRadius: 0
        property int topRightRadius: 0
        property int bottomLeftRadius: 0
        property int bottomRightRadius: 0
        property color fillColor: "transparent"
        property color borderColor: "transparent"
        property int borderWidth: 0

        property int repaintTrigger: 0
        onTopLeftRadiusChanged: repaintTrigger++
        onTopRightRadiusChanged: repaintTrigger++
        onBottomLeftRadiusChanged: repaintTrigger++
        onBottomRightRadiusChanged: repaintTrigger++
        onFillColorChanged: repaintTrigger++
        onBorderColorChanged: repaintTrigger++
        onBorderWidthChanged: repaintTrigger++

        Canvas {
            id: canvas
            anchors.fill: parent
            antialiasing: true
            renderStrategy: Canvas.Cooperative

            property int trigger: roundedRect.repaintTrigger
            onTriggerChanged: requestPaint()
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()

                var w = width
                var h = height
                var tl = Math.min(roundedRect.topLeftRadius, w / 2, h / 2)
                var tr = Math.min(roundedRect.topRightRadius, w / 2, h / 2)
                var bl = Math.min(roundedRect.bottomLeftRadius, w / 2, h / 2)
                var br = Math.min(roundedRect.bottomRightRadius, w / 2, h / 2)

                ctx.beginPath()

                ctx.moveTo(tl, 0)
                ctx.lineTo(w - tr, 0)

                if (tr > 0) {
                    ctx.arcTo(w, 0, w, tr, tr)
                } else {
                    ctx.lineTo(w, 0)
                }

                ctx.lineTo(w, h - br)

                if (br > 0) {
                    ctx.arcTo(w, h, w - br, h, br)
                } else {
                    ctx.lineTo(w, h)
                }

                ctx.lineTo(bl, h)

                if (bl > 0) {
                    ctx.arcTo(0, h, 0, h - bl, bl)
                } else {
                    ctx.lineTo(0, h)
                }

                ctx.lineTo(0, tl)

                if (tl > 0) {
                    ctx.arcTo(0, 0, tl, 0, tl)
                } else {
                    ctx.lineTo(0, 0)
                }

                ctx.closePath()

                ctx.fillStyle = roundedRect.fillColor.toString()
                ctx.fill()

                if (roundedRect.borderWidth > 0) {
                    ctx.strokeStyle = roundedRect.borderColor.toString()
                    ctx.lineWidth = roundedRect.borderWidth
                    ctx.stroke()
                }
            }
        }
    }

    // ============================================================
    // ОБЩИЙ ТИП (COMMON) — единая строка
    // ============================================================
    Item {
        id: commonBar
        
        visible: root.barType === "common"
        
        anchors {
            fill: parent
            // При прикреплении к краю сдвигаем панель за край экрана на величину радиуса
            // Это создаёт эффект "овала", прикреплённого к краю
            topMargin: root.isAttached && root.position === "top" ? -root.effectiveRadius : 4
            bottomMargin: root.isAttached && root.position === "bottom" ? -root.effectiveRadius : 4
            leftMargin: root.isAttached && root.position === "left" ? -root.effectiveRadius : 4
            rightMargin: root.isAttached && root.position === "right" ? -root.effectiveRadius : 4
        }

        RoundedRectangle {
            anchors.fill: parent
            topLeftRadius: root.effectiveRadius
            topRightRadius: root.effectiveRadius
            bottomLeftRadius: root.effectiveRadius
            bottomRightRadius: root.effectiveRadius
            fillColor: root.colors.background
            borderColor: root.colors.border
            borderWidth: 1
        }

        TopBarContent {
            anchors {
                fill: parent
                leftMargin: root.isVertical ? 4 : 12
                rightMargin: root.isVertical ? 4 : 12
                topMargin: root.isVertical ? 12 : 4
                bottomMargin: root.isVertical ? 12 : 4
            }
            theme: root.theme
            topbarManager: root.topbarManager
            isVertical: root.isVertical
        }
    }

    // ============================================================
    // МОДУЛЬНЫЙ ТИП (MODULAR) — ГОРИЗОНТАЛЬНЫЙ РЕЖИМ
    // ============================================================
    Item {
        id: modularHorizontal
        
        visible: root.barType === "modular" && !root.isVertical
        anchors.fill: parent

        // Левый сектор
        Item {
            id: hLeftSector
            
            width: hLeftContent.implicitWidth + 24
            height: parent.height
            
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }

            RoundedRectangle {
                anchors.fill: parent
                topLeftRadius: root.effectiveRadius
                topRightRadius: root.effectiveRadius
                bottomLeftRadius: root.effectiveRadius
                bottomRightRadius: root.effectiveRadius
                fillColor: root.colors.background
                borderColor: root.colors.border
                borderWidth: 1
            }

            TopBarContent {
                id: hLeftContent
                anchors {
                    fill: parent
                    leftMargin: 12
                    rightMargin: 12
                }
                theme: root.theme
                topbarManager: root.topbarManager
                sectionFilter: "left"
                isVertical: false
            }
        }

        // Центральный сектор
        Item {
            id: hCenterSector
            
            width: hCenterContent.implicitWidth + 24
            height: parent.height
            
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                bottom: parent.bottom
            }

            RoundedRectangle {
                anchors.fill: parent
                topLeftRadius: root.effectiveRadius
                topRightRadius: root.effectiveRadius
                bottomLeftRadius: root.effectiveRadius
                bottomRightRadius: root.effectiveRadius
                fillColor: root.colors.background
                borderColor: root.colors.border
                borderWidth: 1
            }

            TopBarContent {
                id: hCenterContent
                anchors {
                    fill: parent
                    leftMargin: 12
                    rightMargin: 12
                }
                theme: root.theme
                topbarManager: root.topbarManager
                sectionFilter: "center"
                isVertical: false
            }
        }

        // Правый сектор
        Item {
            id: hRightSector
            
            width: hRightContent.implicitWidth + 24
            height: parent.height
            
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            RoundedRectangle {
                anchors.fill: parent
                topLeftRadius: root.effectiveRadius
                topRightRadius: root.effectiveRadius
                bottomLeftRadius: root.effectiveRadius
                bottomRightRadius: root.effectiveRadius
                fillColor: root.colors.background
                borderColor: root.colors.border
                borderWidth: 1
            }

            TopBarContent {
                id: hRightContent
                anchors {
                    fill: parent
                    leftMargin: 12
                    rightMargin: 12
                }
                theme: root.theme
                topbarManager: root.topbarManager
                sectionFilter: "right"
                isVertical: false
            }
        }
    }

    // ============================================================
    // МОДУЛЬНЫЙ ТИП (MODULAR) — ВЕРТИКАЛЬНЫЙ РЕЖИМ
    // ============================================================
    Item {
        id: modularVertical
        
        visible: root.barType === "modular" && root.isVertical
        anchors.fill: parent

        // Верхний сектор (левый)
        Item {
            id: vTopSector
            
            width: parent.width
            height: vTopContent.implicitHeight + 24
            
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }

            RoundedRectangle {
                anchors.fill: parent
                topLeftRadius: root.effectiveRadius
                topRightRadius: root.effectiveRadius
                bottomLeftRadius: root.effectiveRadius
                bottomRightRadius: root.effectiveRadius
                fillColor: root.colors.background
                borderColor: root.colors.border
                borderWidth: 1
            }

            TopBarContent {
                id: vTopContent
                anchors {
                    fill: parent
                    leftMargin: 4
                    rightMargin: 4
                    topMargin: 12
                    bottomMargin: 12
                }
                theme: root.theme
                topbarManager: root.topbarManager
                sectionFilter: "left"
                isVertical: true
            }
        }

        // Центральный сектор
        Item {
            id: vCenterSector
            
            width: parent.width
            height: vCenterContent.implicitHeight + 24
            
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }

            RoundedRectangle {
                anchors.fill: parent
                topLeftRadius: root.effectiveRadius
                topRightRadius: root.effectiveRadius
                bottomLeftRadius: root.effectiveRadius
                bottomRightRadius: root.effectiveRadius
                fillColor: root.colors.background
                borderColor: root.colors.border
                borderWidth: 1
            }

            TopBarContent {
                id: vCenterContent
                anchors {
                    fill: parent
                    leftMargin: 4
                    rightMargin: 4
                    topMargin: 12
                    bottomMargin: 12
                }
                theme: root.theme
                topbarManager: root.topbarManager
                sectionFilter: "center"
                isVertical: true
            }
        }

        // Нижний сектор (правый)
        Item {
            id: vBottomSector
            
            width: parent.width
            height: vBottomContent.implicitHeight + 24
            
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }

            RoundedRectangle {
                anchors.fill: parent
                topLeftRadius: root.effectiveRadius
                topRightRadius: root.effectiveRadius
                bottomLeftRadius: root.effectiveRadius
                bottomRightRadius: root.effectiveRadius
                fillColor: root.colors.background
                borderColor: root.colors.border
                borderWidth: 1
            }

            TopBarContent {
                id: vBottomContent
                anchors {
                    fill: parent
                    leftMargin: 4
                    rightMargin: 4
                    topMargin: 12
                    bottomMargin: 12
                }
                theme: root.theme
                topbarManager: root.topbarManager
                sectionFilter: "right"
                isVertical: true
            }
        }
    }
}