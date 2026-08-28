import QtQuick
import Quickshell
import Quickshell.Wayland
import "../modules/widgets"
import "../popups/time"

PanelWindow {
    id: panel

    anchors.top: true
    anchors.left: true
    anchors.right: true

    implicitHeight: 42
    color: "transparent"

    // Один общий фон
    Rectangle {
        id: barBg

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        width: 830
        height: 30
        radius: 12
        color: "#181818"

        // ===== Левый сектор: рабочие пространства =====
        Item {
            id: wsContainer

            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.verticalCenter: parent.verticalCenter

            width: wsRow.implicitWidth
            height: 30

            Row {
                id: wsRow

                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                Workspaces {
                    height: 30
                }
            }
        }

        // ===== Центральный сектор: часы и дата =====
        Item {
            id: clockContainer

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            width: 160
            height: 30

            Clock {
                anchors.centerIn: parent

                onClicked: timePopup.open(clock)
            }
        }

        // ===== Правая область: модули =====
        Item {
            id: rightContainer

            anchors.right: parent.right
            anchors.rightMargin: 15
            anchors.verticalCenter: parent.verticalCenter

            width: rightRow.implicitWidth
            height: 30

            Row {
                id: rightRow

                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                Keyboard {
                    height: 30
                }

                Wifi {
                    id: wifi
                    height: 30
                }

                Volume {
                    height: 30
                }

                Battery {
                    height: 30
                }
            }
        }

        TimePopup {
            id: timePopup
        }
    }
}
