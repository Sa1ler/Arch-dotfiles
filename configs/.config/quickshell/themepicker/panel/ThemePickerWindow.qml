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
    property var themesList: []
    property bool themesLoaded: false
    property int currentIndex: 0
    property bool windowVisible: false
    
    signal applyTheme(string themeName)

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

    // Анимация открытия
    ParallelAnimation {
        id: openAnim
        NumberAnimation { target: pickerWindow; property: "scale"; from: 0.85; to: 1; duration: 400; easing.type: Easing.OutBack; easing.overshoot: 1.5 }
        NumberAnimation { target: pickerWindow; property: "opacity"; from: 0; to: 1; duration: 300; easing.type: Easing.OutCubic }
        NumberAnimation { target: titleText; property: "opacity"; from: 0; to: 0.9; duration: 300 }
        NumberAnimation { target: themesPath; property: "opacity"; from: 0; to: 1; duration: 350 }
    }

    // Анимация закрытия
    SequentialAnimation {
        id: closeAnim
        ParallelAnimation {
            NumberAnimation { target: pickerWindow; property: "scale"; from: 1; to: 0.9; duration: 250; easing.type: Easing.InCubic }
            NumberAnimation { target: pickerWindow; property: "opacity"; from: 1; to: 0; duration: 200; easing.type: Easing.InCubic }
            NumberAnimation { target: titleText; property: "opacity"; from: 0.9; to: 0; duration: 150 }
            NumberAnimation { target: themesPath; property: "opacity"; from: 1; to: 0; duration: 180 }
        }
        ScriptAction { script: { root.visible = false } }
    }

    onWindowVisibleChanged: {
        if (windowVisible) {
            visible = true
            openAnim.start()
        } else {
            closeAnim.start()
        }
    }

    // При загрузке тем — устанавливаем текущий индекс
    onThemesLoadedChanged: {
        if (themesLoaded && themesList.length > 0) {
            for (var i = 0; i < themesList.length; i++) {
                if (themesList[i].file === themeManager.currentTheme) {
                    currentIndex = i
                    break
                }
            }
        }
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
            themesPath.decrementCurrentIndex()
            event.accepted = true
        }
        
        Keys.onRightPressed: function(event) {
            themesPath.incrementCurrentIndex()
            event.accepted = true
        }
        
        Keys.onReturnPressed: function(event) {
            if (root.themesList.length > 0) {
                var themeItem = root.themesList[root.currentIndex]
                root.applyTheme(themeItem.file)
            }
            event.accepted = true
        }

        // Основное окно
        Rectangle {
            id: pickerWindow
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
                id: titleText
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 24
                text: "Themes"
                color: root.theme.colors.text || "#FFF"
                font.pixelSize: 22
                font.bold: true
                opacity: 0
            }

            // Карусель тем
            PathView {
                id: themesPath
                anchors.top: titleText.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 20
                anchors.bottomMargin: 60
                anchors.leftMargin: 50
                anchors.rightMargin: 50
                
                clip: true
                opacity: 0
                
                model: root.themesList
                pathItemCount: 5
                preferredHighlightBegin: 0.5
                preferredHighlightEnd: 0.5
                highlightMoveDuration: 300
                currentIndex: root.currentIndex
                
                path: Path {
                    startX: -themesPath.width * 0.3
                    startY: themesPath.height / 2
                    
                    PathAttribute { name: "itemScale"; value: 0.55 }
                    PathAttribute { name: "itemOpacity"; value: 0.25 }
                    PathAttribute { name: "itemZ"; value: 0 }
                    
                    PathLine {
                        x: themesPath.width / 2
                        y: themesPath.height / 2
                    }
                    
                    PathAttribute { name: "itemScale"; value: 1.0 }
                    PathAttribute { name: "itemOpacity"; value: 1.0 }
                    PathAttribute { name: "itemZ"; value: 10 }
                    
                    PathLine {
                        x: themesPath.width * 1.3
                        y: themesPath.height / 2
                    }
                    
                    PathAttribute { name: "itemScale"; value: 0.55 }
                    PathAttribute { name: "itemOpacity"; value: 0.25 }
                    PathAttribute { name: "itemZ"; value: 0 }
                }
                
                delegate: Item {
                    id: themeDelegate
                    width: themesPath.width * 0.45
                    height: themesPath.height * 0.85
                    
                    scale: PathView.itemScale !== undefined ? PathView.itemScale : 0.55
                    opacity: PathView.itemOpacity !== undefined ? PathView.itemOpacity : 0.25
                    z: PathView.itemZ !== undefined ? PathView.itemZ : 0
                    
                    property var themeData: modelData
                    property bool isCurrent: PathView.isCurrentItem
                    
                    // Тень
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width - 8
                        height: parent.height - 8
                        radius: 26
                        color: Qt.rgba(0, 0, 0, 0.5)
                        y: parent.y + 12
                        opacity: themeDelegate.isCurrent ? 0.9 : 0.3
                    }

                    // Карточка темы
                    Rectangle {
                        id: themeCard
                        anchors.fill: parent
                        radius: 24
                        color: themeData.colors ? themeData.colors.surface : "#2A2A35"
                        
                        border.width: themeDelegate.isCurrent ? 3 : 1
                        border.color: themeDelegate.isCurrent ? 
                                       (themeData.colors.accent || "#5B9BFF") : 
                                       Qt.rgba(1, 1, 1, 0.15)
                        
                        // Мини-превью интерфейса
                        Rectangle {
                            id: previewArea
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.topMargin: 12
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            height: parent.height * 0.55
                            radius: 16
                            color: themeData.colors.background || "#181818"
                            clip: true
                            
                            // Имитация бара
                            Rectangle {
                                id: previewBar
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 28
                                color: themeData.colors.surface || "#1A1F26"
                                
                                // Точки-индикаторы на баре
                                Row {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 4
                                    
                                    Repeater {
                                        model: 3
                                        delegate: Rectangle {
                                            width: 8
                                            height: 8
                                            radius: 4
                                            color: index === 0 ? themeData.colors.accent : Qt.rgba(1,1,1,0.2)
                                        }
                                    }
                                }
                                
                                // Часы на баре
                                Text {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "12:00"
                                    color: themeData.colors.text || "#FFF"
                                    font.pixelSize: 9
                                    font.bold: true
                                }
                            }
                            
                            // Имитация контента
                            Column {
                                anchors.top: previewBar.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.margins: 10
                                spacing: 6
                                
                                Rectangle {
                                    width: parent.width * 0.7
                                    height: 10
                                    radius: 5
                                    color: themeData.colors.text || "#FFF"
                                    opacity: 0.8
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.5
                                    height: 8
                                    radius: 4
                                    color: themeData.colors.textSecondary || "#AAA"
                                    opacity: 0.6
                                }
                                
                                Rectangle {
                                    width: parent.width * 0.6
                                    height: 8
                                    radius: 4
                                    color: themeData.colors.textSecondary || "#AAA"
                                    opacity: 0.4
                                }
                                
                                // Кнопка
                                Rectangle {
                                    width: 60
                                    height: 20
                                    radius: 10
                                    color: themeData.colors.accent || "#5B9BFF"
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Button"
                                        color: themeData.colors.textSelected || "#FFF"
                                        font.pixelSize: 8
                                        font.bold: true
                                    }
                                }
                            }
                        }
                        
                        // Название темы
                        Text {
                            id: themeNameText
                            anchors.top: previewArea.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.topMargin: 10
                            text: themeData.name || themeData.file
                            color: themeData.colors.text || "#FFF"
                            font.pixelSize: 16
                            font.bold: true
                        }
                        
                        // Цветовая палитра
                        Row {
                            anchors.top: themeNameText.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.topMargin: 8
                            spacing: 6
                            
                            Repeater {
                                model: [
                                    themeData.colors.background,
                                    themeData.colors.surface,
                                    themeData.colors.accent,
                                    themeData.colors.text,
                                    themeData.colors.textSecondary
                                ]
                                delegate: Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: modelData || "#888"
                                    border.width: 1
                                    border.color: Qt.rgba(1, 1, 1, 0.2)
                                }
                            }
                        }
                        
                        // Индикатор "текущая тема"
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottomMargin: 10
                            width: currentLabel.width + 16
                            height: 22
                            radius: 11
                            color: themeManager.currentTheme === themeData.file ? 
                                   (themeData.colors.accent || "#5B9BFF") : 
                                   Qt.rgba(0, 0, 0, 0.4)
                            opacity: themeDelegate.isCurrent ? 1 : 0
                            
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            
                            Text {
                                id: currentLabel
                                anchors.centerIn: parent
                                text: themeManager.currentTheme === themeData.file ? "✓ Current" : "↵ Apply"
                                color: themeManager.currentTheme === themeData.file ? 
                                       (themeData.colors.textSelected || "#FFF") : "#FFF"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                    }
                }
                
                onCurrentIndexChanged: {
                    root.currentIndex = currentIndex
                }
            }

            // Градиентные маски по краям
            Rectangle {
                anchors.left: parent.left
                anchors.top: themesPath.top
                anchors.bottom: themesPath.bottom
                width: 60
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: root.theme.colors.background }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
            
            Rectangle {
                anchors.right: parent.right
                anchors.top: themesPath.top
                anchors.bottom: themesPath.bottom
                width: 60
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: root.theme.colors.background }
                }
            }

            // Стрелка влево
            Rectangle {
                id: leftBtn
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 12
                width: 44
                height: 44
                radius: 22
                color: leftBtnMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
                
                Behavior on color { ColorAnimation { duration: 150 } }
                
                Text {
                    anchors.centerIn: parent
                    text: "‹"
                    color: root.theme.colors.text || "#FFF"
                    font.pixelSize: 36
                    font.bold: true
                }
                
                MouseArea {
                    id: leftBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: themesPath.decrementCurrentIndex()
                }
            }

            // Стрелка вправо
            Rectangle {
                id: rightBtn
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 12
                width: 44
                height: 44
                radius: 22
                color: rightBtnMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
                
                Behavior on color { ColorAnimation { duration: 150 } }
                
                Text {
                    anchors.centerIn: parent
                    text: "›"
                    color: root.theme.colors.text || "#FFF"
                    font.pixelSize: 36
                    font.bold: true
                }
                
                MouseArea {
                    id: rightBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: themesPath.incrementCurrentIndex()
                }
            }

            // Индикаторы
            Row {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 18
                spacing: 10
                
                Repeater {
                    model: Math.min(root.themesList.length, 15)
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

        // Области для закрытия по клику за пределами
        MouseArea {
            anchors { top: parent.top; left: parent.left; right: parent.right; bottom: pickerWindow.top }
            onClicked: root.windowVisible = false
        }
        MouseArea {
            anchors { top: pickerWindow.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
            onClicked: root.windowVisible = false
        }
        MouseArea {
            anchors { top: pickerWindow.top; left: parent.left; bottom: pickerWindow.bottom; right: pickerWindow.left }
            onClicked: root.windowVisible = false
        }
        MouseArea {
            anchors { top: pickerWindow.top; left: pickerWindow.right; right: parent.right; bottom: pickerWindow.bottom }
            onClicked: root.windowVisible = false
        }
    }

    onVisibleChanged: {
        if (visible) {
            focusScope.forceActiveFocus()
        }
    }
}