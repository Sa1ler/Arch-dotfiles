import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    property var theme: null
    property var themeManager: null

    // ============================================================
    // ЗВУКИ
    // ============================================================
    readonly property string clicksSoundPath: Quickshell.shellDir + "/../generalmenu/sounds/click.wav"

    function playClicks() {
        Quickshell.execDetached([
            "sh", "-c",
            "pw-play '" + clicksSoundPath + "' 2>/dev/null || paplay '" + clicksSoundPath + "' 2>/dev/null || true"
        ])
    }

    function hexToHsl(hex) {
        if (!hex || typeof hex !== "string" || hex.length !== 7) return { h: 0, s: 0, l: 0.5 }
        try {
            let r = parseInt(hex.substring(1, 3), 16) / 255
            let g = parseInt(hex.substring(3, 5), 16) / 255
            let b = parseInt(hex.substring(5, 7), 16) / 255
            let max = Math.max(r, g, b), min = Math.min(r, g, b)
            let h, s, l = (max + min) / 2
            if (max === min) {
                h = s = 0
            } else {
                let d = max - min
                s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
                switch (max) {
                    case r: h = (g - b) / d + (g < b ? 6 : 0); break
                    case g: h = (b - r) / d + 2; break
                    case b: h = (r - g) / d + 4; break
                }
                h /= 6
            }
            return { h: h * 360, s: s, l: l }
        } catch(e) {
            return { h: 0, s: 0, l: 0.5 }
        }
    }

    function getLuminance(hexColor) {
        if (!hexColor || typeof hexColor !== "string" || hexColor.length !== 7) return 0.5
        try {
            let r = parseInt(hexColor.substring(1, 3), 16) / 255
            let g = parseInt(hexColor.substring(3, 5), 16) / 255
            let b = parseInt(hexColor.substring(5, 7), 16) / 255
            return 0.2126 * r + 0.7152 * g + 0.0722 * b
        } catch(e) {
            return 0.5
        }
    }

    function getHueGroup(accentHex) {
        let hsl = hexToHsl(accentHex)
        if (hsl.s < 0.15) return 9
        let h = hsl.h
        if (h < 20 || h >= 340) return 0
        if (h < 50) return 1
        if (h < 150) return 2
        if (h < 200) return 3
        if (h < 260) return 4
        if (h < 320) return 5
        return 6
    }

    property var allThemes: (root.themeManager && root.themeManager.themes) ? root.themeManager.themes : []

    property var groupedThemes: {
        if (allThemes.length === 0) return []

        let sorted = [...allThemes].sort((a, b) => {
            let accentA = a.colors?.accent || "#3675FF"
            let accentB = b.colors?.accent || "#3675FF"
            let hueA = getHueGroup(accentA)
            let hueB = getHueGroup(accentB)
            if (hueA !== hueB) return hueA - hueB
            let lumA = getLuminance(a.colors?.background || "#181818")
            let lumB = getLuminance(b.colors?.background || "#181818")
            return lumA - lumB
        })

        let groups = []
        let currentHue = null
        let currentGroup = []

        for (let theme of sorted) {
            let accent = theme.colors?.accent || "#3675FF"
            let hue = getHueGroup(accent)
            if (hue !== currentHue) {
                if (currentGroup.length > 0) groups.push(currentGroup)
                currentHue = hue
                currentGroup = [theme]
            } else {
                currentGroup.push(theme)
            }
        }

        if (currentGroup.length > 0) groups.push(currentGroup)
        return groups
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
            text: "Темы оформления"
            font.family: "Cascadia Code"
            font.pixelSize: 26
            font.weight: Font.Bold
            // Защита от null
            color: root.theme && root.theme.colors ? root.theme.colors.text : "#FFFFFF"
        }

        Text {
            text: "Выберите тему. Изменения применяются мгновенно."
            font.family: "Cascadia Code"
            font.pixelSize: 13
            // Защита от null
            color: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#AAAAAA"
        }
    }

    Flickable {
        id: flickableArea
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            topMargin: 100
            leftMargin: 32
            rightMargin: 16
            bottomMargin: 32
        }
        clip: true
        contentWidth: width
        contentHeight: contentColumn.implicitHeight
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: contentColumn
            width: parent.width
            spacing: 40

            Repeater {
                model: root.groupedThemes

                delegate: Item {
                    width: parent.width
                    implicitHeight: themeGrid.implicitHeight

                    GridLayout {
                        id: themeGrid
                        width: parent.width
                        columns: 3
                        rowSpacing: 12
                        columnSpacing: 12

                        Repeater {
                            model: modelData

                            delegate: ThemeCard {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 52
                                themeName: modelData.name
                                isSelected: root.themeManager && root.themeManager.currentTheme === modelData.file
                                bgColor: modelData.colors.background
                                surfaceColor: modelData.colors.surface
                                accentColor: modelData.colors.accent
                                textColor: modelData.colors.text

                                onClicked: {
                                    root.playClicks()
                                    if (root.themeManager) {
                                        root.themeManager.loadTheme(modelData.file)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            visible: flickableArea.contentHeight > flickableArea.height
            width: 4
            radius: 2
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
            // Защита от null
            color: root.theme && root.theme.colors ? root.theme.colors.surface : "#202020"

            Rectangle {
                width: parent.width
                radius: width / 2
                height: Math.max(40, parent.height * (flickableArea.height / flickableArea.contentHeight))
                y: (flickableArea.contentHeight > flickableArea.height)
                   ? (flickableArea.contentY / (flickableArea.contentHeight - flickableArea.height)) * (parent.height - height)
                   : 0
                // Защита от null
                color: root.theme && root.theme.colors ? root.theme.colors.accent : "#3675FF"

                Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
            }
        }

        WheelHandler {
            property: "vertical"
            onWheel: function(event) {
                flickableArea.contentY -= event.angleDelta.y * 5
                flickableArea.returnToBounds()
                event.accepted = true
            }
        }
    }
}