import QtQuick 2.0
import QtQuick.Controls 2.4
import Qt.labs.settings 1.0
import player 1.0

Action {
    id: trackItem
    property string trackType: "none"
    property string trackID: "none"
    checkable: true
    checked: false

    onTriggered: {
        player.playerCommand(Enums.Commands.SetTrack, [trackType, trackID])
    }
}
