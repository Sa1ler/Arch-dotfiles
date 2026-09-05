import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    property var theme: null
    property var appList: []
    property var soundManager: null
    property bool windowVisible: false
    property string searchText: ""
    property var allApps: []
    
    signal launchApp(string appName, string execCmd)

    property var filteredApps: {
        var q = searchText.toLowerCase().trim()
        var result = []
        
        if (q.length === 0) {
            return allApps.slice(0, 20)
        }
        
        for (var i = 0; i < allApps.length; i++) {
            var app = allApps[i]
            var nameLower = app.name.toLowerCase()
            
            var matchScore = 0
            var matches = false
            
            if (nameLower === q) {
                matchScore = 100000
                matches = true
            } else if (nameLower.startsWith(q)) {
                matchScore = 50000
                matches = true
            } else if (nameLower.indexOf(q) !== -1) {
                matchScore = 10000
                matches = true
            } else if (isSubsequence(q, nameLower)) {
                matchScore = 1000
                matches = true
            }
            
            if (matches) {
                var appCopy = Object.assign({}, app)
                appCopy.matchScore = matchScore + (app.usageScore || 0)
                result.push(appCopy)
            }
        }
        
        result.sort(function(a, b) {
            if (a.matchScore !== b.matchScore) return b.matchScore - a.matchScore
            return a.name.localeCompare(b.name)
        })
        
        return result.slice(0, 20)
    }

    function isSubsequence(sub, str) {
        var i = 0
        var j = 0
        while (i < sub.length && j < str.length) {
            if (sub[i] === str[j]) i++
            j++
        }
        return i === sub.length
    }

    onAppListChanged: {
        allApps = appList.slice()
    }

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

    // Улучшенные анимации открытия/закрытия
    property real animScale: windowVisible ? 1.0 : 0.92
    property real animOpacity: windowVisible ? 1.0 : 0.0
    
    Behavior on animScale {
        NumberAnimation {
            duration: windowVisible ? 380 : 220
            easing.type: windowVisible ? Easing.OutBack : Easing.InCubic
            easing.overshoot: windowVisible ? 1.1 : 0
        }
    }
    
    Behavior on animOpacity {
        NumberAnimation {
            duration: windowVisible ? 300 : 200
            easing.type: windowVisible ? Easing.OutCubic : Easing.InQuad
        }
    }

    onWindowVisibleChanged: {
        if (windowVisible) {
            visible = true
            searchText = ""
            searchInput.forceActiveFocus()
            focusTimer.restart()
        } else {
            hideTimer.restart()
        }
    }

    Timer {
        id: hideTimer
        interval: 250
        onTriggered: {
            if (!root.windowVisible) {
                root.visible = false
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        onTriggered: searchInput.forceActiveFocus()
    }

    FocusScope {
        id: focusScope
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: function(event) {
            if (searchInput.text !== "") {
                searchInput.text = ""
            } else {
                root.windowVisible = false
            }
            event.accepted = true
        }
        
        Keys.onReturnPressed: function(event) {
            activateIndex(appsListView.currentIndex)
            event.accepted = true
        }
        
        Keys.onDownPressed: function(event) {
            if (appsListView.currentIndex < appsListView.count - 1) {
                appsListView.currentIndex++
                if (root.soundManager) root.soundManager.playDebounced("in.wav")
            }
            event.accepted = true
        }
        
        Keys.onUpPressed: function(event) {
            if (appsListView.currentIndex > 0) {
                appsListView.currentIndex--
                if (root.soundManager) root.soundManager.playDebounced("in.wav")
            }
            event.accepted = true
        }

        // Основной контейнер с фиксированной высотой
        Item {
            id: container
            
            property real baseWidth: 440
            property real itemHeight: 44
            property real maxVisibleItems: 6
            property real searchHeight: 56
            property real padding: 12
            property real listHeight: searchHeight + padding * 2 + maxVisibleItems * (itemHeight + 2) + 8
            
            anchors.centerIn: parent
            width: baseWidth
            height: listHeight
            
            scale: root.animScale
            opacity: root.animOpacity
            
            // Главный кард
            Rectangle {
                id: bgCard
                anchors.fill: parent
                radius: 20
                color: root.theme && root.theme.colors ? root.theme.colors.background : "#181818"
                border.width: 1
                border.color: root.theme && root.theme.colors ? root.theme.colors.border : "#333"
                clip: true
                
                // Тонкий градиент сверху
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 70
                    radius: 20
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.03) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                
                // Поиск
                Rectangle {
                    id: searchBox
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 12
                    height: 48
                    radius: 14
                    color: root.theme.colors.surface || "#1A1F26"
                    border.width: searchInput.activeFocus ? 2 : 1
                    border.color: searchInput.activeFocus ? 
                                  (root.theme.colors.accent || "#5B9BFF") : 
                                  (root.theme.colors.border || "#333")
                    
                    Behavior on border.color { ColorAnimation { duration: 200 } }
                    
                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 10
                        spacing: 10
                        
                        Text {
                            text: ""
                            color: searchInput.activeFocus ? 
                                   (root.theme.colors.accent || "#5B9BFF") : 
                                   (root.theme.colors.textDisabled || "#666")
                            font.pixelSize: 16
                            font.family: "JetBrainsMono Nerd Font"
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        
                        TextInput {
                            id: searchInput
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 70
                            color: root.theme.colors.text || "#FFF"
                            font.pixelSize: 15
                            clip: true
                            selectByMouse: true
                            focus: true
                            
                            onTextChanged: {
                                root.searchText = text
                                if (appsListView.count > 0) {
                                    appsListView.currentIndex = 0
                                }
                            }
                            
                            Keys.onEscapePressed: function(event) {
                                if (searchInput.text !== "") {
                                    searchInput.text = ""
                                } else {
                                    root.windowVisible = false
                                }
                                event.accepted = true
                            }
                            
                            Keys.onReturnPressed: function(event) {
                                activateIndex(appsListView.currentIndex)
                                event.accepted = true
                            }
                            
                            Keys.onDownPressed: function(event) {
                                if (appsListView.currentIndex < appsListView.count - 1) {
                                    appsListView.currentIndex++
                                    if (root.soundManager) root.soundManager.playDebounced("in.wav")
                                }
                                event.accepted = true
                            }
                            
                            Keys.onUpPressed: function(event) {
                                if (appsListView.currentIndex > 0) {
                                    appsListView.currentIndex--
                                    if (root.soundManager) root.soundManager.playDebounced("in.wav")
                                }
                                event.accepted = true
                            }
                            
                            Text {
                                anchors.fill: parent
                                text: "Search apps..."
                                color: root.theme.colors.textDisabled || "#666"
                                font.pixelSize: 14
                                visible: searchInput.text === ""
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        
                        Rectangle {
                            width: 24
                            height: 24
                            radius: 12
                            color: clearMouse.containsMouse ? Qt.rgba(1,1,1,0.08) : "transparent"
                            anchors.verticalCenter: parent.verticalCenter
                            visible: searchInput.text !== ""
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: root.theme.colors.textSecondary || "#AAA"
                                font.pixelSize: 11
                            }
                            
                            MouseArea {
                                id: clearMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    searchInput.text = ""
                                    searchInput.forceActiveFocus()
                                }
                            }
                        }
                    }
                }
                
                // Список приложений со скроллингом
                Item {
                    id: listContainer
                    anchors.top: searchBox.bottom
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 8
                    anchors.topMargin: 6
                    clip: true
                    
                    ListView {
                        id: appsListView
                        anchors.fill: parent
                        clip: true
                        model: root.filteredApps
                        currentIndex: 0
                        spacing: 2
                        boundsBehavior: Flickable.StopAtBounds
                        flickableDirection: Flickable.VerticalFlick
                        
                        // ИСПРАВЛЕНИЕ СКРОЛЛИНГА: используем highlightRangeMode
                        highlightFollowsCurrentItem: true
                        highlightRangeMode: ListView.ApplyRange
                        preferredHighlightBegin: height * 0.35
                        preferredHighlightEnd: height * 0.65
                        highlightMoveDuration: 200
                        highlightMoveVelocity: -1
                        
                        // Морфинг хайлайт
                        Rectangle {
                            id: morphHighlight
                            parent: appsListView.contentItem
                            z: 0
                            visible: appsListView.count > 0 && appsListView.currentIndex >= 0 && opacity > 0.001
                            opacity: (appsListView.count > 0 && appsListView.currentIndex >= 0 && appsListView.currentItem !== null) ? 1.0 : 0.0
                            
                            Behavior on opacity { NumberAnimation { duration: 170 } }
                            
                            x: 2
                            width: appsListView.width - 4
                            height: 42
                            radius: 12
                            
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: root.theme.colors.accent || "#5B9BFF" }
                                GradientStop { position: 1.0; color: Qt.lighter(root.theme.colors.accent || "#5B9BFF", 1.15) }
                            }
                            
                            property real targetY: (appsListView.currentIndex >= 0 && appsListView.currentItem) ? appsListView.currentItem.y : 0
                            y: targetY
                            
                            Behavior on y {
                                NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
                            }
                            
                            // Блик
                            Rectangle {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: parent.height / 2
                                radius: 12
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.15) }
                                    GradientStop { position: 1.0; color: "transparent" }
                                }
                            }
                        }
                        
                        add: Transition {
                            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 220; easing.type: Easing.OutCubic }
                            NumberAnimation { property: "y"; from: 8; duration: 240; easing.type: Easing.OutCubic }
                        }
                        
                        remove: Transition {
                            NumberAnimation { property: "opacity"; to: 0; duration: 150 }
                        }
                        
                        displaced: Transition {
                            NumberAnimation { properties: "y"; duration: 240; easing.type: Easing.OutCubic }
                        }
                        
                        move: Transition {
                            NumberAnimation { properties: "y"; duration: 240; easing.type: Easing.OutCubic }
                        }
                        
                        delegate: Item {
                            id: delegateRoot
                            width: ListView.view ? ListView.view.width : 0
                            height: 42
                            clip: true
                            z: 1
                            
                            property bool isSelected: index === appsListView.currentIndex
                            
                            Item {
                                id: delegateContent
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                
                                scale: ma.pressed ? 0.98 : 1.0
                                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
                                
                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: delegateRoot.isSelected ? 2 : 0
                                    spacing: 12
                                    
                                    Behavior on anchors.leftMargin { NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1.15 } }
                                    
                                    // Точка-индикатор
                                    Rectangle {
                                        width: 3
                                        height: 16
                                        radius: 1.5
                                        color: "#FFF"
                                        anchors.verticalCenter: parent.verticalCenter
                                        opacity: delegateRoot.isSelected ? 1 : 0
                                        
                                        Behavior on opacity { NumberAnimation { duration: 180 } }
                                    }
                                    
                                    // Иконка
                                    Rectangle {
                                        width: 28
                                        height: 28
                                        radius: 9
                                        color: delegateRoot.isSelected ? 
                                               Qt.rgba(0, 0, 0, 0.25) : 
                                               (root.theme.colors.surface || "#1A1F26")
                                        anchors.verticalCenter: parent.verticalCenter
                                        
                                        Behavior on color { ColorAnimation { duration: 180 } }
                                        
                                        Image {
                                            id: delegateIcon
                                            anchors.fill: parent
                                            anchors.margins: 4
                                            sourceSize: Qt.size(28, 28)
                                            fillMode: Image.PreserveAspectFit
                                            asynchronous: true
                                            smooth: true
                                            cache: true
                                            
                                            property bool loadFailed: false
                                            
                                            source: {
                                                var ic = modelData.icon || ""
                                                if (!ic) {
                                                    loadFailed = true
                                                    return ""
                                                }
                                                if (ic.indexOf("/") === 0) return "file://" + ic
                                                if (ic.indexOf("file://") === 0 || ic.indexOf("image://") === 0) return ic
                                                return "image://icon/" + ic
                                            }
                                            
                                            onStatusChanged: {
                                                if (status === Image.Error || status === Image.Null) {
                                                    loadFailed = true
                                                } else if (status === Image.Ready) {
                                                    loadFailed = false
                                                }
                                            }
                                            
                                            visible: !loadFailed && source !== "" && status === Image.Ready
                                        }
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            visible: delegateIcon.loadFailed || delegateIcon.source === ""
                                            text: ""
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 14
                                            color: delegateRoot.isSelected ? "#FFF" : (root.theme.colors.textSecondary || "#AAA")
                                        }
                                    }
                                    
                                    // Название
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - 70
                                        text: modelData.name
                                        font.pixelSize: 14
                                        font.bold: delegateRoot.isSelected
                                        color: delegateRoot.isSelected ? "#FFF" : (root.theme.colors.text || "#FFF")
                                        elide: Text.ElideRight
                                        
                                        Behavior on color { ColorAnimation { duration: 180 } }
                                    }
                                    
                                    // Стрелка запуска
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: ""
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 12
                                        color: "#FFF"
                                        opacity: delegateRoot.isSelected ? 0.9 : 0
                                        x: delegateRoot.isSelected ? 0 : -8
                                        
                                        Behavior on opacity { NumberAnimation { duration: 200 } }
                                        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                                    }
                                }
                                
                                MouseArea {
                                    id: ma
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    
                                    onClicked: {
                                        appsListView.currentIndex = index
                                        activateIndex(index)
                                    }
                                    
                                    onContainsMouseChanged: {
                                        if (containsMouse) {
                                            appsListView.currentIndex = index
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Пустое состояние
                        Column {
                            anchors.centerIn: parent
                            visible: appsListView.count === 0 && root.animOpacity > 0.5
                            spacing: 8
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: ""
                                color: root.theme.colors.textDisabled || "#555"
                                font.pixelSize: 32
                                font.family: "JetBrainsMono Nerd Font"
                                opacity: 0.4
                            }
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Nothing found"
                                color: root.theme.colors.textDisabled || "#666"
                                font.pixelSize: 13
                            }
                        }
                        
                        // Скроллбар
                        ScrollBar.vertical: ScrollBar {
                            width: 4
                            policy: ScrollBar.AsNeeded
                            
                            contentItem: Rectangle {
                                radius: 2
                                color: root.theme.colors.surfaceHover || "#444"
                                opacity: 0.6
                            }
                        }
                    }
                }
            }
        }
    }

    function activateIndex(index) {
        if (index < 0 || index >= appsListView.count) return
        var item = root.filteredApps[index]
        if (!item) return
        
        root.launchApp(item.name, item.exec)
    }
}