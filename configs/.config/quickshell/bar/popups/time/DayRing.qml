import QtQuick


Item {

    id: root


    width: 360
    height: 360



    property real rotationAngle: 0


    property real radiusX: 150


    property real radiusY: 90



    property real velocity: 0



    property int activeDay:
        (new Date().getDay() + 6) % 7




    property var days: [

        "ПН",
        "ВТ",
        "СР",
        "ЧТ",
        "ПТ",
        "СБ",
        "ВС"

    ]




    property var months: [

        "ЯНВАРЯ",
        "ФЕВРАЛЯ",
        "МАРТА",
        "АПРЕЛЯ",
        "МАЯ",
        "ИЮНЯ",
        "ИЮЛЯ",
        "АВГУСТА",
        "СЕНТЯБРЯ",
        "ОКТЯБРЯ",
        "НОЯБРЯ",
        "ДЕКАБРЯ"

    ]







    Timer {


        interval:16


        running:true


        repeat:true



        onTriggered:{


            if(Math.abs(root.velocity) > 0.01){


                root.rotationAngle += root.velocity


                root.velocity *= 0.94


            }


        }


    }







    // АВТОМАТИЧЕСКОЕ ПЛАВНОЕ ДВИЖЕНИЕ


    Timer {


        interval:40


        running:true


        repeat:true



        onTriggered:{


            root.rotationAngle += 0.08


        }


    }









    // ТОЧКИ ОРБИТЫ


    Repeater {


        model:90



        Rectangle {


            width:3


            height:3



            radius:2



            property real angle:


                index * 360 / 90






            x:


                root.width / 2

                +

                Math.cos(

                    (angle + root.rotationAngle)

                    *

                    Math.PI / 180

                )

                *

                root.radiusX

                -

                width / 2







            y:


                root.height / 2

                +

                Math.sin(

                    (angle + root.rotationAngle)

                    *

                    Math.PI / 180

                )

                *

                root.radiusY

                -

                height / 2







            opacity:


                0.15

                +

                (

                    Math.sin(

                        (angle + root.rotationAngle)

                        *

                        Math.PI / 180

                    )

                    +

                    1

                )

                *

                0.3





            color:"#b8ddff"


        }

    }









    // ДНИ НЕДЕЛИ


    Repeater {


        model:7





        Rectangle {


            id:dayCard



            width:56


            height:30



            radius:15







            property real angle:


                index * 360 / 7







            property real depth:


                Math.sin(

                    (angle + root.rotationAngle)

                    *

                    Math.PI / 180

                )








            property real scaleValue:


                0.78

                +

                (

                    depth + 1

                )

                *

                0.12







            x:


                root.width / 2

                +

                Math.cos(

                    (angle + root.rotationAngle)

                    *

                    Math.PI / 180

                )

                *

                root.radiusX

                -

                width / 2







            y:


                root.height / 2

                +

                Math.sin(

                    (angle + root.rotationAngle)

                    *

                    Math.PI / 180

                )

                *

                root.radiusY

                -

                height / 2







            scale:scaleValue







            z:depth * 20







            opacity:


                0.35

                +

                (

                    depth + 1

                )

                *

                0.32







            color:


                index === root.activeDay

                ?

                "#3355aaff"

                :

                "#55222222"








            border.width:1



            border.color:


                index === root.activeDay

                ?

                "#88bfefff"

                :

                "#33557788"







            Behavior on x {


                NumberAnimation {


                    duration:120


                    easing.type:Easing.OutCubic


                }

            }





            Behavior on y {


                NumberAnimation {


                    duration:120


                    easing.type:Easing.OutCubic


                }

            }





            Behavior on scale {


                NumberAnimation {


                    duration:150


                    easing.type:Easing.OutCubic


                }

            }







            Text {


                anchors.centerIn:parent


                text:root.days[index]


                color:"#eeeeee"


                font.family:"JetBrains Mono"


                font.pixelSize:12


                font.bold:true


            }


        }


    }
        // ЦЕНТРАЛЬНЫЕ ЧАСЫ


    Column {


        anchors.centerIn: parent


        spacing:4






        Text {


            id:dateText


            anchors.horizontalCenter:parent.horizontalCenter



            text:""



            color:"#9fcfff"



            font.family:"JetBrains Mono"



            font.pixelSize:14



            font.bold:true



            opacity:0.85


        }









        Item {


            width:240

            height:75



            anchors.horizontalCenter:parent.horizontalCenter





            // МЯГКОЕ СВЕЧЕНИЕ


            Text {


                anchors.centerIn:parent



                text:clockText.text



                color:"#5599ff"



                opacity:0.35



                scale:1.05



                font.family:"JetBrains Mono"



                font.pixelSize:58



                font.bold:true


            }







            // ОСНОВНОЙ ТЕКСТ


            Text {


                id:clockText



                anchors.centerIn:parent



                text:"00:00"



                color:"#f3f8ff"



                font.family:"JetBrains Mono"



                font.pixelSize:58



                font.bold:true



            }


        }









        Text {


            id:secondsText



            anchors.horizontalCenter:parent.horizontalCenter



            text:"00"



            color:"#77bbff"



            font.family:"JetBrains Mono"



            font.pixelSize:30



            font.bold:true



            font.letterSpacing:4


        }


    }









    // АНИМАЦИЯ СЕКУНД


    SequentialAnimation {


        id:secondPulse



        running:false





        NumberAnimation {


            target:secondsText


            property:"scale"



            from:1


            to:1.15



            duration:120


        }







        NumberAnimation {


            target:secondsText


            property:"scale"



            from:1.15


            to:1



            duration:180


        }


    }









    // ОБНОВЛЕНИЕ ВРЕМЕНИ


    Timer {


        interval:1000


        running:true


        repeat:true





        onTriggered:{


            let now = new Date()







            clockText.text =


                now.getHours()

                .toString()

                .padStart(2,"0")

                +

                ":"

                +

                now.getMinutes()

                .toString()

                .padStart(2,"0")







            secondsText.text =


                now.getSeconds()

                .toString()

                .padStart(2,"0")







            dateText.text =


                now.getDate()

                +

                " "

                +

                root.months[now.getMonth()]







            secondPulse.restart()


        }


    }









    // ВРАЩЕНИЕ КОЛЕСОМ МЫШИ


    WheelHandler {


        onWheel:{


            root.velocity +=


                wheel.angleDelta.y / 250



        }


    }









    // ОБНОВЛЕНИЕ ТЕКУЩЕГО ДНЯ


    Timer {


        interval:60000


        running:true


        repeat:true





        onTriggered:{


            root.activeDay =


                (new Date().getDay() + 6) % 7


        }


    }







}
