import QtQuick

Item {
    id: slider
    
    property real value: 0
    property real minimumValue: 0
    property real maximumValue: 100
    property real stepSize: 1
    property color accentColor: "#5B9BFF"
    property bool isDragging: false
    
    signal moved(real newValue)
    
    implicitWidth: 200
    implicitHeight: 14
    
    // === ТРЕК ===
    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 4
        radius: 2
        color: Qt.rgba(255, 255, 255, 0.12)
        
        // Заполненная часть
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: handle.x + handle.width / 2
            radius: 2
            color: slider.accentColor
            
            Behavior on width {
                NumberAnimation { duration: slider.isDragging ? 0 : 100 }
            }
        }
    }
    
    // === ПОЛЗУНОК ===
    Rectangle {
        id: handle
        width: 12
        height: 12
        radius: 6
        color: "#FFFFFF"
        
        x: {
            var ratio = (slider.value - slider.minimumValue) / (slider.maximumValue - slider.minimumValue)
            return ratio * (track.width - width)
        }
        y: (parent.height - height) / 2
        
        Behavior on x {
            NumberAnimation { duration: slider.isDragging ? 0 : 100 }
        }
        
        scale: mouseArea.pressed ? 1.3 : (mouseArea.containsMouse ? 1.15 : 1.0)
        Behavior on scale {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.margins: -6
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onPressed: function(mouse) {
            slider.isDragging = true
            updateFromMouse(mouse.x)
        }
        
        onPositionChanged: function(mouse) {
            if (pressed) updateFromMouse(mouse.x)
        }
        
        onReleased: slider.isDragging = false
        onCanceled: slider.isDragging = false
    }
    
    function updateFromMouse(x) {
        var handleRadius = handle.width / 2
        var trackWidth = track.width - handle.width
        var ratio = Math.max(0, Math.min(1, (x - handleRadius) / trackWidth))
        var rawValue = slider.minimumValue + ratio * (slider.maximumValue - slider.minimumValue)
        var steppedValue = Math.round(rawValue / slider.stepSize) * slider.stepSize
        steppedValue = Math.max(slider.minimumValue, Math.min(slider.maximumValue, steppedValue))
        
        if (steppedValue !== slider.value) {
            slider.value = steppedValue
            slider.moved(steppedValue)
        }
    }
}