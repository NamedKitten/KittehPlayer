import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

Text {
    id: timeLabel
    objectName: "timeLabel"
    text: "0:00 / 0:00"
    color: "white"
    padding: 2
    font.family: appearance.fontName
    font.pixelSize: layout.height / 2.5
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering
    Connections {
        target: player
        enabled: true
        onDurationStringChanged: function (durationString) {
            timeLabel.text = durationString
        }
    }
}
