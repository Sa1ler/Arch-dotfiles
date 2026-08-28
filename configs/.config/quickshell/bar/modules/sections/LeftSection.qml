import QtQuick 2.15
import "../base"
import "../widgets"

Item {
    width: workspacesRow.implicitWidth
    height: 33

    Row {
        id: workspacesRow
        anchors.centerIn: parent
        spacing: 0

        Workspaces { height: 33 }
    }
}
