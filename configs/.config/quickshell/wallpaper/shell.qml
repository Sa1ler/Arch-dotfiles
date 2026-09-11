import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    property string currentWallpaperPath: ""
    property string nextWallpaperPath: ""
    property bool isTransitioning: false
    
    property real wipeProgress: 0

    ThemeManager {
        id: themeManager
    }

    FileView {
        id: savedWallpaperFile
        path: Quickshell.shellDir + "/selected-wallpaper"
        watchChanges: true
        atomicWrites: true
        printErrors: false
        
        onLoaded: {
            var saved = savedWallpaperFile.text().trim()
            if (saved !== "" && saved !== root.currentWallpaperPath) {
                root.applyWallpaperDirect(saved)
            }
        }
    }

    PanelWindow {
        id: wallpaperWindow
        
        color: "black"
        visible: true
        
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "quickshell-wallpaper"
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        
        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        
        Image {
            id: currentImage
            anchors.fill: parent
            source: root.currentWallpaperPath !== "" ? "file://" + root.currentWallpaperPath : ""
            fillMode: Image.PreserveAspectCrop
            cache: true
            smooth: true
            asynchronous: true
        }
        
        Image {
            id: nextImage
            anchors.fill: parent
            source: root.nextWallpaperPath !== "" ? "file://" + root.nextWallpaperPath : ""
            fillMode: Image.PreserveAspectCrop
            cache: true
            smooth: true
            asynchronous: true
            visible: root.isTransitioning
            
            onStatusChanged: {
                if (status === Image.Ready && root.isTransitioning) {
                    root.startWipe()
                }
            }
            
            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: maskItem
                maskThresholdMin: 0.0
                maskSpreadAtMin: 0.0
            }
        }
        
        // Маска — прямоугольник, расширяющийся из центра
        Item {
            id: maskItem
            width: nextImage.width
            height: nextImage.height
            visible: false
            layer.enabled: true
            
            Rectangle {
                id: maskRect
                width: root.wipeProgress * maskItem.width
                height: maskItem.height
                color: "white"
                x: (maskItem.width - width) / 2  // Центрирование
                y: 0
            }
        }
        
        // Две светлые полоски по краям
        Rectangle {
            id: glowLeft
            width: 3
            height: wallpaperWindow.height
            color: Qt.rgba(1, 1, 1, 0.4)
            x: (wallpaperWindow.width - root.wipeProgress * wallpaperWindow.width) / 2 - 1.5
            y: 0
            visible: root.isTransitioning && root.wipeProgress > 0 && root.wipeProgress < 1
        }
        
        Rectangle {
            id: glowRight
            width: 3
            height: wallpaperWindow.height
            color: Qt.rgba(1, 1, 1, 0.4)
            x: (wallpaperWindow.width + root.wipeProgress * wallpaperWindow.width) / 2 - 1.5
            y: 0
            visible: root.isTransitioning && root.wipeProgress > 0 && root.wipeProgress < 1
        }
    }

    NumberAnimation {
        id: wipeAnimation
        target: root
        property: "wipeProgress"
        from: 0
        to: 1
        duration: 700
        easing.type: Easing.InOutQuart
        
        onStopped: {
            root.finishWipe()
        }
    }
    
    NumberAnimation {
        id: dimAnimation
        target: currentImage
        property: "opacity"
        from: 1.0
        to: 0.8
        duration: 400
        easing.type: Easing.OutCubic
    }

    function startWipe() {
        root.wipeProgress = 0
        dimAnimation.start()
        wipeAnimation.start()
    }

    function finishWipe() {
        root.currentWallpaperPath = root.nextWallpaperPath
        root.nextWallpaperPath = ""
        root.isTransitioning = false
        root.wipeProgress = 0
        currentImage.opacity = 1.0
    }

    function cancelWipe() {
        wipeAnimation.stop()
        dimAnimation.stop()
        root.isTransitioning = false
        root.nextWallpaperPath = ""
        root.wipeProgress = 0
        currentImage.opacity = 1.0
    }

    function applyWallpaper(fileName) {
        var fullPath = "/home/graff/.config/hypr/walls/" + fileName
        savedWallpaperFile.setText(fullPath)
        root.applyWallpaperWithTransition(fullPath)
    }

    function applyWallpaperDirect(path) {
        root.applyWallpaperWithTransition(path)
    }

    function applyWallpaperWithTransition(path) {
        if (root.currentWallpaperPath === "") {
            root.currentWallpaperPath = path
            return
        }
        
        if (root.currentWallpaperPath === path) return
        
        if (root.isTransitioning) {
            root.cancelWipe()
        }
        
        root.isTransitioning = true
        root.nextWallpaperPath = path
        
        if (nextImage.status === Image.Ready) {
            root.startWipe()
        }
    }

    IpcHandler {
        target: "wallpaper"
        
        function applyWallpaper(fileName: string) {
            root.applyWallpaper(fileName)
        }
    }
}
