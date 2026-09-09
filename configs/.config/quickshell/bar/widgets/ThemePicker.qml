import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null
    property var themeManager: null
    property var soundManager: null
    property bool active: false
    property var themesList: []
    property int currentIndex: 0
    property bool isFirstChange: true
    
    readonly property color surfaceColor: root.theme && root.theme.colors ? root.theme.colors.surface : "#1A1F26"
    readonly property color textColor: root.theme && root.theme.colors ? root.theme.colors.text : "#FFFFFF"
    readonly property color accentColor: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
    readonly property color textSecondaryColor: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#AAAAAA"
    
    signal close()

    Process {
        id: loadThemes
        command: ["sh", "-c", "ls -1 ~/.config/quickshell/themes/ 2>/dev/null | grep -iE '\\.json$' | sed 's/\\.json$//' | sort"]
        stdout: StdioCollector {
            onStreamFinished: {
                var files = text.trim().split('\n').filter(function(f) { return f.length > 0 })
                root.themesList = files
                
                if (root.active && root.themeManager && root.themeManager.currentTheme && files.length > 0) {
                    for (var i = 0; i < files.length; i++) {
                        if (files[i] === root.themeManager.currentTheme) {
                            root.currentIndex = i
                            pathView.currentIndex = i
                            break
                        }
                    }
                }
            }
        }
    }

    onActiveChanged: {
        if (active) {
            isFirstChange = true
            if (themesList.length === 0) {
                loadThemes.running = true
            } else if (themeManager && themeManager.currentTheme && themesList.length > 0) {
                for (var i = 0; i < themesList.length; i++) {
                    if (themesList[i] === themeManager.currentTheme) {
                        root.currentIndex = i
                        pathView.currentIndex = i
                        break
                    }
                }
            }
        } else {
            isFirstChange = true
        }
    }

    Text {
        id: title
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 14
        text: "Themes"
        color: root.textColor
        font.pixelSize: 17
        font.bold: true
        opacity: 0.9
    }

    PathView {
        id: pathView
        anchors.top: title.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 8
        anchors.bottomMargin: 40
        anchors.leftMargin: 70
        anchors.rightMargin: 70
        
        clip: true
        model: root.themesList
        pathItemCount: 5
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        highlightMoveDuration: 250
        snapMode: PathView.SnapToItem
        
        path: Path {
            startX: -pathView.width * 0.3
            startY: pathView.height / 2
            
            PathAttribute { name: "itemScale"; value: 0.55 }
            PathAttribute { name: "itemOpacity"; value: 0.35 }
            PathAttribute { name: "itemZ"; value: 0 }
            
            PathLine { x: pathView.width / 2; y: pathView.height / 2 }
            
            PathAttribute { name: "itemScale"; value: 1.0 }
            PathAttribute { name: "itemOpacity"; value: 1.0 }
            PathAttribute { name: "itemZ"; value: 10 }
            
            PathLine { x: pathView.width * 1.3; y: pathView.height / 2 }
            
            PathAttribute { name: "itemScale"; value: 0.55 }
            PathAttribute { name: "itemOpacity"; value: 0.35 }
            PathAttribute { name: "itemZ"; value: 0 }
        }
        
        delegate: Item {
            id: delegateItem
            width: pathView.width * 0.42
            height: pathView.height * 0.85
            
            property bool isCurrent: PathView.isCurrentItem
            
            property var themeData: {
                if (!root.themeManager || !root.themeManager.themes) return null
                for (var i = 0; i < root.themeManager.themes.length; i++) {
                    if (root.themeManager.themes[i].file === modelData) {
                        return root.themeManager.themes[i]
                    }
                }
                return null
            }
            
            property color bgColor: themeData && themeData.colors ? themeData.colors.background : "#181818"
            property color surfColor: themeData && themeData.colors ? themeData.colors.surface : "#1A1F26"
            property color tAccentColor: themeData && themeData.colors ? themeData.colors.accent : "#5B9BFF"
            property color tTextColor: themeData && themeData.colors ? themeData.colors.text : "#FFFFFF"
            property color tTextSecColor: themeData && themeData.colors ? themeData.colors.textSecondary : "#AAAAAA"
            property color tTextSelColor: themeData && themeData.colors ? themeData.colors.textSelected : "#FFFFFF"
            property string themeName: themeData && themeData.name ? themeData.name : modelData
            property bool isCurrentTheme: root.themeManager && root.themeManager.currentTheme === modelData
            
            scale: PathView.itemScale !== undefined ? PathView.itemScale : 0.55
            opacity: PathView.itemOpacity !== undefined ? PathView.itemOpacity : 0.35
            z: PathView.itemZ !== undefined ? PathView.itemZ : 0
            
            Rectangle {
                id: card
                anchors.fill: parent
                radius: 16
                color: surfColor
                border.width: isCurrent ? 2 : 1
                border.color: isCurrent ? tAccentColor : Qt.rgba(1, 1, 1, 0.15)
                
                Behavior on border.width { NumberAnimation { duration: 180 } }
                Behavior on border.color { ColorAnimation { duration: 180 } }
                
                // Превью темы
                Rectangle {
                    id: previewArea
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 12
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    height: parent.height * 0.46
                    radius: 10
                    color: bgColor
                    clip: true
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.1)

                    // Мини топбар
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 20
                        color: surfColor

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Repeater {
                                model: 3
                                delegate: Rectangle {
                                    width: 6
                                    height: 6
                                    radius: 3
                                    color: index === 0 ? tAccentColor : Qt.rgba(1, 1, 1, 0.25)
                                }
                            }
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            text: "12:00"
                            color: tTextColor
                            font.pixelSize: 8
                            font.bold: true
                            font.family: "JetBrains Mono"
                        }
                    }

                    Column {
                        anchors.top: parent.bottom
                        anchors.topMargin: -parent.height + 26
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 9
                        spacing: 5

                        Rectangle {
                            width: parent.width * 0.72
                            height: 8
                            radius: 4
                            color: tTextColor
                            opacity: 0.9
                        }

                        Rectangle {
                            width: parent.width * 0.52
                            height: 6
                            radius: 3
                            color: tTextSecColor
                            opacity: 0.7
                        }

                        Rectangle {
                            width: 44
                            height: 15
                            radius: 7.5
                            color: tAccentColor

                            Text {
                                anchors.centerIn: parent
                                text: "Button"
                                color: tTextSelColor
                                font.pixelSize: 7
                                font.bold: true
                                font.family: "JetBrains Mono"
                            }
                        }
                    }
                }

                // Название темы
                Text {
                    id: themeNameText
                    anchors.top: previewArea.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 8
                    text: themeName
                    color: tTextColor
                    font.pixelSize: 13
                    font.bold: true
                    font.family: "JetBrains Mono"
                }

                // Цветовая палитра
                Row {
                    anchors.top: themeNameText.bottom
                    anchors.topMargin: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 5

                    Repeater {
                        model: themeData && themeData.colors ? 
                               [bgColor, surfColor, tAccentColor, tTextColor] : []
                        delegate: Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: modelData
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.2)
                        }
                    }
                }

                // Плашка статуса
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 10
                    width: currentLabel.width + 20
                    height: 22
                    radius: 11
                    color: isCurrentTheme ? tAccentColor : Qt.rgba(0, 0, 0, 0.4)
                    border.width: isCurrentTheme ? 0 : 1
                    border.color: Qt.rgba(1, 1, 1, 0.15)
                    opacity: isCurrent ? 1 : 0
                    scale: isCurrent ? 1 : 0.9
                    
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    Behavior on scale { NumberAnimation { duration: 200 } }
                    
                    Text {
                        id: currentLabel
                        anchors.centerIn: parent
                        text: isCurrentTheme ? "✓ Current" : "↵ Apply"
                        color: isCurrentTheme ? tTextSelColor : "#FFFFFF"
                        font.pixelSize: 10
                        font.bold: true
                        font.family: "JetBrains Mono"
                    }
                }
                
                MouseArea {
                    id: cardMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (isCurrent) {
                            Quickshell.execDetached(["qs", "-c", "themepicker", "ipc", "call", "themepicker", "applyTheme", modelData])
                            if (root.soundManager) root.soundManager.play("quick_click.wav")
                            root.close()
                        } else {
                            pathView.currentIndex = index
                        }
                    }
                }
            }
        }
        
        onCurrentIndexChanged: {
            root.currentIndex = currentIndex
            if (root.isFirstChange) {
                root.isFirstChange = false
                return
            }
            if (root.soundManager) root.soundManager.play("in.wav")
        }
    }

    // Градиенты по краям
    Rectangle {
        anchors.left: parent.left
        anchors.top: pathView.top
        anchors.bottom: pathView.bottom
        width: 70
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: root.surfaceColor }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }
    
    Rectangle {
        anchors.right: parent.right
        anchors.top: pathView.top
        anchors.bottom: pathView.bottom
        width: 70
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: root.surfaceColor }
        }
    }

    // Стрелка влево
    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 12
        width: 36
        height: 36
        radius: 18
        color: leftMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(0, 0, 0, 0.3)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.1)
        Behavior on color { ColorAnimation { duration: 150 } }
        
        Text {
            anchors.centerIn: parent
            text: "‹"
            color: root.textColor
            font.pixelSize: 28
            font.bold: true
        }
        
        MouseArea {
            id: leftMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: pathView.decrementCurrentIndex()
        }
    }

    // Стрелка вправо
    Rectangle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 12
        width: 36
        height: 36
        radius: 18
        color: rightMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(0, 0, 0, 0.3)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.1)
        Behavior on color { ColorAnimation { duration: 150 } }
        
        Text {
            anchors.centerIn: parent
            text: "›"
            color: root.textColor
            font.pixelSize: 28
            font.bold: true
        }
        
        MouseArea {
            id: rightMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: pathView.incrementCurrentIndex()
        }
    }

    // Индикаторы
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 14
        spacing: 8
        
        Repeater {
            model: Math.min(root.themesList.length, 15)
            delegate: Rectangle {
                property bool isActive: index === root.currentIndex
                width: isActive ? 22 : 6
                height: 6
                radius: 3
                color: isActive ? root.accentColor : root.textSecondaryColor
                opacity: isActive ? 1 : 0.4
                Behavior on width { NumberAnimation { duration: 280; easing.type: Easing.OutQuart } }
                Behavior on opacity { NumberAnimation { duration: 250 } }
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }
    }

    function navigateLeft() { pathView.decrementCurrentIndex() }
    function navigateRight() { pathView.incrementCurrentIndex() }
    
    function applyCurrent() {
        if (themesList.length > 0) {
            var fileName = themesList[currentIndex]
            Quickshell.execDetached(["qs", "-c", "themepicker", "ipc", "call", "themepicker", "applyTheme", fileName])
            if (soundManager) soundManager.play("quick_click.wav")
            close()
        }
    }
}