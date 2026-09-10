import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    property string currentWallpaperPath: ""
    property string nextWallpaperPath: ""
    property bool isTransitioning: false
    
    property real revealRadius: 0
    property real maxRadius: Math.sqrt(
        Math.pow(wallpaperWindow.width / 2, 2) + 
        Math.pow(wallpaperWindow.height / 2, 2)
    ) * 1.05

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
                console.log("Loaded saved wallpaper:", saved)
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
        
        Component.onCompleted: {
            console.log("LayerShell wallpaper created")
        }
        
        Connections {
            target: root
            function onRevealRadiusChanged() {
                revealCanvas.requestPaint()
            }
        }
        
        // Старое изображение (БЕЗ sourceSize — оригинальный размер)
        Image {
            id: currentImage
            anchors.fill: parent
            source: root.currentWallpaperPath !== "" ? "file://" + root.currentWallpaperPath : ""
            fillMode: Image.PreserveAspectCrop
            cache: true
            smooth: true
            asynchronous: true
            
            onStatusChanged: {
                console.log("Current image status:", status)
            }
        }
        
        // Скрытое новое изображение (БЕЗ sourceSize, БЕЗ явных размеров)
        Image {
            id: hiddenNextImage
            visible: false
            source: root.nextWallpaperPath !== "" ? "file://" + root.nextWallpaperPath : ""
            fillMode: Image.PreserveAspectCrop
            cache: true
            smooth: true
            asynchronous: true
            
            onStatusChanged: {
                console.log("Hidden next image status:", status)
                if (status === Image.Ready && root.isTransitioning) {
                    console.log("Next image ready, starting reveal")
                    root.startReveal()
                }
            }
        }
        
        // Canvas с круговой маской
        Canvas {
            id: revealCanvas
            anchors.fill: parent
            visible: root.isTransitioning
            antialiasing: true
            renderTarget: Canvas.FramebufferObject
            renderStrategy: Canvas.Immediate
            
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                
                if (hiddenNextImage.status !== Image.Ready) return
                if (root.revealRadius <= 0) return
                
                var cx = width / 2
                var cy = height / 2
                var r = root.revealRadius
                
                // PreserveAspectCrop логика (как у currentImage)
                var imgW = hiddenNextImage.sourceSize.width
                var imgH = hiddenNextImage.sourceSize.height
                var imgRatio = imgW / imgH
                var canvasRatio = width / height
                var drawW, drawH, drawX, drawY
                
                if (imgRatio > canvasRatio) {
                    drawH = height
                    drawW = height * imgRatio
                    drawX = (width - drawW) / 2
                    drawY = 0
                } else {
                    drawW = width
                    drawH = width / imgRatio
                    drawX = 0
                    drawY = (height - drawH) / 2
                }
                
                ctx.save()
                ctx.beginPath()
                ctx.arc(cx, cy, r, 0, Math.PI * 2)
                ctx.clip()
                
                ctx.drawImage(hiddenNextImage, drawX, drawY, drawW, drawH)
                
                ctx.restore()
                
                if (root.isTransitioning) {
                    ctx.beginPath()
                    ctx.arc(cx, cy, r, 0, Math.PI * 2)
                    ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.3).toString()
                    ctx.lineWidth = 3
                    ctx.stroke()
                }
            }
        }
    }

    NumberAnimation {
        id: revealAnimation
        target: root
        property: "revealRadius"
        from: 0
        to: root.maxRadius
        duration: 800
        easing.type: Easing.OutCubic
        
        onStopped: {
            console.log("Reveal complete, swapping images")
            root.finishReveal()
        }
    }
    
    NumberAnimation {
        id: dimAnimation
        target: currentImage
        property: "opacity"
        from: 1.0
        to: 0.7
        duration: 400
        easing.type: Easing.OutCubic
    }

    function startReveal() {
        console.log("Starting reveal animation, maxRadius:", root.maxRadius)
        root.revealRadius = 0
        revealCanvas.requestPaint()
        dimAnimation.start()
        revealAnimation.start()
    }

    function finishReveal() {
        root.currentWallpaperPath = root.nextWallpaperPath
        root.nextWallpaperPath = ""
        root.isTransitioning = false
        root.revealRadius = 0
        
        currentImage.opacity = 1.0
        console.log("Reveal finished, new wallpaper:", root.currentWallpaperPath)
    }

    function cancelReveal() {
        console.log("Cancelling reveal without swap")
        revealAnimation.stop()
        dimAnimation.stop()
        root.isTransitioning = false
        root.revealRadius = 0
        root.nextWallpaperPath = ""
        currentImage.opacity = 1.0
        revealCanvas.requestPaint()
    }

    function applyWallpaper(fileName) {
        console.log("applyWallpaper called with:", fileName)
        var fullPath = "/home/graff/.config/hypr/walls/" + fileName
        savedWallpaperFile.setText(fullPath)
        root.applyWallpaperWithTransition(fullPath)
    }

    function applyWallpaperDirect(path) {
        console.log("applyWallpaperDirect called with:", path)
        root.applyWallpaperWithTransition(path)
    }

    function applyWallpaperWithTransition(path) {
        console.log("applyWallpaperWithTransition called with:", path)
        
        if (root.currentWallpaperPath === "") {
            console.log("First wallpaper, setting directly")
            root.currentWallpaperPath = path
            return
        }
        
        if (root.currentWallpaperPath === path) {
            console.log("Same wallpaper, skipping")
            return
        }
        
        if (root.isTransitioning) {
            console.log("Cancelling previous reveal")
            root.cancelReveal()
        }
        
        root.isTransitioning = true
        root.nextWallpaperPath = path
        console.log("Set nextWallpaperPath to:", path)
        
        if (hiddenNextImage.status === Image.Ready) {
            console.log("Image already loaded, starting reveal")
            root.startReveal()
        } else {
            console.log("Waiting for image to load...")
        }
    }

    IpcHandler {
        target: "wallpaper"
        
        function applyWallpaper(fileName: string) {
            console.log("IPC applyWallpaper received:", fileName)
            root.applyWallpaper(fileName)
        }
    }

    Component.onCompleted: {
        console.log("ShellRoot completed")
    }
}
