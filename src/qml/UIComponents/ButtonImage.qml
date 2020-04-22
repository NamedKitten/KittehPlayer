import QtQuick 2.0
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0

Image {
    id: root
    smooth: true
    
    property alias color: colorOverlay.color
    property int size: 24
    fillMode: Image.PreserveAspectFit
    sourceSize.width: size
    sourceSize.height: size

    ColorOverlay {
        id: colorOverlay
        anchors.fill: root
        source: root
        color: "#000000"
    }
}