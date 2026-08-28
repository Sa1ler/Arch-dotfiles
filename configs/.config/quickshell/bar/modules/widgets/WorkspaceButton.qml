import QtQuick


Item {

    id: root


    property int workspaceNumber: 1
    property bool active: false
    property bool hovered: false


    signal clicked(int number)



    width: 30
    height: 30




    Text {


        id: numberText


        anchors.centerIn: parent



        text: root.workspaceNumber



        color:

            root.active

            ? "#111111"

            : "#aaaaaa"




        font.pixelSize: 12

        font.bold: true




        y: root.hovered ? -2 : 0


        scale: root.hovered ? 1.12 : 1





        Behavior on y {


            NumberAnimation {


                duration: 150


                easing.type: Easing.OutCubic

            }

        }





        Behavior on scale {


            NumberAnimation {


                duration: 150


                easing.type: Easing.OutCubic

            }

        }

    }







    MouseArea {


        anchors.fill: parent



        hoverEnabled: true



        cursorShape: Qt.PointingHandCursor





        onEntered: {


            root.hovered = true


        }





        onExited: {


            root.hovered = false


        }





        onClicked: {


            root.clicked(root.workspaceNumber)


        }

    }

}
