import QtQuick 2.0
import QtQuick.Controls 2.3

Text {
    id: timeLabel
    text: "0:00 / 0:00"
    color: "white"
    font.family: appearance.fontName
    font.pixelSize: layout.height / 2.5
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering
    Connections {
        target: player
        onDurationStringChanged: function (durationString) {
            timeLabel.text = durationString
        }
    }
}
