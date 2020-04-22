import QtQuick 2.0
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0

Image {
    id: root
    smooth: true

    property alias color: colorOverlay.color
    property int iconHeight: 24
    property int iconWidth: 24
    fillMode: Image.PreserveAspectFit
    sourceSize.height: iconHeight
    sourceSize.width: iconWidth

    ColorOverlay {
        id: colorOverlay
        anchors.fill: root
        source: root
        color: "#000000"
    }
}
