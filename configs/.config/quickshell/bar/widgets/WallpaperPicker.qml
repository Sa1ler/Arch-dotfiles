import QtQuick
import QtQuick.Controls
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
    
    readonly property real glassOpacity: 0.92
    
    signal close()

    opacity: active ? 1 : 0
    scale: active ? 1 : 0.94
    y: active ? 0 : -20
    
    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutQuint } }
    Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutQuint } }

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

    Rectangle {
        anchors.fill: parent
        radius: 20
        color: Qt.rgba(surfaceColor.r, surfaceColor.g, surfaceColor.b, glassOpacity)
        
        Rectangle {
            anchors.fill: parent
            radius: 20
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.05)
            color: "transparent"
        }
    }

    Text {
        id: title
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 26
        text: "Wallpapers"
        color: root.textColor
        font.pixelSize: 16
        font.weight: Font.DemiBold
        font.family: "CaskaydiaCove Nerd Font"
        
        opacity: active ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    PathView {
        id: pathView
        anchors.top: title.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 20
        anchors.bottomMargin: 56
        anchors.leftMargin: 70
        anchors.rightMargin: 70
        
        clip: true
        model: root.wallpaperList
        pathItemCount: 5
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        highlightMoveDuration: 300
        snapMode: PathView.SnapToItem
        
        path: Path {
            startX: -pathView.width * 0.4
            startY: pathView.height / 2
            
            PathAttribute { name: "itemScale"; value: 0.6 }
            PathAttribute { name: "itemOpacity"; value: 0.35 }
            PathAttribute { name: "itemZ"; value: 0 }
            
            PathLine { x: pathView.width / 2; y: pathView.height / 2 }
            
            PathAttribute { name: "itemScale"; value: 1.0 }
            PathAttribute { name: "itemOpacity"; value: 1.0 }
            PathAttribute { name: "itemZ"; value: 10 }
            
            PathLine { x: pathView.width * 1.4; y: pathView.height / 2 }
            
            PathAttribute { name: "itemScale"; value: 0.6 }
            PathAttribute { name: "itemOpacity"; value: 0.35 }
            PathAttribute { name: "itemZ"; value: 0 }
        }
        
        delegate: Item {
            id: delegateItem
            width: pathView.width * 0.62
            height: pathView.height * 0.92
            
            property bool isCurrent: PathView.isCurrentItem
            property bool isHovered: cardMouse.containsMouse
            
            scale: PathView.itemScale !== undefined ? PathView.itemScale : 0.6
            opacity: PathView.itemOpacity !== undefined ? PathView.itemOpacity : 0.35
            z: PathView.itemZ !== undefined ? PathView.itemZ : 0
            
            Rectangle {
                id: card
                anchors.fill: parent
                radius: 0
                color: "#2A2A35"
                border.width: isCurrent ? 2 : 1
                border.color: isCurrent ? root.accentColor : Qt.rgba(1, 1, 1, 0.1)
                clip: true
                
                Behavior on border.width { NumberAnimation { duration: 180 } }
                Behavior on border.color { ColorAnimation { duration: 180 } }
                
                // === Контейнер изображения (прямоугольный) ===
                Rectangle {
                    id: imageContainer
                    anchors.fill: parent
                    anchors.margins: 4
                    radius: 0
                    clip: true
                    color: surfaceColor
                    
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
                        
                        property bool loadFailed: false
                        
                        onStatusChanged: {
                            if (status === Image.Error || status === Image.Null) {
                                loadFailed = true
                            } else if (status === Image.Ready) {
                                loadFailed = false
                            }
                        }
                    }
                    
                    // Fallback при ошибке
                    Rectangle {
                        anchors.fill: parent
                        color: surfaceColor
                        visible: wallpaperImage.loadFailed
                        
                        Text {
                            anchors.centerIn: parent
                            text: ""
                            font.pixelSize: 48
                            color: root.textSecondaryColor
                            font.family: "CaskaydiaCove Nerd Font"
                            opacity: 0.4
                        }
                    }
                    
                    // Градиент снизу
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 56
                        
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.3; color: Qt.rgba(0, 0, 0, 0.2) }
                            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.88) }
                        }
                        
                        Rectangle {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            width: 26
                            height: 26
                            radius: 13
                            color: root.accentColor
                            opacity: isCurrent ? 1 : 0
                            scale: isCurrent ? 1 : 0.3
                            
                            Behavior on opacity { NumberAnimation { duration: 180 } }
                            Behavior on scale { 
                                NumberAnimation { 
                                    duration: 220
                                    easing.type: Easing.OutBack
                                    easing.overshoot: 1.5
                                } 
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "\uf00c"
                                color: "#000000"
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                                font.family: "CaskaydiaCove Nerd Font"
                            }
                        }
                        
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: isCurrent ? 46 : 14
                            anchors.rightMargin: 14
                            text: {
                                var name = modelData
                                var lastSlash = name.lastIndexOf('/')
                                if (lastSlash !== -1) name = name.substring(lastSlash + 1)
                                return name
                            }
                            color: "#FFFFFF"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            font.family: "JetBrains Mono"
                            elide: Text.ElideRight
                            opacity: isCurrent ? 1 : (isHovered ? 0.9 : 0.6)
                            
                            Behavior on opacity { NumberAnimation { duration: 180 } }
                            Behavior on anchors.leftMargin { 
                                NumberAnimation { duration: 220; easing.type: Easing.OutCubic } 
                            }
                        }
                    }
                    
                    // Hover overlay
                    Rectangle {
                        anchors.fill: parent
                        color: Qt.rgba(0, 0, 0, 0.15)
                        opacity: isHovered && !isCurrent ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 180 } }
                    }
                    
                    // Вспышка при применении
                    Rectangle {
                        id: flashEffect
                        anchors.fill: parent
                        color: "#FFFFFF"
                        opacity: 0
                        
                        function flash() {
                            flashAnimation.restart()
                        }
                        
                        SequentialAnimation {
                            id: flashAnimation
                            NumberAnimation { target: flashEffect; property: "opacity"; to: 0.3; duration: 80 }
                            NumberAnimation { target: flashEffect; property: "opacity"; to: 0; duration: 180 }
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
                            flashEffect.flash()
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
                    
                    onPressedChanged: {
                        if (isCurrent) {
                            card.scale = pressed ? 0.97 : 1.0
                        }
                    }
                }
                
                Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
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

    Rectangle {
        anchors.left: parent.left
        anchors.top: pathView.top
        anchors.bottom: pathView.bottom
        width: 70
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: surfaceColor }
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
            GradientStop { position: 1.0; color: surfaceColor }
        }
    }

    Text {
        id: leftArrow
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 28
        text: "\uf060"
        color: root.textColor
        font.pixelSize: 22
        font.family: "CaskaydiaCove Nerd Font"
        opacity: leftMouse.containsMouse ? 1 : 0.4
        x: leftMouse.containsMouse ? -3 : 0
        scale: leftMouse.pressed ? 0.88 : 1.0
        
        Behavior on opacity { NumberAnimation { duration: 150 } }
        Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
        
        MouseArea {
            id: leftMouse
            anchors.fill: parent
            anchors.margins: -12
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: pathView.decrementCurrentIndex()
        }
    }

    Text {
        id: rightArrow
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 28
        text: "\uf061"
        color: root.textColor
        font.pixelSize: 22
        font.family: "CaskaydiaCove Nerd Font"
        opacity: rightMouse.containsMouse ? 1 : 0.4
        x: rightMouse.containsMouse ? 3 : 0
        scale: rightMouse.pressed ? 0.88 : 1.0
        
        Behavior on opacity { NumberAnimation { duration: 150 } }
        Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
        
        MouseArea {
            id: rightMouse
            anchors.fill: parent
            anchors.margins: -12
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: pathView.incrementCurrentIndex()
        }
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 26
        spacing: 8
        
        opacity: active ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 250 } }
        
        Repeater {
            model: Math.min(root.wallpaperList.length, 10)
            delegate: Rectangle {
                property bool isActive: index === root.currentIndex
                width: isActive ? 20 : 6
                height: 6
                radius: 3
                color: isActive ? root.accentColor : Qt.rgba(1, 1, 1, 0.25)
                
                Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 220 } }
                
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: pathView.currentIndex = index
                }
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