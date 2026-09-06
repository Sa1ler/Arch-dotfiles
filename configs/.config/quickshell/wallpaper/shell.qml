import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root

    property string selectedWallpaperPath: ""

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
            if (saved !== "") {
                root.selectedWallpaperPath = saved
                console.log("Loaded saved wallpaper:", saved)
                root.applyWallpaperDirect(saved)
            }
        }
    }

    function applyWallpaper(fileName: string) {
        var fullPath = "/home/graff/.config/hypr/walls/" + fileName
        console.log("Applying wallpaper:", fullPath)
        savedWallpaperFile.setText(fullPath)
        root.selectedWallpaperPath = fullPath
        setWallpaperSwaybg.wallpaperPath = fullPath
        setWallpaperSwaybg.running = true
    }

    function applyWallpaperDirect(path: string) {
        setWallpaperSwaybg.wallpaperPath = path
        setWallpaperSwaybg.running = true
    }

    IpcHandler {
        target: "wallpaper"
        
        function applyWallpaper(fileName: string) {
            root.applyWallpaper(fileName)
        }
    }

    Process {
        id: setWallpaperSwaybg
        
        property string wallpaperPath: ""
        
        // Сначала запускаем новый, ждём применения, потом убиваем старые
        command: ["sh", "-c", "swaybg -i '" + wallpaperPath + "' -m fill > /dev/null 2>&1 & NEW_PID=$!; sleep 0.3; for PID in $(pgrep -x swaybg); do [ \"$PID\" != \"$NEW_PID\" ] && kill $PID 2>/dev/null; done"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim() !== "") console.log("swaybg output:", text)
            }
        }
        
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim() !== "") console.log("swaybg error:", text)
            }
        }
    }
}