import QtQuick
import Quickshell
import Quickshell.Wayland

import "sections"

PanelWindow {
    id: root

    property var theme: null
    property var soundManager: null
    
    // Высота бара (корректируется пользователем)
    property real barHeight: barContent.implicitHeight - 10
    
    // ===== ВИЗУАЛЬНЫЕ ПАРАМЕТРЫ =====
    property real topMargin: 6          // Отступ от верхнего края экрана
    property real sideMargin: 3         // Отступ от боковых краёв экрана
    property real sectionSpacing: 100   // Промежуток между секторами
    property real sectionRadius: 14     // Закругление углов секторов
    property real sectionPadding: 6     // Внутренний отступ секторов
    
    // ===== РАЗМЕРЫ СЕКТОРОВ (0 = автоматический по содержимому) =====
    property real leftSectionWidth: 0     // Ширина левого сектора
    property real centerSectionWidth: 0   // Ширина центрального сектора
    property real rightSectionWidth: 0    // Ширина правого сектора

    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }

    exclusiveZone: barHeight
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Контент бара
    Item {
        id: barContent
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: root.topMargin
        anchors.leftMargin: root.sideMargin
        anchors.rightMargin: root.sideMargin
        height: root.barHeight
        
        implicitHeight: Math.max(
            leftSection.implicitHeight,
            centerSection.implicitHeight,
            rightSection.implicitHeight
        ) + root.sectionPadding * 2
        
        // ===== ЛЕВЫЙ СЕКТОР =====
        Rectangle {
            id: leftSectionBg
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            
            // Ширина: фиксированная если > 0, иначе по содержимому
            width: root.leftSectionWidth > 0 ? 
                   root.leftSectionWidth : 
                   (leftSection.implicitWidth + root.sectionPadding * 2 + 8)
            
            radius: root.sectionRadius
            color: root.theme && root.theme.colors ? root.theme.colors.surface : "#1A1F26"
            border.width: 1
            border.color: root.theme.colors.border || "#2A2A2A"
            
            LeftSection {
                id: leftSection
                anchors.centerIn: parent
                
                theme: root.theme
                soundManager: root.soundManager
            }
        }
        
        // ===== ЦЕНТРАЛЬНЫЙ СЕКТОР =====
        Rectangle {
            id: centerSectionBg
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            
            // Ширина: фиксированная если > 0, иначе по содержимому
            width: root.centerSectionWidth > 0 ? 
                   root.centerSectionWidth : 
                   (centerSection.implicitWidth + root.sectionPadding * 2 + 8)
            
            radius: root.sectionRadius
            color: root.theme && root.theme.colors ? root.theme.colors.surface : "#1A1F26"
            border.width: 1
            border.color: root.theme.colors.border || "#2A2A2A"
            
            CenterSection {
                id: centerSection
                anchors.centerIn: parent
                
                theme: root.theme
                soundManager: root.soundManager
            }
        }
        
        // ===== ПРАВЫЙ СЕКТОР =====
        Rectangle {
            id: rightSectionBg
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            
            // Ширина: фиксированная если > 0, иначе по содержимому
            width: root.rightSectionWidth > 0 ? 
                   root.rightSectionWidth : 
                   (rightSection.implicitWidth + root.sectionPadding * 2 + 8)
            
            radius: root.sectionRadius
            color: root.theme && root.theme.colors ? root.theme.colors.surface : "#1A1F26"
            border.width: 1
            border.color: root.theme.colors.border || "#2A2A2A"
            
            RightSection {
                id: rightSection
                anchors.centerIn: parent
                
                theme: root.theme
                soundManager: root.soundManager
            }
        }
    }
}