import QtQuick
import Quickshell
import Quickshell.Io

import "panel"

ShellRoot {
    id: root

    property var wallpaperList: []
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
                root.applyWallpaperDirect(saved)
            }
        }
    }

    function applyWallpaper(fileName: string) {
        var fullPath = "/home/graff/.config/hypr/walls/" + fileName
        
        
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
        
        function toggle() {
            wallpaperWindow.windowVisible = !wallpaperWindow.windowVisible
            if (wallpaperWindow.windowVisible && root.wallpaperList.length === 0) {
                loadWallpapers.running = true
            }
        }
        
        function applyWallpaper(fileName: string) {
            root.applyWallpaper(fileName)
        }
    }

    Process {
        id: loadWallpapers
        command: ["sh", "-c", "ls -1 ~/.config/hypr/walls/ 2>/dev/null | grep -iE '\\.(jpg|jpeg|png|webp|gif)$' | sort"]
        stdout: StdioCollector {
            onStreamFinished: {
                var files = text.trim().split('\n').filter(f => f.length > 0)
                root.wallpaperList = files
            }
        }
    }

    // Установка обоев через swaybg (без задержки, чтобы не было мерцания)
    Process {
        id: setWallpaperSwaybg
        
        property string wallpaperPath: ""
        
        command: ["sh", "-c", "pkill swaybg 2>/dev/null; swaybg -i '" + wallpaperPath + "' -m fill > /dev/null 2>&1 &"]
        
        stdout: StdioCollector {
            onStreamFinished: {
            }
        }
        
        stderr: StdioCollector {
            onStreamFinished: {
            }
        }
    }

    WallpaperWindow {
        id: wallpaperWindow
        visible: false
        
        theme: themeManager.theme
        themeManager: themeManager
        wallpaperList: root.wallpaperList
        
        onApplyWallpaper: function(fileName) {
            root.applyWallpaper(fileName)
        }
    }
}