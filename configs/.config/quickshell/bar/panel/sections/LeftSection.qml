import QtQuick

import "../../widgets"

Item {
    id: root

    property var theme: null
    property var soundManager: null
    
    implicitHeight: workspacesWidget.implicitHeight
    implicitWidth: workspacesWidget.implicitWidth + 8

    Workspaces {
        id: workspacesWidget
        anchors.centerIn: parent
        
        theme: root.theme
        soundManager: root.soundManager
    }
}