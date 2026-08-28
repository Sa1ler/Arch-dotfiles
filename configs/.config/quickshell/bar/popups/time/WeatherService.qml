import QtQuick


QtObject {


    id: service



    property real temperature:0

    property real feelsLike:0

    property int humidity:0

    property real wind:0


    property int weatherCode:0



    property string city:"Москва"





    function loadWeather(){


        let xhr = new XMLHttpRequest()



        xhr.open(
            "GET",
            "https://api.open-meteo.com/v1/forecast?latitude=55.7558&longitude=37.6173&current=temperature_2m,relative_humidity_2m,apparent_temperature,wind_speed_10m,weather_code"
        )



        xhr.onreadystatechange=function(){


            if(xhr.readyState===4){


                let data=JSON.parse(xhr.responseText)



                temperature =
                    Math.round(
                        data.current.temperature_2m
                    )



                feelsLike =
                    Math.round(
                        data.current.apparent_temperature
                    )



                humidity =
                    data.current.relative_humidity_2m



                wind =
                    Math.round(
                        data.current.wind_speed_10m
                    )



                weatherCode =
                    data.current.weather_code



            }


        }


        xhr.send()

    }


}
