import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.11
import QtQuick.Window 2.2
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

Text {
    id: timeLabel
    objectName: "timeLabel"
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
