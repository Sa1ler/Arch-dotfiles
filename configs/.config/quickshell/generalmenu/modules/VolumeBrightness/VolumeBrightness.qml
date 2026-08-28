import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null

    property real brightness: 0.5
    property real volume: 0.5
    property bool muted: false

    readonly property string clickSoundPath: Quickshell.shellDir + "/sounds/click.wav"

    function playClick() {
        Quickshell.execDetached(["sh", "-c", "pw-play '" + clickSoundPath + "' 2>/dev/null || paplay '" + clickSoundPath + "' 2>/dev/null || true"])
    }

    readonly property color brightnessColor: root.theme.colors.brightnessAccent ? root.theme.colors.brightnessAccent : "#F5C451"
    readonly property color volumeColor: root.theme.colors.volumeAccent ? root.theme.colors.volumeAccent : "#5B8CFF"
    readonly property color backgroundColor: root.theme.colors.surface
    readonly property color trackColor: root.theme.colors.surfaceSelected
    readonly property color borderColor: root.theme.colors.border
    readonly property color textColor: root.theme.colors.text
    readonly property color secondaryTextColor: root.theme.colors.textSecondary
    readonly property color hoverColor: root.theme.colors.surfaceHover
    readonly property color mutedColor: "#FF453A"

    readonly property int blockHeight: 110
    readonly property int sliderHeight: 8
    readonly property int handleSize: 16

    implicitHeight: blockHeight

    Process {
        id: brightnessGet
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                var output = text.trim()
                var match = output.match(/,(\d+)%/)
                if (match) root.brightness = parseInt(match[1]) / 100
            }
        }
    }

    Process {
        id: brightnessSet
        property int pendingValue: 0
        command: ["brightnessctl", "set", pendingValue + "%"]
    }

    Process {
        id: volumeGet
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                var output = text.trim()
                var volumeMatch = output.match(/Volume:\s+([0-9.]+)/)
                var mutedMatch = output.match(/\[MUTED\]/)
                if (volumeMatch) root.volume = Math.max(0, Math.min(1, parseFloat(volumeMatch[1])))
                root.muted = !!mutedMatch
            }
        }
    }

    Process {
        id: volumeSet
        property real pendingValue: 0
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", pendingValue.toFixed(3)]
    }

    Process {
        id: volumeMute
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        onExited: volumeGet.running = true
    }

    function setBrightness(value) {
        value = Math.max(0, Math.min(1, value))
        root.brightness = value
        brightnessSet.pendingValue = Math.round(value * 100)
        brightnessSet.running = true
    }

    function setVolume(value) {
        value = Math.max(0, Math.min(1, value))
        root.volume = value
        volumeSet.pendingValue = value
        volumeSet.running = true
        if (value > 0 && root.muted) volumeMute.running = true
    }

    function toggleMute() {
        volumeMute.running = true
        root.playClick()
    }

    Rectangle {
        id: mainBlock
        anchors.fill: parent
        radius: 16
        color: root.backgroundColor
        border.width: 1
        border.color: root.borderColor

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Slider {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                icon: root.brightness > 0.5 ? "󰃠" : root.brightness > 0.15 ? "󰃟" : "󰃞"
                value: root.brightness
                color: root.brightnessColor
                trackColor: root.trackColor
                hoverColor: root.hoverColor
                iconClickable: false
                onChanged: function(newValue) { root.setBrightness(newValue) }
            }

            Slider {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                icon: root.muted ? "󰝟" : root.volume <= 0 ? "󰝟" : root.volume < 0.5 ? "󰕿" : "󰕾"
                value: root.muted ? 0 : root.volume
                color: root.muted ? root.mutedColor : root.volumeColor
                trackColor: root.trackColor
                hoverColor: root.hoverColor
                iconClickable: true
                onChanged: function(newValue) { root.setVolume(newValue) }
                onIconClicked: root.toggleMute()
            }
        }
    }

    component Slider: Item {
        id: slider
        property string icon: ""
        property real value: 0.5
        property color color: "#FFB080"
        property color trackColor: "#303030"
        property color hoverColor: "#282828"
        property bool iconClickable: false
        signal changed(real newValue)
        signal iconClicked()

        RowLayout {
            anchors.fill: parent
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: 18
                color: iconMa.containsMouse ? Qt.rgba(slider.color.r, slider.color.g, slider.color.b, 0.2) : Qt.rgba(slider.color.r, slider.color.g, slider.color.b, 0.12)
                scale: iconMa.pressed ? 0.9 : (iconMa.containsMouse && slider.iconClickable ? 1.08 : 1.0)
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

                Text {
                    anchors.centerIn: parent
                    text: slider.icon
                    color: slider.color
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    Behavior on color { ColorAnimation { duration: 160 } }
                }

                MouseArea {
                    id: iconMa
                    anchors.fill: parent
                    hoverEnabled: slider.iconClickable
                    cursorShape: slider.iconClickable ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: slider.iconClickable
                    onClicked: if (slider.iconClickable) slider.iconClicked()
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Rectangle {
                    id: track
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: root.sliderHeight
                    radius: height / 2
                    color: slider.trackColor
                }

                Rectangle {
                    id: fill
                    x: track.x
                    y: track.y
                    width: track.width * slider.value
                    height: track.height
                    radius: height / 2
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Qt.lighter(slider.color, 1.15) }
                        GradientStop { position: 1.0; color: slider.color }
                    }
                    Behavior on width { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
                }

                Rectangle {
                    id: handle
                    width: root.handleSize
                    height: root.handleSize
                    radius: width / 2
                    x: track.x + track.width * slider.value - width / 2
                    anchors.verticalCenter: track.verticalCenter
                    color: slider.color
                    border.width: 2
                    border.color: root.backgroundColor
                    scale: mouseArea.pressed ? 1.2 : mouseArea.containsMouse ? 1.1 : 1.0
                    Behavior on x { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
                    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -4
                        radius: parent.radius + 4
                        color: "transparent"
                        border.width: 2
                        border.color: Qt.rgba(slider.color.r, slider.color.g, slider.color.b, 0.3)
                        opacity: mouseArea.containsMouse ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPressed: function(mouse) { slider.changed(Math.max(0, Math.min(1, mouse.x / width))) }
                    onPositionChanged: function(mouse) { if (pressed) slider.changed(Math.max(0, Math.min(1, mouse.x / width))) }
                }
            }

            Text {
                Layout.preferredWidth: 40
                horizontalAlignment: Text.AlignRight
                text: Math.round(slider.value * 100) + "%"
                color: root.secondaryTextColor
                font.pixelSize: 11
                font.bold: true
            }
        }
    }

    Component.onCompleted: {
        brightnessGet.running = true
        volumeGet.running = true
    }

    Timer {
        interval: 3000
        repeat: true
        running: true
        onTriggered: {
            brightnessGet.running = true
            volumeGet.running = true
        }
    }
}