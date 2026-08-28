import QtQuick


Item {


    id:root


    width:270

    height:320







    WeatherService {


        id:weather


    }







    Component.onCompleted:{


        weather.loadWeather()


    }







    function weatherIcon(){


        if(weather.weatherCode===0)

            return "../../assets/icons/weather/clear.png"



        if(weather.weatherCode<=3)

            return "../../assets/icons/weather/partly-cloudy.png"



        if(weather.weatherCode<=48)

            return "../../assets/icons/weather/cloudy.png"



        if(weather.weatherCode<=67)

            return "../../assets/icons/weather/rain.png"



        if(weather.weatherCode<=77)

            return "../../assets/icons/weather/snow.png"



        return "../../assets/icons/weather/storm.png"


    }









    // ==========================
    // МЯГКАЯ ОБЛАСТЬ ЗА КАРТОЧКОЙ
    // ==========================


    Rectangle {


        anchors.fill:parent


        anchors.margins:-6



        radius:26



        color:"#33445566"



        opacity:0.35


    }









    // ==========================
    // ОСНОВНАЯ КАРТОЧКА
    // ==========================


    Rectangle {


        anchors.fill:parent



        radius:22



        color:"#cc1c2230"



        border.width:1



        border.color:"#33445555"


    }









    Column {


        anchors.centerIn:parent



        spacing:10







        // ГОРОД


        Row {


            anchors.horizontalCenter:parent.horizontalCenter



            spacing:6







            Image {


                width:16

                height:16



                source:"../../assets/icons/ui/location.png"



                fillMode:Image.PreserveAspectFit



                smooth:true


            }







            Text {


                text:weather.city



                color:"#dddddd"



                font.family:"JetBrains Mono"



                font.pixelSize:15



                font.bold:true


            }


        }









        // ИКОНКА ПОГОДЫ


        Image {


            anchors.horizontalCenter:parent.horizontalCenter



            width:60

            height:60



            source:weatherIcon()



            fillMode:Image.PreserveAspectFit



            smooth:true


        }









        // ТЕМПЕРАТУРА


        Text {


            anchors.horizontalCenter:parent.horizontalCenter



            text:

                Math.round(weather.temperature)

                +

                "°"



            color:"#ffffff"



            font.family:"JetBrains Mono"



            font.pixelSize:42



            font.bold:true


        }









        // ОЩУЩАЕТСЯ


        Text {


            anchors.horizontalCenter:parent.horizontalCenter



            text:

                "Ощущается "

                +

                Math.round(weather.feelsLike)

                +

                "°"



            color:"#c8dfff"



            font.pixelSize:13


        }









        Rectangle {


            width:170



            height:1



            anchors.horizontalCenter:parent.horizontalCenter



            color:"#44669966"


        }









        // КРУГОВЫЕ ПОКАЗАТЕЛИ


        Row {


            anchors.horizontalCenter:parent.horizontalCenter



            spacing:8







            CircularStat {


                value:weather.humidity



                icon:"../../assets/icons/ui/humidity.png"



                label:"Влажность"


            }







            CircularStat {


                value:

                    Math.min(

                        Math.round(weather.feelsLike + 50),

                        100

                    )



                icon:"../../assets/icons/ui/feels.png"



                label:"Ощущ."


            }







            CircularStat {


                value:

                    Math.min(

                        Math.round(weather.wind * 10),

                        100

                    )



                icon:"../../assets/icons/ui/wind.png"



                label:"Ветер"


            }


        }


    }


}
