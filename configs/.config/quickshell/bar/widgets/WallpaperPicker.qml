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
    property bool isFirstChange: true  // ← ЗАМЕНИЛО isLoaded
    
    signal close()

    Process {
        id: loadWallpapers
        command: ["sh", "-c", "ls -1 ~/.config/hypr/walls/ 2>/dev/null | grep -iE '\\.(jpg|jpeg|png|webp|gif)$' | sort"]
        stdout: StdioCollector {
            onStreamFinished: {
                var files = text.trim().split('\n').filter(function(f) { return f.length > 0 })
                root.wallpaperList = files
                console.log("Loaded wallpapers:", files.length)
            }
        }
    }

    Process {
        id: applyProcess
        property string fileName: ""
        command: ["qs", "-c", "wallpaper", "ipc", "call", "wallpaper", "applyWallpaper", fileName]
    }

    onActiveChanged: {
        if (active) {
            isFirstChange = true  // ← Сбрасываем при открытии
            
            if (wallpaperList.length === 0) {
                loadWallpapers.running = true
            }
        } else {
            isFirstChange = true  // ← Сбрасываем при закрытии
        }
    }

    // Заголовок
    Text {
        id: title
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 14
        text: "Wallpapers"
        color: root.theme.colors.text || "#FFF"
        font.pixelSize: 17
        font.bold: true
        opacity: 0.9
    }

    // Компактная карусель
    PathView {
        id: pathView
        anchors.top: title.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 8
        anchors.bottomMargin: 36
        anchors.leftMargin: 36
        anchors.rightMargin: 36
        
        clip: true
        
        model: root.wallpaperList
        pathItemCount: 5
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        highlightMoveDuration: 280
        
        path: Path {
            startX: -pathView.width * 0.3
            startY: pathView.height / 2
            
            PathAttribute { name: "itemScale"; value: 0.6 }
            PathAttribute { name: "itemOpacity"; value: 0.3 }
            PathAttribute { name: "itemZ"; value: 0 }
            
            PathLine { x: pathView.width / 2; y: pathView.height / 2 }
            
            PathAttribute { name: "itemScale"; value: 1.0 }
            PathAttribute { name: "itemOpacity"; value: 1.0 }
            PathAttribute { name: "itemZ"; value: 10 }
            
            PathLine { x: pathView.width * 1.3; y: pathView.height / 2 }
            
            PathAttribute { name: "itemScale"; value: 0.6 }
            PathAttribute { name: "itemOpacity"; value: 0.3 }
            PathAttribute { name: "itemZ"; value: 0 }
        }
        
        delegate: Item {
            id: delegateItem
            width: pathView.width * 0.38
            height: pathView.height * 0.8
            
            scale: PathView.itemScale !== undefined ? PathView.itemScale : 0.6
            opacity: PathView.itemOpacity !== undefined ? PathView.itemOpacity : 0.3
            z: PathView.itemZ !== undefined ? PathView.itemZ : 0
            
            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 4
                height: parent.height - 4
                radius: 16
                color: Qt.rgba(0, 0, 0, 0.5)
                y: parent.y + 8
                opacity: PathView.isCurrentItem ? 0.7 : 0.25
            }

            Rectangle {
                id: card
                anchors.fill: parent
                radius: 14
                color: "#2A2A35"
                border.width: PathView.isCurrentItem ? 2 : 1
                border.color: PathView.isCurrentItem ? 
                               (root.theme.colors.accent || "#5B9BFF") : 
                               Qt.rgba(1, 1, 1, 0.15)
                
                Item {
                    id: imageContainer
                    anchors.fill: parent
                    anchors.margins: 2
                    
                    Image {
                        anchors.fill: parent
                        source: "file:///home/graff/.config/hypr/walls/" + modelData
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        smooth: true
                    }
                    
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: imageContainer.width
                            height: imageContainer.height
                            radius: 12
                        }
                    }
                    
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 36
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.8) }
                        }
                        Text {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottomMargin: 6
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            text: modelData
                            color: "#FFF"
                            font.pixelSize: 11
                            font.bold: true
                            elide: Text.ElideRight
                            opacity: PathView.isCurrentItem ? 1 : 0.4
                        }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (PathView.isCurrentItem) {
                            applyProcess.fileName = modelData
                            applyProcess.running = true
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
            
            // Пропускаем первое срабатывание (позиционирование при открытии)
            if (root.isFirstChange) {
                root.isFirstChange = false
                return
            }
            
            if (root.soundManager) {
                root.soundManager.play("in.wav")
            }
        }
    }

    // Градиенты по краям
    Rectangle {
        anchors.left: parent.left
        anchors.top: pathView.top
        anchors.bottom: pathView.bottom
        width: 40
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: root.theme.colors.surface }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }
    
    Rectangle {
        anchors.right: parent.right
        anchors.top: pathView.top
        anchors.bottom: pathView.bottom
        width: 40
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: root.theme.colors.surface }
        }
    }

    // Стрелка влево (ЗВУК УБРАН — теперь в onCurrentIndexChanged)
    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 8
        width: 32
        height: 32
        radius: 16
        color: leftMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }
        
        Text {
            anchors.centerIn: parent
            text: "‹"
            color: root.theme.colors.text || "#FFF"
            font.pixelSize: 26
            font.bold: true
        }
        
        MouseArea {
            id: leftMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                pathView.decrementCurrentIndex()
            }
        }
    }

    // Стрелка вправо (ЗВУК УБРАН — теперь в onCurrentIndexChanged)
    Rectangle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 8
        width: 32
        height: 32
        radius: 16
        color: rightMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }
        
        Text {
            anchors.centerIn: parent
            text: "›"
            color: root.theme.colors.text || "#FFF"
            font.pixelSize: 26
            font.bold: true
        }
        
        MouseArea {
            id: rightMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                pathView.incrementCurrentIndex()
            }
        }
    }

    // Индикаторы
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        spacing: 7
        
        Repeater {
            model: Math.min(root.wallpaperList.length, 15)
            delegate: Rectangle {
                property bool isActive: index === root.currentIndex
                width: isActive ? 18 : 6
                height: 6
                radius: 3
                color: isActive ? 
                       (root.theme.colors.accent || "#5B9BFF") : 
                       (root.theme.colors.textSecondary || "#AAA")
                opacity: isActive ? 1 : 0.35
                Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 250 } }
            }
        }
    }

    // Методы для внешнего управления
    function navigateLeft() {
        pathView.decrementCurrentIndex()
    }
    
    function navigateRight() {
        pathView.incrementCurrentIndex()
    }
    
    function applyCurrent() {
        if (wallpaperList.length > 0) {
            var fileName = wallpaperList[currentIndex]
            applyProcess.fileName = fileName
            applyProcess.running = true
            if (soundManager) soundManager.play("quick_click.wav")
            close()
        }
    }
}