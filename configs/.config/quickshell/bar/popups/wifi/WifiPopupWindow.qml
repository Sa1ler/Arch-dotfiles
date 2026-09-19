import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "modules"

PanelWindow {
    id: root

    property var theme: null
    property var soundManager: null

    property bool windowVisible: false

    property int popupWidth: 550
    property int popupHeight: 330
    property int barOffset: 45
    property int rightMargin: 10

    readonly property color bgColor: root.theme && root.theme.colors ? root.theme.colors.background : "#181818"
    readonly property color borderColor: root.theme && root.theme.colors ? root.theme.colors.border : "#2A2A2A"

    // === WiFi состояние ===
    property bool wifiEnabled: true
    property string currentSSID: ""
    property int currentSignal: 0
    property string ipAddress: ""
    property bool isConnecting: false
    property string connectingSSID: ""
    property string passwordForSSID: ""
    property bool showPassword: false

    property string currentScreen: "radial"

    ListModel { id: networksModel }

    color: "transparent"

    anchors { top: true; right: true }

    implicitWidth: root.popupWidth + (root.rightMargin * 2)
    implicitHeight: root.barOffset + root.popupHeight + 20

    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: windowVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    mask: Region { Region { item: popupRect } }

    function toggle() {
        windowVisible = !windowVisible
        if (soundManager) soundManager.play(windowVisible ? "list.wav" : "out.wav")
    }

    function close() {
        if (windowVisible) {
            windowVisible = false
            currentScreen = "radial"
            if (soundManager) soundManager.play("out.wav")
        }
    }

    onWindowVisibleChanged: {
        if (windowVisible) {
            visible = true
            refreshAll()
            openAnimation.start()
        } else {
            closeAnimation.start()
        }
    }

    function refreshAll() {
        getStatus.running = true
        getNetworks.running = true
    }

    function connectToNetwork(ssid, password) {
        root.isConnecting = true
        root.connectingSSID = ssid
        connectProcess.ssid = ssid
        connectProcess.password = password
        connectProcess.running = true
    }

    function disconnect() {
        disconnectProcess.running = true
    }

    function toggleWifi() {
        toggleProcess.enabled = !root.wifiEnabled
        toggleProcess.running = true
    }

    function requestPassword(ssid) {
        root.passwordForSSID = ssid
        root.showPassword = true
    }

    function cancelPassword() {
        root.showPassword = false
        root.passwordForSSID = ""
    }

    function goToNetworks() {
        if (soundManager) soundManager.play("quick_click.wav")
        refreshAll()
        currentScreen = "networks"
    }

    function goToRadial() {
        if (soundManager) soundManager.play("out.wav")
        currentScreen = "radial"
    }

    // === Копирование IP в буфер обмена ===
    function copyIp() {
        if (root.ipAddress === "") return
        Quickshell.execDetached(["sh", "-c",
            "printf '%s' '" + root.ipAddress + "' | wl-copy 2>/dev/null || " +
            "printf '%s' '" + root.ipAddress + "' | xclip -selection clipboard 2>/dev/null || true"
        ])
        if (soundManager) soundManager.play("quick_click.wav")
    }

    // === Процесс: статус + IP ===
    Process {
        id: getStatus
        command: ["sh", "-c",
            "LC_ALL=C nmcli radio wifi 2>/dev/null; " +
            "echo '@@@'; " +
            "LC_ALL=C nmcli -t -f active,ssid,signal dev wifi 2>/dev/null | LC_ALL=C grep '^yes' | head -1; " +
            "echo '@@@'; " +
            "LC_ALL=C nmcli -g IP4.ADDRESS device show wlan0 2>/dev/null | head -1"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = text.split("@@@")

                // Радио
                var radioPart = parts[0] ? parts[0].trim() : ""
                root.wifiEnabled = radioPart === "enabled"

                // Текущая сеть
                if (parts.length > 1) {
                    var wifiPart = parts[1] ? parts[1].trim() : ""
                    if (wifiPart !== "") {
                        var firstColon = wifiPart.indexOf(":")
                        var lastColon = wifiPart.lastIndexOf(":")
                        if (firstColon !== -1 && lastColon > firstColon) {
                            root.currentSSID = wifiPart.substring(firstColon + 1, lastColon)
                            root.currentSignal = parseInt(wifiPart.substring(lastColon + 1)) || 0
                        }
                    } else {
                        root.currentSSID = ""
                        root.currentSignal = 0
                    }
                }

                // IP адрес (формат: "IP4.ADDRESS[1]:192.168.1.10/24")
                if (parts.length > 2) {
                    var ipPart = parts[2] ? parts[2].trim() : ""
                    if (ipPart !== "") {
                        var colonIdx = ipPart.indexOf(":")
                        var raw = colonIdx !== -1 ? ipPart.substring(colonIdx + 1) : ipPart
                        var slashIdx = raw.indexOf("/")
                        root.ipAddress = slashIdx !== -1 ? raw.substring(0, slashIdx) : raw
                    } else {
                        root.ipAddress = ""
                    }
                }
            }
        }
    }

    // === Процесс: список сетей + сохранённые подключения (с сортировкой) ===
    Process {
        id: getNetworks
        command: ["sh", "-c",
            "LC_ALL=C nmcli -g connection.id connection show 2>/dev/null | sed 's/^/S:/'; " +
            "echo '@@@'; " +
            "LC_ALL=C nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list 2>/dev/null | " +
            "awk -F: '{if($1 != \"\") print $0}'"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = text.split("@@@")

                // 1. Сохранённые подключения
                var savedNames = {}
                var savedPart = parts[0] ? parts[0].trim() : ""
                if (savedPart !== "") {
                    var savedLines = savedPart.split("\n")
                    for (var s = 0; s < savedLines.length; s++) {
                        if (savedLines[s].startsWith("S:")) {
                            savedNames[savedLines[s].substring(2).trim()] = true
                        }
                    }
                }

                // 2. Парсим сети
                var arr = []
                var seen = {}
                var netPart = parts.length > 1 ? parts[1].trim() : ""
                if (netPart !== "") {
                    var lines = netPart.split("\n")
                    for (var i = 0; i < lines.length; i++) {
                        if (lines[i].trim() === "") continue
                        var lastColon = lines[i].lastIndexOf(":")
                        var secondLastColon = lines[i].lastIndexOf(":", lastColon - 1)
                        if (secondLastColon === -1 || lastColon === -1) continue

                        var ssid = lines[i].substring(0, secondLastColon)
                        var signal = parseInt(lines[i].substring(secondLastColon + 1, lastColon)) || 0
                        var security = lines[i].substring(lastColon + 1)

                        if (ssid.trim() === "" || seen[ssid]) continue
                        seen[ssid] = true

                        arr.push({
                            "ssid": ssid,
                            "signal": signal,
                            "security": security,
                            "isSecured": security.indexOf("WPA") !== -1 || security.indexOf("WEP") !== -1,
                            "isCurrent": ssid === root.currentSSID,
                            "isSaved": savedNames[ssid] === true
                        })
                    }
                }

                // 3. Сортировка: текущая → сохранённые → остальные (по сигналу)
                arr.sort(function(a, b) {
                    var ga = a.isCurrent ? 0 : (a.isSaved ? 1 : 2)
                    var gb = b.isCurrent ? 0 : (b.isSaved ? 1 : 2)
                    if (ga !== gb) return ga - gb
                    return b.signal - a.signal
                })

                // 4. Заполняем модель
                networksModel.clear()
                for (var k = 0; k < arr.length; k++) {
                    networksModel.append(arr[k])
                }
            }
        }
    }

    // === Процесс: подключение ===
    Process {
        id: connectProcess
        property string ssid: ""
        property string password: ""
        command: ["sh", "-c",
            password !== ""
                ? "LC_ALL=C nmcli dev wifi connect \"" + ssid + "\" password \"" + password + "\" 2>&1"
                : "LC_ALL=C nmcli dev wifi connect \"" + ssid + "\" 2>&1"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                root.isConnecting = false
                root.showPassword = false
                root.passwordForSSID = ""
                root.currentScreen = "radial"
                refreshTimer.restart()
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                root.isConnecting = false
                root.showPassword = false
            }
        }
    }

    // === Процесс: отключение (теперь через зажатие хаба) ===
    Process {
        id: disconnectProcess
        command: ["sh", "-c", "LC_ALL=C nmcli dev disconnect wlan0 2>&1 || LC_ALL=C nmcli dev disconnect wifi 2>&1"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.currentSSID = ""
                root.currentSignal = 0
                root.ipAddress = ""
                refreshTimer.restart()
            }
        }
    }

    // === Процесс: вкл/выкл ===
    Process {
        id: toggleProcess
        property bool enabled: true
        command: ["sh", "-c", enabled ? "LC_ALL=C nmcli radio wifi on" : "LC_ALL=C nmcli radio wifi off"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled = toggleProcess.enabled
                if (!toggleProcess.enabled) {
                    root.currentSSID = ""
                    root.currentSignal = 0
                    root.ipAddress = ""
                }
                refreshTimer.restart()
            }
        }
    }

    Timer {
        id: refreshTimer
        interval: 1500
        onTriggered: root.refreshAll()
    }

    // === Анимация открытия ===
    SequentialAnimation {
        id: openAnimation
        onStarted: {
            contentWrapper.opacity = 0
            contentWrapper.y = 12
            popupRect.scale = 0.96
        }
        ParallelAnimation {
            NumberAnimation { target: popupRect; property: "height"; from: 0; to: root.popupHeight; duration: 200; easing.type: Easing.OutQuart }
            NumberAnimation { target: popupRect; property: "scale"; from: 0.96; to: 1.0; duration: 200; easing.type: Easing.OutQuart }
        }
        NumberAnimation { target: popupRect; property: "width"; from: 0; to: root.popupWidth; duration: 340; easing.type: Easing.OutBack; easing.overshoot: 1.08 }
        ParallelAnimation {
            NumberAnimation { target: contentWrapper; property: "y"; from: 12; to: 0; duration: 280; easing.type: Easing.OutQuart }
            NumberAnimation { target: contentWrapper; property: "opacity"; from: 0; to: 1; duration: 260; easing.type: Easing.OutQuart }
        }
    }

    // === Анимация закрытия ===
    SequentialAnimation {
        id: closeAnimation
        ParallelAnimation {
            NumberAnimation { target: contentWrapper; property: "opacity"; to: 0; duration: 120; easing.type: Easing.InQuart }
            NumberAnimation { target: contentWrapper; property: "y"; from: 0; to: 10; duration: 120; easing.type: Easing.InQuart }
        }
        ParallelAnimation {
            NumberAnimation { target: popupRect; property: "width"; from: root.popupWidth; to: 0; duration: 200; easing.type: Easing.InQuart }
            NumberAnimation { target: popupRect; property: "scale"; from: 1.0; to: 0.97; duration: 200; easing.type: Easing.InQuart }
        }
        NumberAnimation { target: popupRect; property: "height"; from: root.popupHeight; to: 0; duration: 180; easing.type: Easing.InQuart }
        onFinished: {
            root.visible = false
            popupRect.scale = 1.0
            contentWrapper.y = 0
        }
    }

    FocusScope {
        id: focusScope
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: function(event) {
            if (root.showPassword) root.cancelPassword()
            else if (root.currentScreen === "networks") root.goToRadial()
            else root.close()
            event.accepted = true
        }

        Rectangle {
            id: popupRect
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: root.barOffset
            anchors.rightMargin: root.rightMargin

            width: 0
            height: 0
            radius: 14
            color: root.bgColor
            border.width: 1
            border.color: root.borderColor
            clip: true
            transformOrigin: Item.TopRight

            Item {
                id: contentWrapper
                anchors.fill: parent
                anchors.margins: 16
                opacity: 0

                // === Радиальное меню ===
                RadialMenu {
                    id: radialMenu
                    anchors.fill: parent

                    theme: root.theme
                    wifiEnabled: root.wifiEnabled
                    currentSSID: root.currentSSID
                    currentSignal: root.currentSignal
                    isConnecting: root.isConnecting
                    networkCount: root.networksModel ? root.networksModel.count : 0
                    ipAddress: root.ipAddress

                    visible: root.currentScreen === "radial" && !root.showPassword
                    opacity: visible ? 1 : 0
                    scale: visible ? 1 : 0.9

                    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }
                    Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.1 } }

                    onNetworksRequested: root.goToNetworks()
                    onDisconnectRequested: root.disconnect()
                    onToggleRequested: root.toggleWifi()
                    onScanRequested: root.refreshAll()
                    onCopyIpRequested: root.copyIp()
                }

                // === Список сетей ===
                NetworkList {
                    id: networkList
                    anchors.fill: parent

                    theme: root.theme
                    networksModel: networksModel
                    currentSSID: root.currentSSID
                    isConnecting: root.isConnecting
                    connectingSSID: root.connectingSSID
                    wifiEnabled: root.wifiEnabled

                    visible: root.currentScreen === "networks" && !root.showPassword
                    opacity: visible ? 1 : 0
                    scale: visible ? 1 : 0.95

                    Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }
                    Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutQuart } }

                    // === НОВАЯ ЛОГИКА: saved сети без пароля ===
                    onNetworkSelected: function(ssid, secured, saved) {
                        if (ssid === root.currentSSID) return
                        if (secured && !saved) {
                            root.requestPassword(ssid)
                        } else {
                            if (soundManager) soundManager.play("quick_click.wav")
                            root.connectToNetwork(ssid, "")
                        }
                    }
                    onScan: root.refreshAll()
                    onBack: root.goToRadial()
                }

                // === Диалог пароля ===
                PasswordDialog {
                    id: passwordDialog
                    anchors.fill: parent

                    theme: root.theme
                    visible: root.showPassword
                    enabled: root.showPassword
                    opacity: root.showPassword ? 1 : 0
                    ssid: root.passwordForSSID
                    isConnecting: root.isConnecting

                    onConnect: function(password) {
                        if (soundManager) soundManager.play("quick_click.wav")
                        root.connectToNetwork(root.passwordForSSID, password)
                    }
                    onCancel: root.cancelPassword()

                    Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutQuart } }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: function(mouse) {
                var popupX = popupRect.x, popupY = popupRect.y
                var popupW = popupRect.width, popupH = popupRect.height
                if (mouse.x < popupX || mouse.x > popupX + popupW ||
                    mouse.y < popupY || mouse.y > popupY + popupH) {
                    root.close()
                }
            }
        }
    }
}