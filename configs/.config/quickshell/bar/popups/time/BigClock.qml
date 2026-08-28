import QtQuick


Item {

    id: root


    width: 280
    height: 65





    property string hours: "00"
    property string minutes: "00"
    property string seconds: "00"

    property string oldSeconds: "00"







    Timer {

        interval: 1000

        running: true

        repeat: true


        onTriggered: {

            updateTime()

        }

    }







    Component.onCompleted: {

        updateTime()

    }








    function updateTime() {


        let now = new Date()



        hours = now.getHours().toString().padStart(2, "0")

        minutes = now.getMinutes().toString().padStart(2, "0")



        let sec =
            now.getSeconds()
            .toString()
            .padStart(2, "0")



        if (sec !== seconds) {

            oldSeconds = seconds

            seconds = sec

            secondsAnimation.restart()

        }

    }








    Row {


        anchors.centerIn: parent



        spacing: 5





        Text {

            text: hours + ":" + minutes + ":"



            color: "#55aaff"



            font.family: "JetBrains Mono"



            font.pixelSize: 56



            font.bold: true



            anchors.verticalCenter: parent.verticalCenter

        }








        Item {


            width: 65

            height: 70



            clip: true



            anchors.verticalCenter: parent.verticalCenter





            Text {


                id: oldSecond



                text: root.oldSeconds



                color: "#55aaff"



                font.family: "JetBrains Mono"



                font.pixelSize: 56



                font.bold: true



                anchors.horizontalCenter: parent.horizontalCenter



                y: 0


            }







            Text {


                id: newSecond



                text: root.seconds



                color: "#55aaff"



                font.family: "JetBrains Mono"



                font.pixelSize: 56



                font.bold: true



                anchors.horizontalCenter: parent.horizontalCenter



                y: 70


            }









            SequentialAnimation {


                id: secondsAnimation





                ParallelAnimation {





                    NumberAnimation {


                        target: oldSecond


                        property: "y"



                        from: 0


                        to: -70



                        duration: 220



                        easing.type: Easing.OutCubic


                    }








                    NumberAnimation {


                        target: newSecond



                        property: "y"



                        from: 70


                        to: 0



                        duration: 220



                        easing.type: Easing.OutCubic


                    }

                }

            }

        }

    }

}
