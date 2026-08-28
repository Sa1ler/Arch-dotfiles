import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../base"


Item {


    id: root



    property string layout: "EN"



    implicitWidth: keyboardRow.implicitWidth + 24

    implicitHeight: 33






    Behavior on y {


        NumberAnimation {


            duration: 120

            easing.type: Easing.OutCubic

        }

    }






    Behavior on scale {


        NumberAnimation {


            duration: 120

            easing.type: Easing.OutCubic

        }

    }








    Process {


        id: layoutProc



        command: [

            "bash",

            "-c",

            "hyprctl devices -j | jq -r '.keyboards[] | select(.main==true) | .active_keymap'"

        ]





        stdout: StdioCollector {


            onStreamFinished: {


                let out = text.trim().toLowerCase()



                if (out.indexOf("russian") !== -1 || out.indexOf("рус") !== -1)

                    root.layout = "RU"

                else

                    root.layout = "EN"


            }

        }

    }








    Timer {


        interval: 300


        running: true


        repeat: true



        onTriggered: {


            layoutProc.running = true


        }

    }








    Process {


        id: switchLayout



        command: [

            "hyprctl",

            "switchxkblayout",

            "at-translated-set-2-keyboard",

            "next"

        ]

    }









    MouseArea {


        anchors.fill: parent



        hoverEnabled: true



        cursorShape: Qt.PointingHandCursor






        onEntered: {


            root.y = -2

            root.scale = 1.03


        }





        onExited: {


            root.y = 0

            root.scale = 1.0


        }






        onClicked: {


            switchLayout.running = true


        }

    }









    RowLayout {


        id: keyboardRow



        anchors.centerIn: parent



        spacing: 5







        Image {


            Layout.preferredWidth: 17

            Layout.preferredHeight: 18



            source: "../../assets/icons/keyboard.svg"



            fillMode: Image.PreserveAspectFit



            smooth: true

        }







        Text {


            text: root.layout



            color: "#ffffff"



            font.family: "JetBrains Mono"



            font.pixelSize: 13



            font.bold: true



            verticalAlignment: Text.AlignVCenter

        }

    }

}
