import QtQuick
import Quickshell
import Quickshell.Io
import "../base"


Module {

    id: root


    signal clicked(var source)



    moduleHeight: 33
    moduleWidth: wifiRow.implicitWidth + 12



    property string ssid: "Off"

    property string wifiState: "off"






    Process {


        id: wifiProcess



        command: [

            "sh",

            "-c",

            "WIFI=$(nmcli radio wifi); if [ \"$WIFI\" = \"disabled\" ]; then echo off; else SSID=$(LANG=C nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes:' | cut -d: -f2-); if [ -n \"$SSID\" ]; then echo connected:$SSID; else echo enabled; fi; fi"

        ]





        stdout: StdioCollector {


            onStreamFinished: {


                let result = this.text.trim()



                if (result.startsWith("connected:")) {


                    root.wifiState = "connected"

                    root.ssid = result.substring(10)


                }

                else if (result === "enabled") {


                    root.wifiState = "enabled"

                    root.ssid = "On"


                }

                else {


                    root.wifiState = "off"

                    root.ssid = "Off"

                }

            }

        }

    }







    Timer {


        interval: 3000

        running: true

        repeat: true



        onTriggered: wifiProcess.running = true

    }







    Component.onCompleted: wifiProcess.running = true








    Rectangle {


        anchors.fill: parent


        anchors.margins: 4



        radius: 6





        gradient: Gradient {



            GradientStop {


                position: 0



                color:


                    root.wifiState === "connected"


                    ? "#3675ff"


                    : root.wifiState === "enabled"


                        ? "#b06b55"


                        : "#555555"


            }





            GradientStop {


                position: 1



                color:


                    root.wifiState === "connected"


                    ? "#3675ff"


                    : root.wifiState === "enabled"


                        ? "#b06b55"


                        : "#555555"


            }

        }







        Row {


            id: wifiRow



            anchors.centerIn: parent



            spacing: 6






            Item {


                width:18

                height:18





                Image {


                    anchors.centerIn: parent



                    source:"../../assets/icons/wifi.svg"



                    width:17

                    height:17



                    smooth:true

                }





                Rectangle {


                    visible: root.wifiState === "off"



                    width:23

                    height:2



                    radius:2



                    color:"#111111"



                    rotation:-45



                    anchors.centerIn:parent

                }

            }






            Text {


                text:root.ssid



                color:"#111111"



                font.pixelSize:13

                font.weight:Font.DemiBold


            }

        }

    }







    MouseArea {


        anchors.fill:parent



        hoverEnabled:true



        cursorShape:Qt.PointingHandCursor





        onEntered:{


            root.y=-2

            root.scale=1.03


        }





        onExited:{


            root.y=0

            root.scale=1


        }







        onClicked:{


            root.clicked(root)


        }

    }

}
