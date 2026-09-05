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

    SoundPlayer {
        id: soundManager
        soundsDir: Quickshell.shellDir + "/../sounds"
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
        
        soundManager.play("quick_click.wav")
        
        setWallpaperSwaybg.wallpaperPath = fullPath
        setWallpaperSwaybg.running = true
    }

    function applyWallpaperDirect(path: string) {
        console.log("Direct applying wallpaper:", path)
        setWallpaperSwaybg.wallpaperPath = path
        setWallpaperSwaybg.running = true
    }

    function playWindowSound(isOpen) {
        if (isOpen) {
            soundManager.play("list.wav")
        } else {
            soundManager.play("sfx.wav")
        }
    }

    IpcHandler {
        target: "wallpaper"
        
        function toggle() {
            var willOpen = !wallpaperWindow.windowVisible
            wallpaperWindow.windowVisible = willOpen
            
            if (willOpen && root.wallpaperList.length === 0) {
                loadWallpapers.running = true
            }
            
            playWindowSound(willOpen)
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
                console.log("Loaded wallpapers:", files.length)
            }
        }
    }

    Process {
        id: setWallpaperSwaybg
        
        property string wallpaperPath: ""
        
        command: ["sh", "-c", "pkill swaybg 2>/dev/null; swaybg -i '" + wallpaperPath + "' -m fill > /dev/null 2>&1 &"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                console.log("swaybg output:", text)
            }
        }
        
        stderr: StdioCollector {
            onStreamFinished: {
                console.log("swaybg error:", text)
            }
        }
    }

    WallpaperWindow {
        id: wallpaperWindow
        visible: false
        
        theme: themeManager.theme
        themeManager: themeManager
        wallpaperList: root.wallpaperList
        soundManager: soundManager
        
        onApplyWallpaper: function(fileName) {
            root.applyWallpaper(fileName)
        }
    }
}