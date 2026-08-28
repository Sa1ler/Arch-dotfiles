import QtQuick
import "../base"

Item {

    id: root
    signal clicked()

    implicitWidth: 160
    implicitHeight: 30

    property string timeText: ""
    property string dayText: ""
    property string dateText: ""



    Timer {

        interval: 1000

        running: true

        repeat: true


        onTriggered: updateTime()

    }



    Component.onCompleted: {

        updateTime()

    }






    function updateTime() {


        let d = new Date()



        timeText = Qt.formatTime(d, "HH:mm")



        let days = [

            "ВС",
            "ПН",
            "ВТ",
            "СР",
            "ЧТ",
            "ПТ",
            "СБ"

        ]



        let months = [

            "ЯНВ",
            "ФЕВ",
            "МАР",
            "АПР",
            "МАЙ",
            "ИЮН",
            "ИЮЛ",
            "АВГ",
            "СЕН",
            "ОКТ",
            "НОЯ",
            "ДЕК"

        ]



        dayText = days[d.getDay()]



        dateText =
            d.getDate()
            +
            " "
            +
            months[d.getMonth()]

    }









    Row {


        anchors.centerIn: parent



        spacing: 16







        // ВРЕМЯ

        Row {


            spacing: 7



            anchors.verticalCenter: parent.verticalCenter





            Text {


                text: "󰥔"



                color: "#3675ff"



                font.pixelSize: 16



                anchors.verticalCenter: parent.verticalCenter


            }





            Text {


                text: root.timeText



                color: "#3675ff"



                font.pixelSize: 19



                font.bold: true



                anchors.verticalCenter: parent.verticalCenter


            }

        }









        // ТОЧКА

        Text {


            text: "•"



            color: "#55aaff"



            font.pixelSize: 18



            font.bold: true



            anchors.verticalCenter: parent.verticalCenter


        }









        // ДАТА

        Row {


            spacing: 6



            anchors.verticalCenter: parent.verticalCenter





            Text {


                text: root.dayText



                color: "#55aaff"



                font.pixelSize: 13



                font.bold: true



                font.letterSpacing: 0.5


            }





            Text {


                text: root.dateText



                color: "#bdbdbd"



                font.pixelSize: 13



                font.bold: true


            }

        }

    }

    MouseArea {

    anchors.fill: parent

    onClicked: {

        root.clicked()

    }

}

}
