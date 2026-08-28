import QtQuick
import Quickshell
import Quickshell.Wayland


PanelWindow {


    id: root


    visible:false


    color:"transparent"




    implicitWidth:Screen.width

    implicitHeight:Screen.height







    WlrLayershell.layer:WlrLayer.Overlay


    WlrLayershell.keyboardFocus:WlrKeyboardFocus.OnDemand







    MouseArea {


        anchors.fill:parent


        z:0



        onClicked:{


            root.close()


        }


    }









    Rectangle {


        id:popup



        width:930

        height:350



        radius:28




        z:1




        color:"#FC04040d"







        opacity:0

        scale:0.92







        Behavior on opacity {


            NumberAnimation {


                duration:350


                easing.type:Easing.OutCubic


            }


        }







        Behavior on scale {


            NumberAnimation {


                duration:550


                easing.type:Easing.OutBack


            }


        }







        Behavior on y {


            NumberAnimation {


                duration:550


                easing.type:Easing.OutQuint


            }


        }









        MouseArea {


            anchors.fill:parent


            z:0


            acceptedButtons:Qt.AllButtons



            onClicked:{


                mouse.accepted=true


            }


        }









        // ==========================
        // КАЛЕНДАРЬ
        // ==========================


        Rectangle {


            id:calendarGlow



            x:13

            y:10



            width:280

            height:330



            radius:28



            color:"#33445566"



            opacity:0.35


        }









        Rectangle {


            id:calendarBox



            x:18

            y:15



            width:270

            height:320



            radius:22



            color:"#cc1c2230"



            border.width:1



            border.color:"#33445555"







            MiniCalendar {


                anchors.fill:parent


                anchors.margins:12


            }


        }









        // ==========================
        // ЧАСЫ
        // ==========================


        DayRing {


            id:ring



            width:400

            height:350



            x:270

            y:0


        }









        // ==========================
        // ПОГОДА
        // ==========================


        WeatherCard {


            id:weather



            x:642

            y:15



            width:270

            height:320


        }


    }









    function open(source){


        let targetX

        let targetY







        if(source){



            let pos = source.mapToItem(

                null,

                0,

                source.height

            )







            targetX =

                pos.x

                +

                source.width / 2

                -

                popup.width / 2







            // ровно под Waybar

            targetY = pos.y



        }


        else {



            targetX =

                Screen.width / 2

                -

                popup.width / 2







            targetY = 80



        }







        popup.x = targetX







        // стартовая позиция выше

        popup.y = targetY - 60







        root.visible=true







        popup.opacity=0

        popup.scale=0.92







        // запуск анимации

        popup.opacity=1

        popup.scale=1

        popup.y=targetY



    }









    function close(){



        if(!root.visible)

            return







        popup.opacity=0



        popup.scale=0.92



        popup.y-=60







        closeTimer.restart()


    }









    Timer {


        id:closeTimer



        interval:550



        onTriggered:{


            root.visible=false


        }


    }









    Shortcut {


        sequence:"Escape"



        onActivated:{


            root.close()


        }


    }



}
