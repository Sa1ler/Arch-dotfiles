import QtQuick
import Quickshell
import Quickshell.Io
import "../base"

Module {

    id: root

    // signal clicked(var source)

    moduleHeight:33

    property int volumeLevel: 0
    property bool isMuted: false

    property bool hasSound: !root.isMuted && root.volumeLevel > 0

    property int matchWidth: 0
    property int fullWidth: 70
    property int shrinkWidth:40

    property int animWidth: root.shrinkWidth
    property bool prevHasSound: false

    Behavior on animWidth {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    moduleWidth: root.animWidth

    implicitWidth: root.moduleWidth
    implicitHeight: moduleHeight

    onHasSoundChanged: {
        if (root.prevHasSound !== root.hasSound) {
            root.animWidth = root.hasSound ? root.fullWidth : root.shrinkWidth
            root.prevHasSound = root.hasSound
        }
    }


    // Единый парсер: пробует wpctl, pactl list, pactl list short
    Process {
        id: getVolume
        command: [
            "bash", "-c",
            "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null && exit 0; " +
            "pactl list sinks 2>/dev/null | grep -A5 '^Sink #' | grep 'Volume:' | head -1 && exit 0; " +
            "pactl list short sinks 2>/dev/null | head -1 && exit 0; " +
            "echo '0'"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let text = this.text.trim()
                let val = 0

                // wpctl: "Volume: 0.50000 -0.00 dBM Muted: no"
                if (text.includes("Volume:")) {
                    let parts = text.split(" ")
                    for (let i = 0; i < parts.length; i++) {
                        if (parts[i] === "Volume:" && i + 1 < parts.length) {
                            let num = parseFloat(parts[i + 1])
                            if (!isNaN(num) && num >= 0 && num <= 1) {
                                val = Math.round(num * 100)
                                break
                            }
                        }
                    }
                }
                // pactl list: "    Front Left: 45634 /  70%"
                else if (text.includes("%")) {
                    let match = text.match(/(\d+)%/)
                    if (match) val = parseInt(match[1])
                }
                // pactl list short: "0 ... 45"
                else {
                    let parts = text.split(/\s+/)
                    let last = parseInt(parts[parts.length - 1])
                    if (!isNaN(last) && last >= 0 && last <= 100) val = last
                }

                root.volumeLevel = val
            }
        }
    }

    // Парсер мута — pactl get-sink-mute возвращает "yes" или "no"
    Process {
        id: getMute
        command: [
            "bash", "-c",
            "pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}'"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let text = this.text.trim().toLowerCase()
                root.isMuted = text === "yes"
            }
        }
    }

    // Обновление каждые 500мс — надёжнее чем subscribe
    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            getVolume.running = true
            getMute.running = true
        }
    }

    Component.onCompleted: {
        getVolume.running = true
        getMute.running = true
        animWidth = hasSound ? fullWidth : shrinkWidth
        prevHasSound = hasSound
    }


    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: 6

        gradient: Gradient {
            GradientStop { position: 0; color: "#3675ff" }
            GradientStop { position: 1; color: "#3675ff" }
        }

        Row {
            id: volumeRow
            anchors.centerIn: parent
            spacing: 4

            // Контейнер с перекрытыми иконками (занимает 18px в ряду)
            Item {
                width: 18
                height: 18

                // Выключенная иконка (нижний слой)
                Image {
                    anchors.centerIn: parent
                    source: "../../assets/icons/ui/volume-muted.svg"
                    width: 18
                    height: 18
                    smooth: true

                    opacity: root.hasSound ? 0 : 1
                    scale: root.hasSound ? 0.8 : 1

                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    Behavior on scale { NumberAnimation { duration: 200 } }
                }

                // Активная иконка (верхний слой)
                Image {
                    anchors.centerIn: parent
                    source: "../../assets/icons/ui/volume-active.svg"
                    width: 18
                    height: 18
                    smooth: true

                    opacity: root.hasSound ? 1 : 0
                    scale: root.hasSound ? 1 : 0.8

                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    Behavior on scale { NumberAnimation { duration: 200 } }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.hasSound ? root.volumeLevel + "%" : ""
                color: "#111111"
                font.pixelSize: 13
                font.weight: Font.DemiBold

                opacity: root.hasSound ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }
        }
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
            root.scale = 1
        }
    }

}
