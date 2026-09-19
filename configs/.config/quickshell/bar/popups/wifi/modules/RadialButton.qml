import QtQuick

Item {
    id: root

    property string icon: ""
    property string label: ""
    property string sublabel: ""
    property color accentColor: "#5B9BFF"
    property color textColor: "#FFFFFF"
    property color textSecondary: "#888888"
    property bool buttonEnabled: true
    property real holdDuration: 550
    property real progress: 0
    property bool isHolding: false

    signal activated()

    width: 134
    height: 54

    // === Фон ===
    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 16
        color: Qt.rgba(1, 1, 1, mouseArea.containsMouse && root.buttonEnabled ? 0.07 : 0.035)
        border.width: 1.5
        border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b,
                               0.12 + root.progress * 0.55)

        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 100 } }
    }

    // === Заливка прогресса (Canvas с clip по radius) ===
    Canvas {
        id: fillCanvas
        anchors.fill: parent
        property real progress: root.progress
        onProgressChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            if (root.progress <= 0.001) return;

            var r = 16, w = width, h = height, p = root.progress;

            ctx.save();
            ctx.beginPath();
            ctx.moveTo(r, 0);
            ctx.lineTo(w - r, 0);
            ctx.arcTo(w, 0, w, r, r);
            ctx.lineTo(w, h - r);
            ctx.arcTo(w, h, w - r, h, r);
            ctx.lineTo(r, h);
            ctx.arcTo(0, h, 0, h - r, r);
            ctx.lineTo(0, r);
            ctx.arcTo(0, 0, r, 0, r);
            ctx.closePath();
            ctx.clip();

            // Градиент заливки
            var grad = ctx.createLinearGradient(0, 0, w * p, 0);
            grad.addColorStop(0, Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.05));
            grad.addColorStop(1, Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.30));
            ctx.fillStyle = grad;
            ctx.fillRect(0, 0, w * p, h);

            // Яркая линия на фронте заливки
            var edgeGrad = ctx.createLinearGradient(w * p - 6, 0, w * p, 0);
            edgeGrad.addColorStop(0, Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0));
            edgeGrad.addColorStop(1, Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.85));
            ctx.fillStyle = edgeGrad;
            ctx.fillRect(w * p - 6, 0, 6, h);

            ctx.restore();
        }
    }

    // === Вспышка при завершении ===
    Rectangle {
        anchors.fill: parent
        radius: 16
        color: root.accentColor
        opacity: root.progress > 0.98 && root.isHolding ? 0.2 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    // === Контент ===
    Row {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 11

        // Иконка в круге
        Rectangle {
            width: 32
            height: 32
            radius: 16
            anchors.verticalCenter: parent.verticalCenter
            color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b,
                           0.10 + root.progress * 0.2)

            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: root.icon
                font.family: "Font Awesome 6 Free Solid"
                font.pixelSize: 15
                color: root.buttonEnabled ? root.accentColor : Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.3)

                Behavior on color { ColorAnimation { duration: 250 } }

                // Пульс иконки при hold
                scale: 1 + root.progress * 0.15
                Behavior on scale { NumberAnimation { duration: 100 } }
            }
        }

        // Тексты
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            width: parent.width - 50

            Text {
                text: root.label
                font.pixelSize: 13
                font.weight: Font.Bold
                font.family: "JetBrains Mono"
                color: root.buttonEnabled ? root.textColor : root.textSecondary
                elide: Text.ElideRight
                width: parent.width

                Behavior on color { ColorAnimation { duration: 250 } }
            }

            Text {
                text: root.sublabel
                font.pixelSize: 9
                font.weight: Font.Medium
                font.family: "JetBrains Mono"
                color: root.textSecondary
                elide: Text.ElideRight
                width: parent.width
                visible: root.sublabel !== ""
                opacity: 0.7
            }
        }
    }

    // === Индикатор disabled ===
    Rectangle {
        anchors.fill: parent
        radius: 16
        color: "#000000"
        opacity: root.buttonEnabled ? 0 : 0.35
        Behavior on opacity { NumberAnimation { duration: 300 } }
    }

    // === MouseArea с long-press ===
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.buttonEnabled
        cursorShape: Qt.PointingHandCursor

        onPressed: {
            root.isHolding = true;
            fillAnim.restart();
        }
        onReleased: {
            root.isHolding = false;
            fillAnim.stop();
            resetAnim.restart();
        }
        onCanceled: {
            root.isHolding = false;
            fillAnim.stop();
            resetAnim.restart();
        }
    }

    NumberAnimation {
        id: fillAnim
        target: root
        property: "progress"
        from: 0
        to: 1
        duration: root.holdDuration
        easing.type: Easing.InOutQuad

        onFinished: {
            root.activated();
            holdPause.restart();
        }
    }

    Timer {
        id: holdPause
        interval: 120
        onTriggered: resetAnim.restart()
    }

    NumberAnimation {
        id: resetAnim
        target: root
        property: "progress"
        to: 0
        duration: 350
        easing.type: Easing.OutQuart
    }

    // === Масштаб при нажатии ===
    scale: root.isHolding ? 1.03 : (mouseArea.containsMouse && root.buttonEnabled ? 1.015 : 1.0)
    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutQuart } }
}