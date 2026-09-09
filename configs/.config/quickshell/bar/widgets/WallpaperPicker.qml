import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null
    property var soundManager: null
    property bool active: false
    property var wallpaperList: []
    property int currentIndex: 0
    property bool isFirstChange: true
    
    readonly property color surfaceColor: root.theme && root.theme.colors ? root.theme.colors.surface : "#1A1F26"
    readonly property color textColor: root.theme && root.theme.colors ? root.theme.colors.text : "#FFFFFF"
    readonly property color accentColor: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
    readonly property color textSecondaryColor: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#AAAAAA"
    
    signal close()

    Process {
        id: loadWallpapers
        command: ["sh", "-c", "find ~/.config/hypr/walls/ -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \\) 2>/dev/null | sort"]
        stdout: StdioCollector {
            onStreamFinished: {
                var files = text.trim().split('\n').filter(function(f) { return f.length > 0 })
                root.wallpaperList = files
            }
        }
    }

    onActiveChanged: {
        if (active) {
            isFirstChange = true
            if (wallpaperList.length === 0) {
                loadWallpapers.running = true
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
        text: "Wallpapers"
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
        model: root.wallpaperList
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
            // === ИЗМЕНЕНО: Прямоугольная карточка (шире и ниже) ===
            width: pathView.width * 0.63
            height: pathView.height * 0.90
            
            property bool isCurrent: PathView.isCurrentItem
            
            scale: PathView.itemScale !== undefined ? PathView.itemScale : 0.55
            opacity: PathView.itemOpacity !== undefined ? PathView.itemOpacity : 0.35
            z: PathView.itemZ !== undefined ? PathView.itemZ : 0
            
            Rectangle {
                id: card
                anchors.fill: parent
                radius: 16
                color: "#2A2A35"
                border.width: isCurrent ? 2 : 1
                border.color: isCurrent ? root.accentColor : Qt.rgba(1, 1, 1, 0.15)
                
                Behavior on border.width { NumberAnimation { duration: 180 } }
                Behavior on border.color { ColorAnimation { duration: 180 } }
                
                Item {
                    id: imageContainer
                    anchors.fill: parent
                    anchors.margins: 2
                    
                    Image {
                        id: wallpaperImage
                        anchors.fill: parent
                        source: modelData.indexOf("file://") === 0 ? modelData : "file://" + modelData
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        smooth: true
                        sourceSize.width: delegateItem.width
                        sourceSize.height: delegateItem.height
                        
                        onStatusChanged: {
                            if (status === Image.Error) {
                                console.warn("[WallpaperPicker] Failed to load:", source)
                            }
                        }
                    }
                    
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: imageContainer.width
                            height: imageContainer.height
                            radius: 14
                        }
                    }
                    
                    // Градиент снизу
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 44
                        
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.5; color: Qt.rgba(0, 0, 0, 0.5) }
                            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.85) }
                        }
                        
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            text: {
                                var name = modelData
                                var lastSlash = name.lastIndexOf('/')
                                if (lastSlash !== -1) name = name.substring(lastSlash + 1)
                                return name
                            }
                            color: "#FFFFFF"
                            font.pixelSize: 12
                            font.bold: true
                            font.family: "JetBrains Mono"
                            elide: Text.ElideRight
                            opacity: isCurrent ? 1 : 0.5
                            Behavior on opacity { NumberAnimation { duration: 180 } }
                        }
                    }
                }
                
                MouseArea {
                    id: cardMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (isCurrent) {
                            var fileName = modelData
                            var lastSlash = fileName.lastIndexOf('/')
                            if (lastSlash !== -1) fileName = fileName.substring(lastSlash + 1)
                            Quickshell.execDetached(["qs", "-c", "wallpaper", "ipc", "call", "wallpaper", "applyWallpaper", fileName])
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
            model: Math.min(root.wallpaperList.length, 15)
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
        if (wallpaperList.length > 0) {
            var fileName = wallpaperList[currentIndex]
            var lastSlash = fileName.lastIndexOf('/')
            if (lastSlash !== -1) fileName = fileName.substring(lastSlash + 1)
            Quickshell.execDetached(["qs", "-c", "wallpaper", "ipc", "call", "wallpaper", "applyWallpaper", fileName])
            if (soundManager) soundManager.play("quick_click.wav")
            close()
        }
    }
}