import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    property var theme: null
    
    // === Текущие обои ===
    property string currentWallpaperPath: ""
    property string currentWallpaperName: ""
    property int lastMtime: 0
    
    signal closeRequested()
    
    readonly property color surfaceColor: theme && theme.colors ? theme.colors.surface : "#1A1F26"
    readonly property color textColor: theme && theme.colors ? theme.colors.text : "#FFFFFF"
    readonly property color textSecondaryColor: theme && theme.colors ? theme.colors.textSecondary : "#AAAAAA"
    readonly property color accentColor: theme && theme.colors ? theme.colors.accent : "#5B9BFF"
    readonly property color borderColor: theme && theme.colors ? theme.colors.border : "#333333"
    
    readonly property int headerHeight: 160
    
    readonly property string wallpaperFilePath: Quickshell.env["HOME"] + "/.config/quickshell/wallpaper/selected-wallpaper"
    
    // === Отступы блоков ===
    readonly property int blockLeftMargin: 6
    readonly property int blockRightMargin: -8
    readonly property int blockSpacing: 10
    
    // === Чтение текущих обоев ===
    Process {
        id: readWallpaper
        command: ["bash", "-c", 
            "FILE=\"$HOME/.config/quickshell/wallpaper/selected-wallpaper\"; " +
            "if [ -f \"$FILE\" ]; then " +
            "  cat \"$FILE\"; " +
            "else " +
            "  echo ''; " +
            "fi"
        ]
        
        stdout: StdioCollector {
            onStreamFinished: {
                var path = text.trim()
                console.log("[Personalization] Raw wallpaper path:", JSON.stringify(path))
                
                if (path.length > 0) {
                    root.currentWallpaperPath = path
                    var parts = path.split('/')
                    root.currentWallpaperName = parts.length > 0 ? parts[parts.length - 1] : "Не установлены"
                } else {
                    root.currentWallpaperPath = ""
                    root.currentWallpaperName = "Не установлены"
                }
            }
        }
        
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    console.warn("[Personalization] Error reading wallpaper:", text.trim())
                }
            }
        }
    }
    
    // === Проверка mtime файла ===
    Process {
        id: checkMtime
        command: ["bash", "-c", 
            "FILE=\"$HOME/.config/quickshell/wallpaper/selected-wallpaper\"; " +
            "if [ -f \"$FILE\" ]; then " +
            "  stat -c %Y \"$FILE\"; " +
            "else " +
            "  echo '0'; " +
            "fi"
        ]
        
        stdout: StdioCollector {
            onStreamFinished: {
                var mtime = parseInt(text.trim())
                if (mtime > 0 && mtime !== root.lastMtime) {
                    console.log("[Personalization] File mtime changed:", mtime)
                    root.lastMtime = mtime
                    readWallpaper.running = true
                }
            }
        }
    }
    
    Timer {
        id: mtimeCheckTimer
        interval: 500
        repeat: true
        running: true
        onTriggered: checkMtime.running = true
    }
    
    Component.onCompleted: {
        readWallpaper.running = true
    }
    
    // === ШАПКА С ОБОЯМИ ===
    Item {
        id: wallpaperHeader
        anchors.top: parent.top
        anchors.topMargin: -8
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.right: parent.right
        anchors.rightMargin: -8
        height: root.headerHeight
        z: 10
        
        Rectangle {
            id: headerMask
            width: wallpaperHeader.width
            height: wallpaperHeader.height
            radius: 14
            color: "white"
        }
        
        Item {
            id: headerContent
            anchors.fill: parent
            
            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: ShaderEffectSource {
                    sourceItem: headerMask
                    hideSource: true
                }
            }
            
            Rectangle {
                anchors.fill: parent
                radius: 14
                color: root.surfaceColor
                
                Image {
                    id: wallpaperImage
                    anchors.fill: parent
                    source: currentWallpaperPath !== "" ? "file://" + currentWallpaperPath : ""
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    cache: true
                    
                    Rectangle {
                        anchors.fill: parent
                        color: root.surfaceColor
                        visible: wallpaperImage.status !== Image.Ready
                        
                        Text {
                            anchors.centerIn: parent
                            text: "\uf03e  Обои не установлены"
                            font.family: "Font Awesome 6 Free Solid"
                            font.pixelSize: 14
                            color: root.textSecondaryColor
                        }
                    }
                    
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 70
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.7) }
                        }
                    }
                    
                    Text {
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.margins: 12
                        text: currentWallpaperName
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: "#FFFFFF"
                        
                        style: Text.Outline
                        styleColor: Qt.rgba(0, 0, 0, 0.8)
                    }
                    
                    // === КНОПКА СМЕНЫ ОБОЕВ (исправленный текст) ===
                    Rectangle {
                        id: changeWallpaperBtn
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 12
                        anchors.bottomMargin: 12
                        
                        width: 150
                        height: 36
                        radius: 9
                        
                        color: root.accentColor
                        
                        
                        Rectangle {
                            anchors.fill: parent
                            radius: 9
                            color: "#FFFFFF"
                            opacity: changeWallpaperMouse.containsMouse ? 0.15 : 0
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }
                        
                        scale: changeWallpaperMouse.pressed ? 0.96 : 1.0
                        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }
                        
                        Row {
                            anchors.centerIn: parent
                            spacing: 8
                            
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "\uf03e"
                                font.family: "Font Awesome 6 Free Solid"
                                font.pixelSize: 14
                                color: "#000000"
                            }
                            
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Сменить обои"
                                font.family: "JetBrains Mono"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: "#000000"
                            }
                        }
                        
                        MouseArea {
                            id: changeWallpaperMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            
                            onClicked: {
                                root.closeRequested()
                                Quickshell.execDetached([
                                    "qs", "-c", "bar", "ipc", "call", "topbar", "toggleWallpaper"
                                ])
                            }
                        }
                    }
                }
            }
        }
    }
    
    // === КОНТЕЙНЕР БЛОКОВ ПОД ШАПКОЙ ===
    Column {
        id: contentBlocks
        anchors.top: wallpaperHeader.bottom
        anchors.topMargin: root.blockSpacing
        anchors.left: parent.left
        anchors.leftMargin: root.blockLeftMargin
        anchors.right: parent.right
        anchors.rightMargin: root.blockRightMargin
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        spacing: root.blockSpacing
        
        // === БЛОК ТЕМЫ ===
        Rectangle {
            id: themeBlock
            width: parent.width
            height: 50
            radius: 12
            
            color: Qt.rgba(255, 255, 255, 0.04)
            border.width: 1
            border.color: Qt.rgba(255, 255, 255, 0.08)
            
            // Иконка слева
            Text {
                id: themeIcon
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: "\uf1fc"
                font.family: "Font Awesome 6 Free Solid"
                font.pixelSize: 15
                color: root.accentColor
            }
            
            // Название рядом с иконкой
            Text {
                anchors.left: themeIcon.right
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: "Тема"
                font.family: "JetBrains Mono"
                font.pixelSize: 13
                font.weight: Font.Bold
                color: root.textColor
            }
            
            // === КНОПКА СМЕНЫ ТЕМЫ (справа по центру) ===
            Rectangle {
                id: changeThemeBtn
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                
                width: 150
                height: 36
                radius: 9
                
                color: root.accentColor
                
                Rectangle {
                    anchors.fill: parent
                    radius: 9
                    color: "#FFFFFF"
                    opacity: changeThemeMouse.containsMouse ? 0.15 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }
                
                scale: changeThemeMouse.pressed ? 0.96 : 1.0
                Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }
                
                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\uf1fc"
                        font.family: "Font Awesome 6 Free Solid"
                        font.pixelSize: 14
                        color: "#000000"
                    }
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Сменить тему"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: "#000000"
                    }
                }
                
                MouseArea {
                    id: changeThemeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        root.closeRequested()
                        Quickshell.execDetached([
                            "qs", "-c", "bar", "ipc", "call", "topbar", "toggleTheme"
                        ])
                    }
                }
            }
        }
    }
}