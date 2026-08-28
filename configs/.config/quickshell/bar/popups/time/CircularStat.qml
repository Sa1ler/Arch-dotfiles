import QtQuick


Item {


    id: root


    width:60

    height:78







    property int value:50

    property string icon:""

    property string label:""









    Canvas {


        id:circle



        width:42

        height:42



        anchors.horizontalCenter:parent.horizontalCenter





        onPaint:{


            let ctx = getContext("2d")



            ctx.clearRect(
                0,
                0,
                width,
                height
            )







            ctx.lineWidth = 5



            ctx.lineCap = "round"







            // фон круга


            ctx.strokeStyle = "#33445566"



            ctx.beginPath()



            ctx.arc(

                21,

                21,

                17,

                0,

                Math.PI * 2

            )



            ctx.stroke()







            // заполнение


            ctx.strokeStyle = "#55aaff"



            ctx.beginPath()



            ctx.arc(

                21,

                21,

                17,

                -Math.PI / 2,

                -Math.PI / 2 +

                Math.PI * 2 * (

                    root.value / 100

                )

            )



            ctx.stroke()


        }


    }









    Text {


        anchors.centerIn:circle



        text:root.value + "%"



        color:"#ffffff"



        font.family:"JetBrains Mono"



        font.pixelSize:10



        font.bold:true


    }









    Image {


        anchors.top:circle.bottom



        anchors.topMargin:5



        anchors.horizontalCenter:parent.horizontalCenter



        width:14

        height:14



        source:root.icon



        smooth:true



        fillMode:Image.PreserveAspectFit


    }









    Text {


        anchors.top:circle.bottom



        anchors.topMargin:23



        anchors.horizontalCenter:parent.horizontalCenter



        text:root.label



        color:"#aaaaaa"



        font.family:"JetBrains Mono"



        font.pixelSize:8



    }









    onValueChanged:{


        circle.requestPaint()


    }







    Component.onCompleted:{


        circle.requestPaint()


    }


}
