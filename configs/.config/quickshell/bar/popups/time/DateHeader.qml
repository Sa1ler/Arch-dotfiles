import QtQuick


Item {

    id: root


    width: 380
    height: 35





    property var months: [
        "ЯНВАРЬ",
        "ФЕВРАЛЬ",
        "МАРТ",
        "АПРЕЛЬ",
        "МАЙ",
        "ИЮНЬ",
        "ИЮЛЬ",
        "АВГУСТ",
        "СЕНТЯБРЬ",
        "ОКТЯБРЬ",
        "НОЯБРЬ",
        "ДЕКАБРЬ"
    ]





    property var days: [
        "ВОСКРЕСЕНЬЕ",
        "ПОНЕДЕЛЬНИК",
        "ВТОРНИК",
        "СРЕДА",
        "ЧЕТВЕРГ",
        "ПЯТНИЦА",
        "СУББОТА"
    ]







    property string dateText: ""







    Timer {

        interval: 60000

        running: true

        repeat: true


        onTriggered: updateDate()

    }







    Component.onCompleted: {

        updateDate()

    }







    function updateDate() {


        let now = new Date()


        let day = now.getDate()


        let month = months[now.getMonth()]


        let week = days[now.getDay()]


        let year = now.getFullYear()



        dateText =
            day
            +
            "  •  "
            +
            week
            +
            "  •  "
            +
            month
            +
            "  •  "
            +
            year

    }







    Text {


        anchors.centerIn: parent



        text: root.dateText



        color: "#d8d8d8"



        font.family: "JetBrains Mono"



        font.pixelSize: 14



        font.bold: true



        horizontalAlignment: Text.AlignHCenter



    }

}
