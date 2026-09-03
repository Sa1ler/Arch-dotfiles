import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string rootPath: Quickshell.shellDir + "/../"
    readonly property string themesPath: rootPath + "themes/"
    readonly property string selectedThemePath: rootPath + "selected-theme"

    property string currentTheme: "default"
    property var theme: ({
        "name": "Default",
        "colors": {
            "background": "#0E1217", "surface": "#1A1F26", "surfaceHover": "#252C36",
            "surfaceSelected": "#2C3A50", "accent": "#5B9BFF", "text": "#F0F4F8",
            "textSecondary": "#9AA9B9", "textDisabled": "#5A6675", "textSelected": "#FFFFFF",
            "border": "#2A323D", "separator": "#262E38"
        }
    })

    property var themes: []
    property var themeFiles: []
    property int loadingIndex: 0
    property var loadedThemes: []
    property bool themesLoaded: false

    signal themeChanging()

    FileView {
        id: savedThemeFile
        path: root.selectedThemePath
        watchChanges: true
        atomicWrites: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.applySavedTheme()
    }

    Process {
        id: findThemes
        command: ["sh", "-c", "ls -1 '" + root.themesPath + "' 2>/dev/null | grep '\\.json$' | sort"]
        stdout: StdioCollector {
            onStreamFinished: {
                var output = text.trim()
                root.themeFiles = []
                root.loadedThemes = []
                root.loadingIndex = 0
                if (output === "") {
                    root.themes = []
                    root.themesLoaded = true
                    root.applySavedTheme()
                    return
                }
                root.themeFiles = output.split("\n").filter(function(f) { return f.endsWith(".json") })
                root.loadNextTheme()
            }
        }
    }

    Process {
        id: readTheme
        stdout: StdioCollector {
            onStreamFinished: {
                var output = text.trim()
                if (output !== "") {
                    try {
                        var data = JSON.parse(output)
                        if (data.colors) {
                            var fileName = root.themeFiles[root.loadingIndex]
                            var themeName = fileName.replace(".json", "")
                            root.loadedThemes.push({
                                "file": themeName,
                                "name": data.name || themeName,
                                "colors": data.colors
                            })
                        }
                    } catch (e) { console.warn("ThemeManager: bad JSON:", e) }
                }
                root.loadingIndex++
                root.loadNextTheme()
            }
        }
    }

    function loadNextTheme() {
        if (root.loadingIndex >= root.themeFiles.length) {
            root.themes = root.loadedThemes
            root.themesLoaded = true
            root.applySavedTheme()
            return
        }
        var file = root.themeFiles[root.loadingIndex]
        readTheme.command = ["cat", root.themesPath + file]
        readTheme.running = true
    }

    function applySavedTheme() {
        if (!root.themesLoaded) return
        var savedTheme = savedThemeFile.loaded ? savedThemeFile.text().trim() : ""
        if (savedTheme !== "") {
            for (var i = 0; i < root.themes.length; i++) {
                if (root.themes[i].file === savedTheme) {
                    root.currentTheme = savedTheme
                    root.theme = root.themes[i]
                    return
                }
            }
        }
        for (var j = 0; j < root.themes.length; j++) {
            if (root.themes[j].file === "default") {
                root.currentTheme = "default"
                root.theme = root.themes[j]
                root.saveCurrentTheme()
                return
            }
        }
        if (root.themes.length > 0) {
            root.currentTheme = root.themes[0].file
            root.theme = root.themes[0]
            root.saveCurrentTheme()
        }
    }

    function loadTheme(name) {
        for (var i = 0; i < root.themes.length; i++) {
            if (root.themes[i].file === name) {
                root.themeChanging()
                root.currentTheme = root.themes[i].file
                root.theme = root.themes[i]
                root.saveCurrentTheme()
                return
            }
        }
    }

    function saveCurrentTheme() {
        if (savedThemeFile) savedThemeFile.setText(String(root.currentTheme))
    }

    Component.onCompleted: { findThemes.running = true }
}