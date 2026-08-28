import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var theme: null

    readonly property color bg: root.theme.colors.background
    readonly property color surface: root.theme.colors.surface
    readonly property color accent: root.theme.colors.accent
    readonly property color text: root.theme.colors.text
    readonly property color textSec: root.theme.colors.textSecondary
    readonly property color border: root.theme.colors.border

    property string position: "top-right"
    property string dropdown: ""
    property bool soundOn: true
    property string soundFile: "notification.wav"
    property var sounds: []

    property bool fileBrowserOpen: false
    property string currentDir: ""
    property var fileList: []
    property string selectedFile: ""

    readonly property string posFile: Quickshell.env("HOME") + "/.config/quickshell/notification-position"
    readonly property string sndEnFile: Quickshell.env("HOME") + "/.config/quickshell/notification-sound-enabled"
    readonly property string sndFile: Quickshell.env("HOME") + "/.config/quickshell/notification-sound"
    readonly property string sndDir: Quickshell.env("HOME") + "/.config/quickshell/generalmenu/sounds/notifications/"
    readonly property string uiSoundsDir: Quickshell.env("HOME") + "/.config/quickshell/generalmenu/sounds/"

    readonly property var positions: [
        { v: "top-left",      l: "Слева вверху" },
        { v: "top-center",    l: "Вверху по центру" },
        { v: "top-right",     l: "Справа вверху" },
        { v: "bottom-left",   l: "Слева внизу" },
        { v: "bottom-center", l: "Внизу по центру" },
        { v: "bottom-right",  l: "Справа внизу" }
    ]

    function posLabel(v) {
        return positions.find(p => p.v === v)?.l ?? "Справа вверху"
    }

    function sndLabel(f) {
        return f.replace(/\.(wav|ogg)$/, "")
    }

    Process {
        id: posRead
        command: ["cat", root.posFile]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = text.trim()
                if (v) root.position = v
            }
        }
    }

    Process {
        id: posWrite
        property string val: ""
        command: ["sh", "-c", "printf '%s\\n' '" + val + "' > '" + root.posFile + "'"]
    }

    Process {
        id: sndEnRead
        command: ["cat", root.sndEnFile]
        stdout: StdioCollector {
            onStreamFinished: root.soundOn = text.trim() !== "0"
        }
    }

    Process {
        id: sndEnWrite
        property string val: ""
        command: ["sh", "-c", "printf '%s\\n' '" + val + "' > '" + root.sndEnFile + "'"]
    }

    Process {
        id: sndRead
        command: ["cat", root.sndFile]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = text.trim()
                if (v) root.soundFile = v
            }
        }
    }

    Process {
        id: sndWrite
        property string val: ""
        command: ["sh", "-c", "printf '%s\\n' '" + val + "' > '" + root.sndFile + "'"]
    }

    Process {
        id: sndScan
        command: ["sh", "-c", "ls '" + root.sndDir + "'*.wav 2>/dev/null | xargs -n1 basename | sort"]
        stdout: StdioCollector {
            onStreamFinished: root.sounds = text.trim().split("\n").filter(f => f)
        }
    }

    Process {
        id: fileLister
        command: ["bash", "-c", "cd '" + root.currentDir + "' 2>/dev/null && ls -p | grep -v '^\\.' | sort"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                const dirs = []
                const files = []
                for (const line of lines) {
                    if (!line) continue
                    if (line.endsWith("/")) {
                        dirs.push({ type: "dir", name: line.slice(0, -1) })
                    } else if (line.endsWith(".wav")) {
                        files.push({ type: "file", name: line })
                    }
                }
                root.fileList = [...dirs, ...files]
            }
        }
    }

    Process {
        id: fileCopier
        property string source: ""
        property string fileName: ""
        command: ["cp", source, root.sndDir + fileName]
        onExited: function(code) {
            if (code === 0) {
                root.soundFile = fileName
                sndWrite.val = fileName
                sndWrite.running = true
                sndScan.running = true
                playSnd(fileName)
            }
            root.fileBrowserOpen = false
        }
    }

    function setPos(v) {
        root.position = v
        posWrite.val = v
        posWrite.running = true
        root.dropdown = ""
    }

    function toggleSnd() {
        root.soundOn = !root.soundOn
        sndEnWrite.val = root.soundOn ? "1" : "0"
        sndEnWrite.running = true
        if (root.soundOn) playSnd(root.soundFile)
    }

    function setSnd(f) {
        root.soundFile = f
        sndWrite.val = f
        sndWrite.running = true
        root.dropdown = ""
        playSnd(f)
    }

    function playSnd(f) {
        Quickshell.execDetached([
            "sh", "-c",
            "pw-play '" + root.sndDir + f + "' 2>/dev/null || paplay '" + root.sndDir + f + "' 2>/dev/null || true"
        ])
    }

    function playClick(f) {
        Quickshell.execDetached([
            "sh", "-c",
            "pw-play '" + root.uiSoundsDir + f + "' 2>/dev/null || paplay '" + root.uiSoundsDir + f + "' 2>/dev/null || true"
        ])
    }

    function openFileBrowser() {
        root.playClick("clicks.wav")
        root.currentDir = Quickshell.env("HOME")
        root.fileList = []
        root.fileBrowserOpen = true
        fileLister.running = true
    }

    function closeFileBrowser() {
        root.playClick("clicks.wav")
        root.fileBrowserOpen = false
    }

    function enterDir(name) {
        root.playClick("click.wav")
        root.currentDir = root.currentDir === "/" ? "/" + name : root.currentDir + "/" + name
        root.fileList = []
        fileLister.running = true
    }

    function goUp() {
        root.playClick("click.wav")
        const parts = root.currentDir.split("/").filter(p => p)
        parts.pop()
        root.currentDir = "/" + parts.join("/")
        root.fileList = []
        fileLister.running = true
    }

    function selectFile(name) {
        root.playClick("click.wav")
        root.selectedFile = name
        const sourcePath = root.currentDir + "/" + name
        if (root.sounds.indexOf(name) !== -1) {
            root.soundFile = name
            sndWrite.val = name
            sndWrite.running = true
            playSnd(name)
            root.fileBrowserOpen = false
        } else {
            fileCopier.source = sourcePath
            fileCopier.fileName = name
            fileCopier.running = true
        }
    }

    function shortPath(path) {
        const home = Quickshell.env("HOME")
        if (path === home) return "~"
        if (path.indexOf(home) === 0) return "~" + path.substring(home.length)
        return path
    }

    Component.onCompleted: {
        posRead.running = true
        sndEnRead.running = true
        sndRead.running = true
        sndScan.running = true
    }

    Item {
        id: page
        anchors.fill: parent

        Column {
            anchors { fill: parent; margins: 36 }
            spacing: 0

            Text {
                text: "Уведомления"
                font.family: "Cascadia Code"
                font.pixelSize: 28
                font.weight: Font.Bold
                color: root.text
            }

            Text {
                text: "Положение и звуковое оформление"
                font.family: "Cascadia Code"
                font.pixelSize: 11
                color: root.textSec
            }

            Text {
                text: "ОТОБРАЖЕНИЕ"
                font.family: "Cascadia Code"
                font.pixelSize: 10
                font.weight: Font.Bold
                font.letterSpacing: 1.5
                color: root.textSec
                width: parent.width
                height: implicitHeight + 40
                verticalAlignment: Text.AlignBottom
            }

            Item {
                width: parent.width
                height: 44

                Text {
                    text: "Позиция"
                    font.family: "Cascadia Code"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: root.text
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    id: posBtn
                    width: 180
                    height: 32
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 8
                    color: posMa.containsMouse ? Qt.lighter(root.surface, 1.16) : Qt.lighter(root.surface, 1.08)
                    border.width: 1
                    border.color: root.dropdown === "position" ? root.accent : root.border
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.posLabel(root.position)
                        font.family: "Cascadia Code"
                        font.pixelSize: 11
                        color: root.dropdown === "position" ? root.accent : root.text
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: ""
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 11
                        color: root.textSec
                        rotation: root.dropdown === "position" ? 180 : 0
                        Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    }

                    MouseArea {
                        id: posMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.playClick("clicks.wav")
                            root.dropdown = root.dropdown === "position" ? "" : "position"
                        }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: root.border; opacity: 0.3 }

            Text {
                text: "ЗВУК"
                font.family: "Cascadia Code"
                font.pixelSize: 10
                font.weight: Font.Bold
                font.letterSpacing: 1.5
                color: root.textSec
                width: parent.width
                height: implicitHeight + 32
                verticalAlignment: Text.AlignBottom
            }

            Item {
                width: parent.width
                height: 44

                Column {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text { text: "Звук уведомлений"; font.family: "Cascadia Code"; font.pixelSize: 13; font.weight: Font.Medium; color: root.text }
                    Text { text: "Проигрывать звук при получении"; font.family: "Cascadia Code"; font.pixelSize: 10; color: root.textSec }
                }

                Rectangle {
                    width: 40
                    height: 22
                    radius: 11
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.soundOn ? root.accent : root.border
                    Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutCubic } }

                    Rectangle {
                        width: 18
                        height: 18
                        radius: 9
                        x: root.soundOn ? parent.width - 20 : 2
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#FFFFFF"
                        Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.playClick("click.wav")
                            root.toggleSnd()
                        }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: root.border; opacity: 0.3 }

            Item {
                width: parent.width
                height: 44
                opacity: root.soundOn ? 1.0 : 0.4
                Behavior on opacity { NumberAnimation { duration: 250 } }

                Text {
                    text: "Мелодия"
                    font.family: "Cascadia Code"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: root.text
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    id: addSndBtn
                    width: 32
                    height: 32
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 8
                    color: addSndMa.containsMouse ? Qt.lighter(root.surface, 1.16) : Qt.lighter(root.surface, 1.08)
                    border.width: 1
                    border.color: root.border
                    enabled: root.soundOn
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: "+"
                        font.family: "Cascadia Code"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: root.text
                    }

                    MouseArea {
                        id: addSndMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.openFileBrowser()
                    }
                }

                Rectangle {
                    id: sndBtn
                    width: 142
                    height: 32
                    anchors.right: addSndBtn.left
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 8
                    color: sndMa.containsMouse ? Qt.lighter(root.surface, 1.16) : Qt.lighter(root.surface, 1.08)
                    border.width: 1
                    border.color: root.dropdown === "sound" ? root.accent : root.border
                    enabled: root.soundOn
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.sndLabel(root.soundFile)
                        font.family: "Cascadia Code"
                        font.pixelSize: 11
                        color: root.dropdown === "sound" ? root.accent : root.text
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: ""
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 11
                        color: root.textSec
                        rotation: root.dropdown === "sound" ? 180 : 0
                        Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    }

                    MouseArea {
                        id: sndMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.playClick("clicks.wav")
                            root.dropdown = root.dropdown === "sound" ? "" : "sound"
                        }
                    }
                }
            }
        }

        Rectangle {
            id: posList
            width: 180
            height: root.positions.length * 32 + 8

            x: {
                root.dropdown
                page.width
                return posBtn.mapToItem(page, 0, 0).x
            }
            y: {
                root.dropdown
                page.height
                return posBtn.mapToItem(page, 0, 0).y + posBtn.height + 4
            }

            radius: 8
            color: root.bg
            border.width: 1
            border.color: root.border

            visible: root.dropdown === "position"
            opacity: root.dropdown === "position" ? 1.0 : 0.0
            scale: root.dropdown === "position" ? 1.0 : 0.98
            transformOrigin: Item.Top
            z: 1000

            Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

            Column {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 1

                Repeater {
                    model: root.positions
                    delegate: Rectangle {
                        width: posList.width - 8
                        height: 30
                        radius: 6
                        color: pMa.containsMouse ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.1) : "transparent"
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.l
                            font.family: "Cascadia Code"
                            font.pixelSize: 11
                            color: root.position === modelData.v ? root.accent : root.text
                        }

                        Text {
                            visible: root.position === modelData.v
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: "✓"
                            font.family: "Cascadia Code"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: root.accent
                        }

                        MouseArea {
                            id: pMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.playClick("click.wav")
                                root.setPos(modelData.v)
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: sndList
            width: 142
            height: Math.min(sCol.height + 8, 200)

            x: {
                root.dropdown
                page.width
                return sndBtn.mapToItem(page, 0, 0).x
            }
            y: {
                root.dropdown
                page.height
                return sndBtn.mapToItem(page, 0, 0).y + sndBtn.height + 4
            }

            radius: 8
            color: root.bg
            border.width: 1
            border.color: root.border

            visible: root.dropdown === "sound"
            opacity: root.dropdown === "sound" ? 1.0 : 0.0
            scale: root.dropdown === "sound" ? 1.0 : 0.98
            transformOrigin: Item.Top
            z: 1000

            Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

            Flickable {
                anchors.fill: parent
                anchors.margins: 4
                contentHeight: sCol.height
                clip: true

                Column {
                    id: sCol
                    width: sndList.width - 8
                    spacing: 1

                    Repeater {
                        model: root.sounds
                        delegate: Rectangle {
                            width: sndList.width - 8
                            height: 30
                            radius: 6
                            color: sMa.containsMouse ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.1) : "transparent"
                            Behavior on color { ColorAnimation { duration: 100 } }

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.sndLabel(modelData)
                                font.family: "Cascadia Code"
                                font.pixelSize: 11
                                color: root.soundFile === modelData ? root.accent : root.text
                            }

                            Text {
                                visible: root.soundFile === modelData
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                text: "✓"
                                font.family: "Cascadia Code"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: root.accent
                            }

                            MouseArea {
                                id: sMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.playClick("click.wav")
                                    root.setSnd(modelData)
                                }
                            }
                        }
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            visible: root.dropdown !== ""
            z: 500
            onClicked: root.dropdown = ""
        }

        Item {
            id: fileBrowserOverlay
            anchors.fill: parent
            visible: root.fileBrowserOpen
            z: 2000

            Rectangle {
                anchors.fill: parent
                color: "#000000"
                opacity: 0.6

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.closeFileBrowser()
                }
            }

            Rectangle {
                width: 520
                height: 420
                anchors.centerIn: parent
                radius: 16
                color: root.bg
                border.width: 1
                border.color: root.border

                Row {
                    id: fbHeader
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        topMargin: 20
                        leftMargin: 24
                        rightMargin: 24
                    }
                    spacing: 12

                    Text {
                        text: "Выбор звука"
                        font.family: "Cascadia Code"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: root.text
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Item { width: parent.width - 200; height: 1 }
                }

                Text {
                    id: fbPath
                    anchors {
                        top: fbHeader.bottom
                        left: parent.left
                        right: parent.right
                        topMargin: 8
                        leftMargin: 24
                        rightMargin: 24
                    }
                    text: root.shortPath(root.currentDir)
                    font.family: "Cascadia Code"
                    font.pixelSize: 11
                    color: root.textSec
                    elide: Text.ElideMiddle
                }

                Rectangle {
                    id: fbDivider
                    anchors {
                        top: fbPath.bottom
                        left: parent.left
                        right: parent.right
                        topMargin: 12
                        leftMargin: 24
                        rightMargin: 24
                    }
                    height: 1
                    color: root.border
                    opacity: 0.3
                }

                Flickable {
                    id: fbList
                    anchors {
                        top: fbDivider.bottom
                        left: parent.left
                        right: parent.right
                        bottom: fbFooter.top
                        topMargin: 8
                        leftMargin: 16
                        rightMargin: 16
                        bottomMargin: 8
                    }
                    contentHeight: fbCol.height
                    clip: true

                    Column {
                        id: fbCol
                        width: fbList.width
                        spacing: 2

                        Rectangle {
                            width: fbCol.width
                            height: 36
                            radius: 8
                            visible: root.currentDir !== "/"
                            color: fbUpMa.containsMouse ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.1) : "transparent"
                            Behavior on color { ColorAnimation { duration: 100 } }

                            Row {
                                anchors {
                                    left: parent.left
                                    leftMargin: 12
                                    verticalCenter: parent.verticalCenter
                                }
                                spacing: 10

                                Text { text: "←"; font.family: "Cascadia Code"; font.pixelSize: 14; color: root.accent; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "Назад"; font.family: "Cascadia Code"; font.pixelSize: 12; color: root.textSec; anchors.verticalCenter: parent.verticalCenter }
                            }

                            MouseArea {
                                id: fbUpMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.goUp()
                            }
                        }

                        Repeater {
                            model: root.fileList
                            delegate: Rectangle {
                                width: fbCol.width
                                height: 36
                                radius: 8
                                color: fbItemMa.containsMouse ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.1) : "transparent"
                                Behavior on color { ColorAnimation { duration: 100 } }

                                Row {
                                    anchors {
                                        left: parent.left
                                        leftMargin: 12
                                        verticalCenter: parent.verticalCenter
                                    }
                                    spacing: 10

                                    Text {
                                        text: modelData.type === "dir" ? "󰉋" : "󰓆"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 16
                                        color: modelData.type === "dir" ? root.accent : root.textSec
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: modelData.name
                                        font.family: "Cascadia Code"
                                        font.pixelSize: 12
                                        color: root.text
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                MouseArea {
                                    id: fbItemMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData.type === "dir") root.enterDir(modelData.name)
                                        else root.selectFile(modelData.name)
                                    }
                                }
                            }
                        }

                        Item {
                            width: fbCol.width
                            height: 60
                            visible: root.fileList.length === 0

                            Text {
                                anchors.centerIn: parent
                                text: "Нет .wav файлов в этой папке"
                                font.family: "Cascadia Code"
                                font.pixelSize: 11
                                color: root.textSec
                                opacity: 0.6
                            }
                        }
                    }
                }

                Row {
                    id: fbFooter
                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                        bottomMargin: 20
                        rightMargin: 24
                    }
                    spacing: 8

                    Rectangle {
                        width: 100
                        height: 34
                        radius: 8
                        color: fbCancelMa.containsMouse ? Qt.lighter(root.surface, 1.16) : Qt.lighter(root.surface, 1.08)
                        border.width: 1
                        border.color: root.border

                        Text {
                            anchors.centerIn: parent
                            text: "Отмена"
                            font.family: "Cascadia Code"
                            font.pixelSize: 12
                            color: root.text
                        }

                        MouseArea {
                            id: fbCancelMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.closeFileBrowser()
                        }
                    }
                }
            }
        }
    }
}