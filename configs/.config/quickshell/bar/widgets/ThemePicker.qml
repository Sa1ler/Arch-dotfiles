import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null
    property var themeManager: null
    property var soundManager: null
    property bool active: false
    property var themesList: []
    property int currentIndex: 0
    property bool isFirstChange: true  // ← ВОЗВРАЩЕНО
    
    signal close()

    // Загрузка списка тем через процесс
    Process {
        id: loadThemes
        command: ["sh", "-c", "ls -1 ~/.config/quickshell/themes/ 2>/dev/null | grep -iE '\\.json$' | sed 's/\\.json$//' | sort"]
        stdout: StdioCollector {
            onStreamFinished: {
                var files = text.trim().split('\n').filter(function(f) { return f.length > 0 })
                root.themesList = files
                console.log("Loaded themes:", files.length)
                
                // Установить текущую тему после загрузки
                if (root.active && root.themeManager && root.themeManager.currentTheme && root.themesList.length > 0) {
                    for (var i = 0; i < root.themesList.length; i++) {
                        if (root.themesList[i] === root.themeManager.currentTheme) {
                            root.currentIndex = i
                            pathView.currentIndex = i
                            break
                        }
                    }
                }
            }
        }
    }

    // Применение темы через themepicker процесс
    Process {
        id: applyProcess
        property string themeName: ""
        command: ["qs", "-c", "themepicker", "ipc", "call", "themepicker", "applyTheme", themeName]
    }

    onActiveChanged: {
        if (active) {
            isFirstChange = true  // ← Сбрасываем при открытии
            
            // Запускаем загрузку если список пуст
            if (themesList.length === 0) {
                loadThemes.running = true  // ← ВОЗВРАЩЕНО
            } else if (themeManager && themeManager.currentTheme && themesList.length > 0) {
                // Найти текущую тему и установить индекс
                for (var i = 0; i < themesList.length; i++) {
                    if (themesList[i] === themeManager.currentTheme) {
                        root.currentIndex = i
                        pathView.currentIndex = i
                        break
                    }
                }
            }
        } else {
            isFirstChange = true  // ← Сбрасываем при закрытии
        }
    }

    // Заголовок
    Text {
        id: title
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 14
        text: "Themes"
        color: root.theme.colors.text || "#FFF"
        font.pixelSize: 17
        font.bold: true
        opacity: 0.9
    }

    // Карусель тем
    PathView {
        id: pathView
        anchors.top: title.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 8
        anchors.bottomMargin: 36
        anchors.leftMargin: 36
        anchors.rightMargin: 36
        
        clip: true
        
        model: root.themesList
        pathItemCount: 5
        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5
        highlightMoveDuration: 280
        
        path: Path {
            startX: -pathView.width * 0.3
            startY: pathView.height / 2
            
            PathAttribute { name: "itemScale"; value: 0.6 }
            PathAttribute { name: "itemOpacity"; value: 0.3 }
            PathAttribute { name: "itemZ"; value: 0 }
            
            PathLine { x: pathView.width / 2; y: pathView.height / 2 }
            
            PathAttribute { name: "itemScale"; value: 1.0 }
            PathAttribute { name: "itemOpacity"; value: 1.0 }
            PathAttribute { name: "itemZ"; value: 10 }
            
            PathLine { x: pathView.width * 1.3; y: pathView.height / 2 }
            
            PathAttribute { name: "itemScale"; value: 0.6 }
            PathAttribute { name: "itemOpacity"; value: 0.3 }
            PathAttribute { name: "itemZ"; value: 0 }
        }
        
        delegate: Item {
            id: delegateItem
            width: pathView.width * 0.38
            height: pathView.height * 0.8
            
            scale: PathView.itemScale !== undefined ? PathView.itemScale : 0.6
            opacity: PathView.itemOpacity !== undefined ? PathView.itemOpacity : 0.3
            z: PathView.itemZ !== undefined ? PathView.itemZ : 0
            
            // Получаем данные темы из themeManager
            property var themeData: {
                if (root.themeManager && root.themeManager.themes) {
                    for (var i = 0; i < root.themeManager.themes.length; i++) {
                        if (root.themeManager.themes[i].file === modelData) {
                            return root.themeManager.themes[i]
                        }
                    }
                }
                return null
            }
            
            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 4
                height: parent.height - 4
                radius: 16
                color: Qt.rgba(0, 0, 0, 0.5)
                y: parent.y + 8
                opacity: PathView.isCurrentItem ? 0.7 : 0.25
            }

            Rectangle {
                id: card
                anchors.fill: parent
                radius: 14
                color: delegateItem.themeData && delegateItem.themeData.colors ? 
                       delegateItem.themeData.colors.surface : "#2A2A35"
                border.width: PathView.isCurrentItem ? 2 : 1
                border.color: PathView.isCurrentItem ? 
                               (delegateItem.themeData && delegateItem.themeData.colors ? 
                                delegateItem.themeData.colors.accent : "#5B9BFF") : 
                               Qt.rgba(1, 1, 1, 0.15)
                
                // Превью темы
                Rectangle {
                    id: previewArea
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 10
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    height: parent.height * 0.5
                    radius: 8
                    color: delegateItem.themeData && delegateItem.themeData.colors ? 
                           delegateItem.themeData.colors.background : "#181818"
                    clip: true

                    // Мини топбар
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 16
                        color: delegateItem.themeData && delegateItem.themeData.colors ? 
                               delegateItem.themeData.colors.surface : "#1A1F26"

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 5
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3

                            Repeater {
                                model: 3
                                delegate: Rectangle {
                                    width: 5
                                    height: 5
                                    radius: 2.5
                                    color: index === 0 ? 
                                           (delegateItem.themeData && delegateItem.themeData.colors ? 
                                            delegateItem.themeData.colors.accent : "#5B9BFF") : 
                                           Qt.rgba(1,1,1,0.2)
                                }
                            }
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 5
                            anchors.verticalCenter: parent.verticalCenter
                            text: "12:00"
                            color: delegateItem.themeData && delegateItem.themeData.colors ? 
                                   delegateItem.themeData.colors.text : "#FFF"
                            font.pixelSize: 6
                            font.bold: true
                        }
                    }

                    Column {
                        anchors.top: parent.bottom
                        anchors.topMargin: -parent.height + 20
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 7
                        spacing: 4

                        Rectangle {
                            width: parent.width * 0.7
                            height: 7
                            radius: 3.5
                            color: delegateItem.themeData && delegateItem.themeData.colors ? 
                                   delegateItem.themeData.colors.text : "#FFF"
                            opacity: 0.8
                        }

                        Rectangle {
                            width: parent.width * 0.5
                            height: 5
                            radius: 2.5
                            color: delegateItem.themeData && delegateItem.themeData.colors ? 
                                   delegateItem.themeData.colors.textSecondary : "#AAA"
                            opacity: 0.6
                        }

                        Rectangle {
                            width: 36
                            height: 12
                            radius: 6
                            color: delegateItem.themeData && delegateItem.themeData.colors ? 
                                   delegateItem.themeData.colors.accent : "#5B9BFF"

                            Text {
                                anchors.centerIn: parent
                                text: "Button"
                                color: delegateItem.themeData && delegateItem.themeData.colors ? 
                                       delegateItem.themeData.colors.textSelected : "#FFF"
                                font.pixelSize: 5
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
                    anchors.topMargin: 6
                    text: delegateItem.themeData && delegateItem.themeData.name ? 
                          delegateItem.themeData.name : modelData
                    color: delegateItem.themeData && delegateItem.themeData.colors ? 
                           delegateItem.themeData.colors.text : "#FFF"
                    font.pixelSize: 12
                    font.bold: true
                }

                // Цветовая палитра
                Row {
                    anchors.top: themeNameText.bottom
                    anchors.topMargin: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 4

                    Repeater {
                        model: delegateItem.themeData && delegateItem.themeData.colors ? 
                               [
                                   delegateItem.themeData.colors.background,
                                   delegateItem.themeData.colors.surface,
                                   delegateItem.themeData.colors.accent,
                                   delegateItem.themeData.colors.text
                               ] : []
                        delegate: Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: modelData || "#888"
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.15)
                        }
                    }
                }

                // Индикатор текущей темы
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 6
                    width: currentLabel.width + 12
                    height: 16
                    radius: 8
                    color: root.themeManager && root.themeManager.currentTheme === modelData ?
                           (delegateItem.themeData && delegateItem.themeData.colors ? 
                            delegateItem.themeData.colors.accent : "#5B9BFF") :
                           Qt.rgba(0, 0, 0, 0.3)
                    opacity: PathView.isCurrentItem ? 1 : 0

                    Behavior on opacity { NumberAnimation { duration: 200 } }

                    Text {
                        id: currentLabel
                        anchors.centerIn: parent
                        text: root.themeManager && root.themeManager.currentTheme === modelData ? 
                              "✓ Current" : "↵ Apply"
                        color: root.themeManager && root.themeManager.currentTheme === modelData ?
                               (delegateItem.themeData && delegateItem.themeData.colors ? 
                                delegateItem.themeData.colors.textSelected : "#FFF") : "#FFF"
                        font.pixelSize: 8
                        font.bold: true
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (PathView.isCurrentItem) {
                            applyProcess.themeName = modelData
                            applyProcess.running = true
                            if (root.soundManager) root.soundManager.play("quick_click.wav")
                            root.close()
                        } else {
                            pathView.currentIndex = index
                        }
                    }
                }
            }
        }
        
        onCurrentIndexChanged: {
            root.currentIndex = currentIndex
            
            // Пропускаем первое срабатывание (позиционирование при открытии)
            if (root.isFirstChange) {
                root.isFirstChange = false
                return
            }
            
            if (root.soundManager) {
                root.soundManager.play("in.wav")
            }
        }
    }

    // Градиенты по краям
    Rectangle {
        anchors.left: parent.left
        anchors.top: pathView.top
        anchors.bottom: pathView.bottom
        width: 40
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: root.theme.colors.surface }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }
    
    Rectangle {
        anchors.right: parent.right
        anchors.top: pathView.top
        anchors.bottom: pathView.bottom
        width: 40
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: root.theme.colors.surface }
        }
    }

    // Стрелка влево (ЗВУК УБРАН — теперь в onCurrentIndexChanged)
    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 8
        width: 32
        height: 32
        radius: 16
        color: leftMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }
        
        Text {
            anchors.centerIn: parent
            text: "‹"
            color: root.theme.colors.text || "#FFF"
            font.pixelSize: 26
            font.bold: true
        }
        
        MouseArea {
            id: leftMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                pathView.decrementCurrentIndex()
            }
        }
    }

    // Стрелка вправо (ЗВУК УБРАН — теперь в onCurrentIndexChanged)
    Rectangle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 8
        width: 32
        height: 32
        radius: 16
        color: rightMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }
        
        Text {
            anchors.centerIn: parent
            text: "›"
            color: root.theme.colors.text || "#FFF"
            font.pixelSize: 26
            font.bold: true
        }
        
        MouseArea {
            id: rightMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                pathView.incrementCurrentIndex()
            }
        }
    }

    // Индикаторы
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        spacing: 7
        
        Repeater {
            model: Math.min(root.themesList.length, 15)
            delegate: Rectangle {
                property bool isActive: index === root.currentIndex
                width: isActive ? 18 : 6
                height: 6
                radius: 3
                color: isActive ? 
                       (root.theme.colors.accent || "#5B9BFF") : 
                       (root.theme.colors.textSecondary || "#AAA")
                opacity: isActive ? 1 : 0.35
                Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 250 } }
            }
        }
    }

    function navigateLeft() {
        pathView.decrementCurrentIndex()
    }
    
    function navigateRight() {
        pathView.incrementCurrentIndex()
    }
    
    function applyCurrent() {
        if (themesList.length > 0) {
            var fileName = themesList[currentIndex]
            applyProcess.themeName = fileName
            applyProcess.running = true
            if (soundManager) soundManager.play("quick_click.wav")
            close()
        }
    }
}