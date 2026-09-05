import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    property var theme: null
    property var themeManager: null
    property var wallpaperList: []
    property var soundManager: null
    property int currentIndex: 0
    property bool windowVisible: false
    property bool isLoaded: false
    
    signal applyWallpaper(string fileName)

    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    ParallelAnimation {
        id: openAnimation
        NumberAnimation { target: wallpaperWindow; property: "scale"; from: 0.85; to: 1; duration: 400; easing.type: Easing.OutBack; easing.overshoot: 1.5 }
        NumberAnimation { target: wallpaperWindow; property: "opacity"; from: 0; to: 1; duration: 300; easing.type: Easing.OutCubic }
        NumberAnimation { target: title; property: "opacity"; from: 0; to: 0.9; duration: 300 }
        NumberAnimation { target: pathView; property: "opacity"; from: 0; to: 1; duration: 350 }
    }

    SequentialAnimation {
        id: closeAnimation
        ParallelAnimation {
            NumberAnimation { target: wallpaperWindow; property: "scale"; from: 1; to: 0.9; duration: 250; easing.type: Easing.InCubic }
            NumberAnimation { target: wallpaperWindow; property: "opacity"; from: 1; to: 0; duration: 200; easing.type: Easing.InCubic }
            NumberAnimation { target: title; property: "opacity"; from: 0.9; to: 0; duration: 150 }
            NumberAnimation { target: pathView; property: "opacity"; from: 1; to: 0; duration: 180 }
        }
        ScriptAction { script: { root.visible = false; root.isLoaded = false } }
    }

    onWindowVisibleChanged: {
        if (windowVisible) {
            visible = true
            openAnimation.start()
            loadedTimer.start()
        } else {
            closeAnimation.start()
        }
    }

    Timer {
        id: loadedTimer
        interval: 450
        onTriggered: root.isLoaded = true
    }

    FocusScope {
        id: focusScope
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: function(event) {
            root.windowVisible = false
            event.accepted = true
        }
        
        Keys.onLeftPressed: function(event) {
            pathView.decrementCurrentIndex()
            event.accepted = true
        }
        
        Keys.onRightPressed: function(event) {
            pathView.incrementCurrentIndex()
            event.accepted = true
        }
        
        Keys.onReturnPressed: function(event) {
            if (root.wallpaperList.length > 0) {
                var fileName = root.wallpaperList[root.currentIndex]
                root.applyWallpaper(fileName)
                root.windowVisible = false
            }
            event.accepted = true
        }

        Rectangle {
            id: wallpaperWindow
            width: 750
            height: 420
            anchors.centerIn: parent
            radius: 32
            color: root.theme && root.theme.colors ? root.theme.colors.background : "#181818"
            border.width: 2
            border.color: root.theme && root.theme.colors ? root.theme.colors.border : "#333333"
            antialiasing: true
            
            scale: 0.85
            opacity: 0

            Text {
                id: title
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 24
                text: "Wallpapers"
                color: root.theme.colors.text || "#FFF"
                font.pixelSize: 22
                font.bold: true
                opacity: 0
            }

            PathView {
                id: pathView
                anchors.top: title.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 20
                anchors.bottomMargin: 60
                anchors.leftMargin: 50
                anchors.rightMargin: 50
                
                clip: true
                opacity: 0
                
                model: root.wallpaperList
                pathItemCount: 5
                preferredHighlightBegin: 0.5
                preferredHighlightEnd: 0.5
                highlightMoveDuration: 300
                
                path: Path {
                    startX: -pathView.width * 0.3
                    startY: pathView.height / 2
                    
                    PathAttribute { name: "itemScale"; value: 0.55 }
                    PathAttribute { name: "itemOpacity"; value: 0.25 }
                    PathAttribute { name: "itemZ"; value: 0 }
                    
                    PathLine {
                        x: pathView.width / 2
                        y: pathView.height / 2
                    }
                    
                    PathAttribute { name: "itemScale"; value: 1.0 }
                    PathAttribute { name: "itemOpacity"; value: 1.0 }
                    PathAttribute { name: "itemZ"; value: 10 }
                    
                    PathLine {
                        x: pathView.width * 1.3
                        y: pathView.height / 2
                    }
                    
                    PathAttribute { name: "itemScale"; value: 0.55 }
                    PathAttribute { name: "itemOpacity"; value: 0.25 }
                    PathAttribute { name: "itemZ"; value: 0 }
                }
                
                delegate: Item {
                    id: delegateItem
                    width: pathView.width * 0.45
                    height: pathView.height * 0.85
                    
                    scale: PathView.itemScale !== undefined ? PathView.itemScale : 0.55
                    opacity: PathView.itemOpacity !== undefined ? PathView.itemOpacity : 0.25
                    z: PathView.itemZ !== undefined ? PathView.itemZ : 0
                    
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width - 8
                        height: parent.height - 8
                        radius: 26
                        color: Qt.rgba(0, 0, 0, 0.5)
                        y: parent.y + 12
                        opacity: PathView.isCurrentItem ? 0.9 : 0.3
                    }

                    Rectangle {
                        id: card
                        anchors.fill: parent
                        radius: 24
                        color: "#2A2A35"
                        
                        border.width: PathView.isCurrentItem ? 3 : 1
                        border.color: PathView.isCurrentItem ? 
                                       (root.theme.colors.accent || "#5B9BFF") : 
                                       Qt.rgba(1, 1, 1, 0.15)
                        
                        Item {
                            id: imageContainer
                            anchors.fill: parent
                            anchors.margins: 3
                            
                            Image {
                                id: img
                                anchors.fill: parent
                                source: "file:///home/graff/.config/hypr/walls/" + modelData
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                                smooth: true
                                antialiasing: true
                            }
                            
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: imageContainer.width
                                    height: imageContainer.height
                                    radius: 21
                                }
                            }
                            
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 60
                                
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "transparent" }
                                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.85) }
                                }
                                
                                Text {
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottomMargin: 12
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 16
                                    text: modelData
                                    color: "#FFF"
                                    font.pixelSize: 14
                                    font.bold: true
                                    elide: Text.ElideRight
                                    opacity: PathView.isCurrentItem ? 1 : 0.4
                                }
                            }
                        }
                        
                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: parent.height * 0.3
                            radius: 24
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.08) }
                                GradientStop { position: 1.0; color: "transparent" }
                            }
                        }
                    }
                }
                
                onCurrentIndexChanged: {
                    root.currentIndex = currentIndex
                    
                    if (root.isLoaded && root.soundManager) {
                        root.soundManager.play("in.wav")
                    }
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.top: pathView.top
                anchors.bottom: pathView.bottom
                width: 60
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: root.theme.colors.background }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
            
            Rectangle {
                anchors.right: parent.right
                anchors.top: pathView.top
                anchors.bottom: pathView.bottom
                width: 60
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: root.theme.colors.background }
                }
            }

            Rectangle {
                id: leftArrow
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 12
                width: 44
                height: 44
                radius: 22
                color: leftArrowMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
                
                Behavior on color { ColorAnimation { duration: 150 } }
                
                Text {
                    anchors.centerIn: parent
                    text: "‹"
                    color: root.theme.colors.text || "#FFF"
                    font.pixelSize: 36
                    font.bold: true
                }
                
                MouseArea {
                    id: leftArrowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        pathView.decrementCurrentIndex()
                        if (root.soundManager) {
                            root.soundManager.play("in.wav")
                        }
                    }
                }
            }

            Rectangle {
                id: rightArrow
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 12
                width: 44
                height: 44
                radius: 22
                color: rightArrowMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
                
                Behavior on color { ColorAnimation { duration: 150 } }
                
                Text {
                    anchors.centerIn: parent
                    text: "›"
                    color: root.theme.colors.text || "#FFF"
                    font.pixelSize: 36
                    font.bold: true
                }
                
                MouseArea {
                    id: rightArrowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        pathView.incrementCurrentIndex()
                        if (root.soundManager) {
                            root.soundManager.play("in.wav")
                        }
                    }
                }
            }

            Row {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 18
                spacing: 10
                
                Repeater {
                    model: Math.min(root.wallpaperList.length, 15)
                    delegate: Rectangle {
                        property bool isActive: index === root.currentIndex
                        width: isActive ? 24 : 8
                        height: 8
                        radius: 4
                        color: isActive ? 
                               (root.theme.colors.accent || "#5B9BFF") : 
                               (root.theme.colors.textSecondary || "#AAA")
                        opacity: isActive ? 1 : 0.35
                        
                        Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                        Behavior on opacity { NumberAnimation { duration: 250 } }
                    }
                }
            }
        }

        MouseArea {
            anchors { top: parent.top; left: parent.left; right: parent.right; bottom: wallpaperWindow.top }
            onClicked: root.windowVisible = false
        }
        MouseArea {
            anchors { top: wallpaperWindow.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
            onClicked: root.windowVisible = false
        }
        MouseArea {
            anchors { top: wallpaperWindow.top; left: parent.left; bottom: wallpaperWindow.bottom; right: wallpaperWindow.left }
            onClicked: root.windowVisible = false
        }
        MouseArea {
            anchors { top: wallpaperWindow.top; left: wallpaperWindow.right; right: parent.right; bottom: wallpaperWindow.bottom }
            onClicked: root.windowVisible = false
        }
    }

    onVisibleChanged: {
        if (visible) {
            focusScope.forceActiveFocus()
        }
    }
}