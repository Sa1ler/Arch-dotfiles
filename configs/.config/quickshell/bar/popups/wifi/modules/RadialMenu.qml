import QtQuick

Item {
    id: root

    property var theme: null
    property bool wifiEnabled: true
    property string currentSSID: ""
    property int currentSignal: 0
    property bool isConnecting: false
    property int networkCount: 0
    property string ipAddress: ""

    // Состояние зажатия хаба
    property real hubProgress: 0
    property bool hubHolding: false

    signal networksRequested()
    signal disconnectRequested()
    signal toggleRequested()
    signal scanRequested()
    signal copyIpRequested()

    readonly property color textColor: theme && theme.colors ? theme.colors.text : "#FFFFFF"
    readonly property color textSecondary: theme && theme.colors ? theme.colors.textSecondary : "#888888"
    readonly property color accentColor: theme && theme.colors ? theme.colors.accent : "#5B9BFF"
    readonly property color dangerColor: "#FF4D4D"

    // Смешанный цвет accent → red по мере зажатия
    readonly property color hubMixColor: Qt.rgba(
        accentColor.r + (dangerColor.r - accentColor.r) * hubProgress,
        accentColor.g + (dangerColor.g - accentColor.g) * hubProgress,
        accentColor.b + (dangerColor.b - accentColor.b) * hubProgress,
        1.0
    )

    readonly property bool canDisconnect: wifiEnabled && currentSSID !== "" && !isConnecting

    // === Геометрия ===
    readonly property real hubRadius: 64
    readonly property real centerX: width / 2
    readonly property real centerY: height / 2
    readonly property real btnW: 134
    readonly property real btnH: 54
    readonly property real padX: 12
    readonly property real padY: 14

    readonly property real b1cx: padX + btnW / 2
    readonly property real b1cy: padY + btnH / 2
    readonly property real b2cx: width - padX - btnW / 2
    readonly property real b2cy: padY + btnH / 2
    readonly property real b3cx: padX + btnW / 2
    readonly property real b3cy: height - padY - btnH / 2
    readonly property real b4cx: width - padX - btnW / 2
    readonly property real b4cy: height - padY - btnH / 2

    // === Анимации зажатия хаба (1.7 сек) ===
    NumberAnimation {
        id: hubFillAnim
        target: root
        property: "hubProgress"
        from: 0
        to: 1
        duration: 1700
        easing.type: Easing.InOutQuad

        onFinished: {
            root.disconnectRequested()
            hubReleasePause.restart()
        }
    }

    Timer {
        id: hubReleasePause
        interval: 200
        onTriggered: hubResetAnim.restart()
    }

    NumberAnimation {
        id: hubResetAnim
        target: root
        property: "hubProgress"
        to: 0
        duration: 450
        easing.type: Easing.OutQuart
    }

    // =============================================
    // === МОЛНИИ ===
    // =============================================
    Canvas {
        id: lightningCanvas
        anchors.fill: parent
        renderTarget: Canvas.FramebufferObject
        renderStrategy: Canvas.Threaded

        Timer {
            interval: 45
            running: root.visible && root.opacity > 0
            repeat: true
            onTriggered: lightningCanvas.requestPaint()
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            var now = Date.now() / 1000;

            // Цвет молний тоже краснеет при зажатии хаба
            var ac = root.hubMixColor;

            drawBolt(ctx, root.centerX, root.centerY, root.b1cx, root.b1cy, now, 0.0, ac);
            drawBolt(ctx, root.centerX, root.centerY, root.b2cx, root.b2cy, now, 0.25, ac);
            drawBolt(ctx, root.centerX, root.centerY, root.b3cx, root.b3cy, now, 0.5, ac);
            drawBolt(ctx, root.centerX, root.centerY, root.b4cx, root.b4cy, now, 0.75, ac);
        }

        function drawBolt(ctx, cx, cy, tx, ty, time, phase, ac) {
            var dx = tx - cx;
            var dy = ty - cy;
            var len = Math.sqrt(dx * dx + dy * dy);
            if (len < 1) return;

            var ux = dx / len;
            var uy = dy / len;

            var startX = cx + ux * (root.hubRadius + 6);
            var startY = cy + uy * (root.hubRadius + 6);
            var endX = tx - ux * 42;
            var endY = ty - uy * 42;

            var boltDx = endX - startX;
            var boltDy = endY - startY;
            var boltLen = Math.sqrt(boltDx * boltDx + boltDy * boltDy);
            if (boltLen < 15) return;

            var nx = -uy, ny = ux;

            var segments = 8;
            var pts = [{x: startX, y: startY}];
            for (var i = 1; i < segments; i++) {
                var t = i / segments;
                var bx = startX + boltDx * t;
                var by = startY + boltDy * t;
                var envelope = Math.sin(t * Math.PI);
                // При зажатии хаба молнии "трясутся" сильнее
                var jitter = 11 + root.hubProgress * 8;
                var amp = Math.sin(i * 3.1 + 1.2 + time * root.hubProgress * 6) * jitter * envelope;
                pts.push({x: bx + nx * amp, y: by + ny * amp});
            }
            pts.push({x: endX, y: endY});

            // Базовая линия
            ctx.beginPath();
            ctx.moveTo(pts[0].x, pts[0].y);
            for (var j = 1; j < pts.length; j++) ctx.lineTo(pts[j].x, pts[j].y);
            ctx.strokeStyle = Qt.rgba(ac.r, ac.g, ac.b, 0.10 + root.hubProgress * 0.15);
            ctx.lineWidth = 2;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";
            ctx.stroke();

            // Бегущий импульс (при зажатии — быстрее и к центру, эффект "стягивания энергии")
            var speed = 0.6 + root.hubProgress * 1.4;
            var dir = root.hubProgress > 0.02 ? -1 : 1;
            var p = ((time * speed * dir + phase) % 1 + 1) % 1;

            ctx.save();
            ctx.setLineDash([20, boltLen + 20]);
            ctx.lineDashOffset = -p * (boltLen + 40);

            ctx.beginPath();
            ctx.moveTo(pts[0].x, pts[0].y);
            for (var k = 1; k < pts.length; k++) ctx.lineTo(pts[k].x, pts[k].y);

            ctx.strokeStyle = Qt.rgba(ac.r, ac.g, ac.b, 0.75);
            ctx.lineWidth = 2.5;
            ctx.shadowColor = Qt.rgba(ac.r, ac.g, ac.b, 0.55 + root.hubProgress * 0.3);
            ctx.shadowBlur = 12 + root.hubProgress * 8;
            ctx.stroke();

            ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.35);
            ctx.lineWidth = 1;
            ctx.shadowBlur = 6;
            ctx.stroke();

            ctx.restore();
        }
    }

    // =============================================
    // === ЦЕНТРАЛЬНЫЙ ХАБ (зажать = отключиться) ===
    // =============================================
    Item {
        id: hub
        anchors.centerIn: parent
        width: root.hubRadius * 2
        height: root.hubRadius * 2

        // Внешнее пульсирующее кольцо (краснеет при зажатии)
        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 40
            height: parent.height + 40
            radius: width / 2
            color: "transparent"
            border.width: 1.5 + root.hubProgress * 2
            border.color: Qt.rgba(root.hubMixColor.r, root.hubMixColor.g, root.hubMixColor.b,
                                   0.06 + root.hubProgress * 0.25)

            SequentialAnimation on scale {
                running: root.wifiEnabled && root.currentSSID !== "" && root.hubProgress <= 0
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 1.12; duration: 2200; easing.type: Easing.InOutSine }
                NumberAnimation { from: 1.12; to: 1.0; duration: 2200; easing.type: Easing.InOutSine }
            }
        }

        // Вращающиеся дуги
        Canvas {
            id: ringCanvas
            anchors.fill: parent
            anchors.margins: -10

            Timer {
                interval: 33
                running: root.visible && root.opacity > 0
                repeat: true
                onTriggered: ringCanvas.requestPaint()
            }

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                var cx = width / 2, cy = height / 2;
                var r = Math.min(cx, cy) - 5;
                var t = Date.now() / 1000;
                var ac = root.hubMixColor;
                var active = root.wifiEnabled && root.currentSSID !== "";

                // Скорость вращения растёт при зажатии
                var speedMul = 1 + root.hubProgress * 3;

                for (var i = 0; i < 4; i++) {
                    var dir = (i % 2 === 0) ? 1 : -1;
                    var speed = (0.35 + i * 0.12) * speedMul;
                    var start = t * speed * dir + i * 1.57;
                    var sweep = 0.55 + i * 0.15;

                    ctx.beginPath();
                    ctx.arc(cx, cy, r - i * 3, start, start + sweep);
                    ctx.strokeStyle = Qt.rgba(ac.r, ac.g, ac.b, active ? (0.30 - i * 0.06) : 0.06);
                    ctx.lineWidth = 2 - i * 0.3;
                    ctx.lineCap = "round";
                    ctx.stroke();
                }

                if (active) {
                    for (var j = 0; j < 3; j++) {
                        var angle = t * (0.8 + j * 0.3) * speedMul + j * 2.09;
                        var orbitR = r + 2;
                        var px = cx + Math.cos(angle) * orbitR;
                        var py = cy + Math.sin(angle) * orbitR;

                        ctx.beginPath();
                        ctx.arc(px, py, 2.5, 0, Math.PI * 2);
                        ctx.fillStyle = Qt.rgba(ac.r, ac.g, ac.b, 0.6);
                        ctx.shadowColor = Qt.rgba(ac.r, ac.g, ac.b, 0.8);
                        ctx.shadowBlur = 8;
                        ctx.fill();
                        ctx.shadowBlur = 0;
                    }
                }
            }
        }

        // Основной круг
        Rectangle {
            id: hubCircle
            anchors.fill: parent
            radius: width / 2
            color: Qt.rgba(root.hubMixColor.r, root.hubMixColor.g, root.hubMixColor.b, 0.06)
            border.width: 2
            border.color: Qt.rgba(root.hubMixColor.r, root.hubMixColor.g, root.hubMixColor.b,
                                   root.canDisconnect ? 0.4 : 0.12)

            Behavior on border.color { ColorAnimation { duration: 300 } }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                radius: width / 2
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: Qt.rgba(root.hubMixColor.r, root.hubMixColor.g, root.hubMixColor.b, 0.14)
                    }
                    GradientStop {
                        position: 1.0
                        color: Qt.rgba(root.hubMixColor.r, root.hubMixColor.g, root.hubMixColor.b, 0.02)
                    }
                }
            }
        }

        // === Круговая заливка при зажатии (pie fill) ===
        Canvas {
            id: hubFillCanvas
            anchors.fill: parent
            property real progress: root.hubProgress
            property color mixColor: root.hubMixColor
            onProgressChanged: requestPaint()
            onMixColorChanged: requestPaint()

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                if (root.hubProgress <= 0.001) return;

                var cx = width / 2, cy = height / 2;
                var r = root.hubRadius - 3;
                var mc = root.hubMixColor;
                var sweep = -Math.PI / 2 + Math.PI * 2 * root.hubProgress;

                // Pie-заполнение
                ctx.save();
                ctx.beginPath();
                ctx.moveTo(cx, cy);
                ctx.arc(cx, cy, r, -Math.PI / 2, sweep);
                ctx.closePath();

                var grad = ctx.createRadialGradient(cx, cy, 0, cx, cy, r);
                grad.addColorStop(0, Qt.rgba(mc.r, mc.g, mc.b, 0.15));
                grad.addColorStop(1, Qt.rgba(mc.r, mc.g, mc.b, 0.40));
                ctx.fillStyle = grad;
                ctx.fill();

                // Яркий край заливки
                ctx.beginPath();
                ctx.moveTo(cx, cy);
                ctx.lineTo(cx + Math.cos(sweep) * r, cy + Math.sin(sweep) * r);
                ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.5);
                ctx.lineWidth = 2;
                ctx.shadowColor = Qt.rgba(mc.r, mc.g, mc.b, 0.9);
                ctx.shadowBlur = 12;
                ctx.stroke();

                ctx.restore();
            }
        }

        // === Контент хаба ===
        Item {
            anchors.fill: parent

            // Wifi иконка (исчезает при зажатии)
            Text {
                id: wifiIcon
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: root.hubProgress > 0.02 ? 0 : -18
                text: "\uf1eb"
                font.family: "Font Awesome 6 Free Solid"
                font.pixelSize: 30
                color: root.canDisconnect ? root.hubMixColor : "#444444"
                opacity: 1 - root.hubProgress

                Behavior on color { ColorAnimation { duration: 400 } }
                Behavior on opacity { NumberAnimation { duration: 200 } }

                SequentialAnimation on scale {
                    running: root.canDisconnect && root.hubProgress <= 0
                    loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 1.08; duration: 1800; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.08; to: 1.0; duration: 1800; easing.type: Easing.InOutSine }
                }
            }

            // Иконка отключения (появляется при зажатии)
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -14
                text: "\uf057"
                font.family: "Font Awesome 6 Free Solid"
                font.pixelSize: 30
                color: root.dangerColor
                opacity: root.hubProgress
                scale: 0.7 + root.hubProgress * 0.3

                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            // Название сети / прогресс
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 14
                width: parent.width - 20
                horizontalAlignment: Text.AlignHCenter
                text: {
                    if (root.hubProgress > 0.02) return Math.round(root.hubProgress * 100) + "%"
                    if (!root.wifiEnabled) return "Off"
                    if (root.isConnecting) return "..."
                    if (root.currentSSID === "") return "None"
                    return root.currentSSID
                }
                font.pixelSize: 12
                font.weight: Font.Bold
                font.family: "JetBrains Mono"
                color: root.hubProgress > 0.02 ? root.dangerColor :
                       (root.canDisconnect ? root.textColor : root.textSecondary)
                elide: Text.ElideRight
                maximumLineCount: 1

                Behavior on color { ColorAnimation { duration: 250 } }
            }

            // Полоски сигнала
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 34
                spacing: 3
                height: 16
                visible: root.canDisconnect && root.hubProgress <= 0.02
                opacity: visible ? 1 : 0

                Behavior on opacity { NumberAnimation { duration: 200 } }

                Repeater {
                    model: 4
                    Rectangle {
                        width: 4
                        height: 5 + index * 3.5
                        radius: 2
                        anchors.bottom: parent.bottom
                        color: index < Math.ceil(root.currentSignal / 25)
                            ? root.hubMixColor
                            : Qt.rgba(1, 1, 1, 0.08)
                    }
                }
            }
        }

        // Подсказка при наведении (можно отключиться зажатием)
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.bottom
            anchors.topMargin: 8
            text: "hold to disconnect"
            font.pixelSize: 9
            font.family: "JetBrains Mono"
            color: root.dangerColor
            opacity: hubMouse.containsMouse && root.canDisconnect && root.hubProgress <= 0.02 ? 0.7 : 0

            Behavior on opacity { NumberAnimation { duration: 250 } }
        }

        // Scale при зажатии
        scale: root.hubHolding ? 1.06 : (hubMouse.containsMouse && root.canDisconnect ? 1.02 : 1.0)
        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }

        // === MouseArea: зажать на 1.7 сек ===
        MouseArea {
            id: hubMouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: root.canDisconnect
            cursorShape: Qt.PointingHandCursor

            onPressed: {
                root.hubHolding = true;
                hubResetAnim.stop();
                hubFillAnim.restart();
            }
            onReleased: {
                root.hubHolding = false;
                hubFillAnim.stop();
                hubResetAnim.restart();
            }
            onCanceled: {
                root.hubHolding = false;
                hubFillAnim.stop();
                hubResetAnim.restart();
            }
        }
    }

    // =============================================
    // === КНОПКИ ===
    // =============================================

    // Networks (top-left)
    RadialButton {
        x: root.padX
        y: root.padY
        width: root.btnW
        height: root.btnH

        icon: "\uf0c9"
        label: "Networks"
        sublabel: root.wifiEnabled ? (root.networkCount + " found") : "WiFi off"
        accentColor: root.accentColor
        textColor: root.textColor
        textSecondary: root.textSecondary
        buttonEnabled: root.wifiEnabled

        onActivated: root.networksRequested()
    }

    // Copy IP (top-right) — замена Disconnect
    RadialButton {
        x: root.width - root.padX - root.btnW
        y: root.padY
        width: root.btnW
        height: root.btnH

        icon: "\uf0c5"
        label: "Copy IP"
        sublabel: root.ipAddress !== "" ? root.ipAddress : "No address"
        accentColor: root.accentColor
        textColor: root.textColor
        textSecondary: root.textSecondary
        buttonEnabled: root.ipAddress !== ""

        onActivated: root.copyIpRequested()
    }

    // Toggle WiFi (bottom-left)
    RadialButton {
        x: root.padX
        y: root.height - root.padY - root.btnH
        width: root.btnW
        height: root.btnH

        icon: root.wifiEnabled ? "\uf205" : "\uf204"
        label: root.wifiEnabled ? "Turn Off" : "Turn On"
        sublabel: root.wifiEnabled ? "WiFi enabled" : "WiFi disabled"
        accentColor: root.accentColor
        textColor: root.textColor
        textSecondary: root.textSecondary
        buttonEnabled: !root.isConnecting

        onActivated: root.toggleRequested()
    }

    // Scan (bottom-right)
    RadialButton {
        x: root.width - root.padX - root.btnW
        y: root.height - root.padY - root.btnH
        width: root.btnW
        height: root.btnH

        icon: "\uf021"
        label: "Scan"
        sublabel: "Refresh networks"
        accentColor: root.accentColor
        textColor: root.textColor
        textSecondary: root.textSecondary
        buttonEnabled: root.wifiEnabled && !root.isConnecting

        onActivated: root.scanRequested()
    }
}