import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

import "./pages/Personalization"
import "./pages/TopBar"

PanelWindow {
    id: root

    property var theme: null
    property var soundManager: null
    
    property bool windowVisible: false
    property bool panelVisible: false
    
    // === Выбранная вкладка ===
    property int selectedTab: 0
    
    // === Размеры окна ===
    readonly property int windowWidth: 850
    readonly property int windowHeight: 500
    readonly property int sidebarWidth: 170
    
    // === Размеры вкладок ===
    readonly property int tabHeight: 36
    readonly property int tabSpacing: 4
    readonly property int tabPadding: 4
    
    // === Цвета из темы ===
    readonly property color surfaceColor: root.theme && root.theme.colors ? root.theme.colors.surface : "#1A1F26"
    readonly property color textColor: root.theme && root.theme.colors ? root.theme.colors.text : "#FFFFFF"
    readonly property color textSecondaryColor: root.theme && root.theme.colors ? root.theme.colors.textSecondary : "#AAAAAA"
    readonly property color accentColor: root.theme && root.theme.colors ? root.theme.colors.accent : "#5B9BFF"
    readonly property color borderColor: root.theme && root.theme.colors ? root.theme.colors.border : "#333333"
    
    // === Данные вкладок (ДВЕ ВКЛАДКИ) ===
    readonly property var tabs: [
        { name: "Персонализация", icon: "\uf1fc" },  // fa-paint-brush
        { name: "Топбар",         icon: "\uf2d0" }   // fa-window-maximize
    ]
    
    color: "transparent"
    
    anchors {
        top: root.panelVisible
        bottom: root.panelVisible
        left: root.panelVisible
        right: root.panelVisible
    }
    
    exclusiveZone: root.panelVisible ? 0 : -1
    WlrLayershell.layer: root.panelVisible ? WlrLayer.Overlay : WlrLayer.Bottom
    WlrLayershell.keyboardFocus: root.panelVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    
    // === Обработчик клавиш ===
    FocusScope {
        id: focusScope
        anchors.fill: parent
        focus: root.panelVisible
        
        Keys.onEscapePressed: function(event) {
            root.close()
            event.accepted = true
        }
    }

    TopBarManager { id: topbarManager }
    
    // === Клик по прозрачной области = закрытие ===
    MouseArea {
        anchors.fill: parent
        enabled: root.panelVisible
        onClicked: root.close()
    }
    
    // === ВНЕШНИЙ КОНТЕЙНЕР ОКНА ===
    Item {
        id: settingsPanel
        anchors.centerIn: parent
        width: root.windowWidth
        height: root.windowHeight
        
        // === Плавный opacity ===
        opacity: root.windowVisible ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
        
        // === ЭЛЕМЕНТ-МАСКА ===
        Rectangle {
            id: panelMask
            width: root.windowWidth
            height: root.windowHeight
            radius: 18
            color: "white"
        }
        
        // === КОНТЕНТ С ОБРЕЗКОЙ ПО МАСКЕ ===
        Item {
            id: panelContent
            anchors.fill: parent
            
            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: ShaderEffectSource {
                    sourceItem: panelMask
                    hideSource: true
                }
            }
            
            // Фон окна
            Rectangle {
                anchors.fill: parent
                radius: 18
                color: root.surfaceColor
                border.width: 1
                border.color: Qt.rgba(255, 255, 255, 0.08)
            }
            
            // Клик внутри окна НЕ закрывает его
            MouseArea {
                anchors.fill: parent
                onClicked: function(mouse) { mouse.accepted = true }
            }
            
            // === Основной layout ===
            Row {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 0
                
                // === ЛЕВАЯ ПАНЕЛЬ С ВКЛАДКАМИ ===
                Item {
                    id: sidebar
                    width: root.sidebarWidth
                    height: parent.height
                    
                    // Заголовок панели
                    Text {
                        id: sidebarTitle
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.left
                        anchors.rightMargin: root.tabPadding + 10
                        anchors.topMargin: 4
                        text: "Настройки"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        font.letterSpacing: 0.5
                        color: root.textSecondaryColor
                        opacity: 0.7
                    }
                    
                    // Контейнер вкладок
                    Item {
                        id: tabsContainer
                        anchors.top: sidebarTitle.bottom
                        anchors.topMargin: 14
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        
                        // === МОРФИНГ-ХАЙЛАЙТ ===
                        Rectangle {
                            id: tabHighlight
                            x: root.tabPadding
                            width: parent.width - (root.tabPadding * 2)
                            height: root.tabHeight
                            radius: 9
                            color: root.accentColor
                            y: root.selectedTab * (root.tabHeight + root.tabSpacing)
                            z: 0
                            
                            Behavior on y {
                                NumberAnimation { duration: 250; easing.type: Easing.OutQuart }
                            }
                            
                        }
                        
                        // === КНОПКИ ВКЛАДОК ===
                        Column {
                            anchors.fill: parent
                            spacing: root.tabSpacing
                            
                            Repeater {
                                model: root.tabs
                                
                                Item {
                                    id: tabButton
                                    width: parent.width
                                    height: root.tabHeight
                                    
                                    property bool isSelected: index === root.selectedTab
                                    property bool isHovered: tabMouse.containsMouse
                                    
                                    // Фон при наведении
                                    Rectangle {
                                        x: root.tabPadding
                                        width: parent.width - (root.tabPadding * 2)
                                        height: parent.height
                                        radius: 9
                                        color: Qt.rgba(1, 1, 1, 0.05)
                                        opacity: isHovered && !isSelected ? 1 : 0
                                        Behavior on opacity { NumberAnimation { duration: 150 } }
                                    }
                                    
                                    // Контент кнопки
                                    Row {
                                        anchors.fill: parent
                                        anchors.leftMargin: root.tabPadding + 10
                                        spacing: 10
                                        
                                        // Иконка
                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: modelData.icon
                                            font.family: "Font Awesome 6 Free Solid"
                                            font.pixelSize: 16
                                            color: isSelected ? "#000000" : root.textColor
                                            opacity: isSelected ? 1 : (isHovered ? 0.9 : 0.7)
                                            
                                            Behavior on color { ColorAnimation { duration: 200 } }
                                            Behavior on opacity { NumberAnimation { duration: 200 } }
                                        }
                                        
                                        // Название
                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: modelData.name
                                            font.family: "JetBrains Mono"
                                            font.pixelSize: 13
                                            font.weight: isSelected ? Font.Bold : Font.DemiBold
                                            color: isSelected ? "#000000" : root.textColor
                                            opacity: isSelected ? 1 : (isHovered ? 0.9 : 0.7)
                                            
                                            Behavior on color { ColorAnimation { duration: 200 } }
                                            Behavior on opacity { NumberAnimation { duration: 200 } }
                                        }
                                    }
                                    
                                    MouseArea {
                                        id: tabMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        
                                        onClicked: {
                                            if (root.selectedTab !== index) {
                                                root.selectedTab = index
                                                if (root.soundManager) root.soundManager.play("click.wav")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // === РАЗДЕЛИТЕЛЬ ===
                Rectangle {
                    width: 1
                    height: parent.height
                    color: Qt.rgba(255, 255, 255, 0.08)
                }
                
                // === ПРАВАЯ ОБЛАСТЬ С КОНТЕНТОМ ===
                Item {
                    id: contentArea
                    width: parent.width - root.sidebarWidth - 1
                    height: parent.height
                    
                    // === КОНТЕЙНЕР СТРАНИЦ ===
                    Item {
                        anchors.fill: parent
                        anchors.margins: 0
                        
                        // === СТРАНИЦА ПЕРСОНАЛИЗАЦИИ ===
                        PersonalizationPage {
                            anchors.fill: parent
                            theme: root.theme
                            visible: root.selectedTab === 0
                            opacity: visible ? 1 : 0
                            
                            Behavior on opacity {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                            
                            onCloseRequested: root.close()
                        }
                        
                        // === СТРАНИЦА ТОПБАРА ===
                        TopBarPage {
                            anchors.fill: parent
                            theme: root.theme
                            visible: root.selectedTab === 1
                            opacity: visible ? 1 : 0
                            topbarManager: topbarManager
                            
                            Behavior on opacity {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // === Таймер для скрытия окна после анимации ===
    Timer {
        id: hideTimer
        interval: 220
        onTriggered: {
            root.panelVisible = false
        }
    }
    
    function toggle() {
        if (windowVisible) close()
        else open()
    }
    
    function open() {
        if (!windowVisible) {
            panelVisible = true
            windowVisible = true
            focusScope.forceActiveFocus()
            if (soundManager) soundManager.play("open.wav")
        }
    }
    
    function close() {
        if (windowVisible) {
            windowVisible = false
            hideTimer.start()
            if (soundManager) soundManager.play("close.wav")
        }
    }
}