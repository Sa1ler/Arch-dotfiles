import QtQuick
import Quickshell

Item {
    id: root

    property var theme: null
    property var soundManager: null
    property bool active: false
    
    readonly property color surfaceColor: root.theme && root.theme.colors ? root.theme.colors.surface : "#1A1F26"
    readonly property color textColor: root.theme && root.theme.colors ? root.theme.colors.text : "#FFFFFF"
    readonly property color textSecondaryColor: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#AAAAAA"
    readonly property color accentColor: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
    readonly property color borderColor: root.theme && root.theme.colors ? root.theme.colors.border : "#333333"
    
    signal close()
    
    // === Список макетов ===
    property var layouts: [
        { id: "split",   name: "Split 50/50", desc: "Два окна пополам" },
        { id: "master",  name: "Master",      desc: "Большое + стек справа" },
        { id: "triple",  name: "Три колонки", desc: "Три равных столбца" },
        { id: "grid",    name: "Grid 2x2",    desc: "Сетка из 4 окон" },
        { id: "focus",   name: "Focus",       desc: "Редактор 75% + панель" },
        { id: "stack",   name: "Stack",       desc: "Три полосы" }
    ]

    onActiveChanged: {
        if (active) focusTimer.restart()
    }

    Timer {
        id: focusTimer
        interval: 100
        onTriggered: focusScope.forceActiveFocus()
    }

    FocusScope {
        id: focusScope
        anchors.fill: parent
        focus: root.active

        Keys.onEscapePressed: function(event) {
            root.close()
            event.accepted = true
        }

        // Заголовок
        Text {
            id: title
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 12
            text: "Window Layouts"
            color: root.textColor
            font.pixelSize: 16
            font.weight: Font.Bold
            font.family: "JetBrains Mono"
            font.letterSpacing: 0.3
        }
        
        // Сетка макетов
        Grid {
            id: layoutGrid
            anchors.top: title.bottom
            anchors.topMargin: 12
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12
            columns: 3
            spacing: 10
            
            Repeater {
                model: layouts
                
                // Карточка макета
                Rectangle {
                    id: card
                    width: 100
                    height: 110
                    radius: 12
                    color: cardMouse.containsMouse ? 
                           Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.15) : 
                           Qt.rgba(255, 255, 255, 0.03)
                    border.width: cardMouse.containsMouse ? 2 : 1
                    border.color: cardMouse.containsMouse ? 
                                  root.accentColor : 
                                  Qt.rgba(255, 255, 255, 0.1)
                    scale: cardMouse.pressed ? 0.95 : 1.0
                    
                    Behavior on color { ColorAnimation { duration: 180 } }
                    Behavior on border.color { ColorAnimation { duration: 180 } }
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack; easing.overshoot: 1.3 } }
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 6
                        
                        // === Мини-превью макета (схематичные квадратики) ===
                        Item {
                            width: parent.width
                            height: 50
                            
                            Rectangle {
                                anchors.fill: parent
                                radius: 4
                                color: Qt.rgba(0, 0, 0, 0.3)
                                border.width: 1
                                border.color: Qt.rgba(255, 255, 255, 0.1)
                            }
                            
                            // Отрисовка схемы макета
                            Loader {
                                anchors.fill: parent
                                anchors.margins: 4
                                sourceComponent: {
                                    switch (modelData.id) {
                                        case "split": return splitPreview
                                        case "master": return masterPreview
                                        case "triple": return triplePreview
                                        case "grid": return gridPreview
                                        case "focus": return focusPreview
                                        case "stack": return stackPreview
                                        default: return splitPreview
                                    }
                                }
                            }
                        }
                        
                        // Название
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.name
                            color: root.textColor
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            font.family: "JetBrains Mono"
                        }
                        
                        // Описание
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.desc
                            color: root.textSecondaryColor
                            font.pixelSize: 8
                            font.family: "JetBrains Mono"
                        }
                    }
                    
                    MouseArea {
                        id: cardMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: applyLayout(modelData.id)
                    }
                }
            }
        }
        
        // === Компоненты превью ===
        
        // Split 50/50
        Component {
            id: splitPreview
            Item {
                Row {
                    anchors.fill: parent
                    spacing: 3
                    Rectangle { width: (parent.width - 3) / 2; height: parent.height; radius: 2; color: root.accentColor; opacity: 0.7 }
                    Rectangle { width: (parent.width - 3) / 2; height: parent.height; radius: 2; color: root.accentColor; opacity: 0.5 }
                }
            }
        }
        
        // Master + Stack
        Component {
            id: masterPreview
            Item {
                Row {
                    anchors.fill: parent
                    spacing: 3
                    Rectangle { width: parent.width * 0.65; height: parent.height; radius: 2; color: root.accentColor; opacity: 0.8 }
                    Column {
                        width: parent.width * 0.35
                        height: parent.height
                        spacing: 3
                        Rectangle { width: parent.width; height: (parent.height - 3) / 2; radius: 2; color: root.accentColor; opacity: 0.4 }
                        Rectangle { width: parent.width; height: (parent.height - 3) / 2; radius: 2; color: root.accentColor; opacity: 0.4 }
                    }
                }
            }
        }
        
        // Triple
        Component {
            id: triplePreview
            Item {
                Row {
                    anchors.fill: parent
                    spacing: 3
                    Rectangle { width: (parent.width - 6) / 3; height: parent.height; radius: 2; color: root.accentColor; opacity: 0.7 }
                    Rectangle { width: (parent.width - 6) / 3; height: parent.height; radius: 2; color: root.accentColor; opacity: 0.6 }
                    Rectangle { width: (parent.width - 6) / 3; height: parent.height; radius: 2; color: root.accentColor; opacity: 0.5 }
                }
            }
        }
        
        // Grid 2x2
        Component {
            id: gridPreview
            Item {
                Grid {
                    anchors.fill: parent
                    columns: 2
                    spacing: 3
                    Rectangle { width: (parent.width - 3) / 2; height: (parent.height - 3) / 2; radius: 2; color: root.accentColor; opacity: 0.7 }
                    Rectangle { width: (parent.width - 3) / 2; height: (parent.height - 3) / 2; radius: 2; color: root.accentColor; opacity: 0.6 }
                    Rectangle { width: (parent.width - 3) / 2; height: (parent.height - 3) / 2; radius: 2; color: root.accentColor; opacity: 0.5 }
                    Rectangle { width: (parent.width - 3) / 2; height: (parent.height - 3) / 2; radius: 2; color: root.accentColor; opacity: 0.4 }
                }
            }
        }
        
        // Focus
        Component {
            id: focusPreview
            Item {
                Row {
                    anchors.fill: parent
                    spacing: 3
                    Rectangle { width: parent.width * 0.7; height: parent.height; radius: 2; color: root.accentColor; opacity: 0.85 }
                    Rectangle { width: parent.width * 0.3 - 3; height: parent.height; radius: 2; color: root.accentColor; opacity: 0.4 }
                }
            }
        }
        
        // Stack
        Component {
            id: stackPreview
            Item {
                Column {
                    anchors.fill: parent
                    spacing: 3
                    Rectangle { width: parent.width; height: (parent.height - 6) / 3; radius: 2; color: root.accentColor; opacity: 0.7 }
                    Rectangle { width: parent.width; height: (parent.height - 6) / 3; radius: 2; color: root.accentColor; opacity: 0.6 }
                    Rectangle { width: parent.width; height: (parent.height - 6) / 3; radius: 2; color: root.accentColor; opacity: 0.5 }
                }
            }
        }
    }
    
    function applyLayout(layoutId) {
        console.log("[LayoutPicker] Applying layout:", layoutId)
        Quickshell.execDetached([
            "bash",
            Quickshell.env["HOME"] + "/.config/quickshell/scripts/apply-layout.sh",
            layoutId
        ])
        if (soundManager) soundManager.play("quick_click.wav")
        close()
    }
}
