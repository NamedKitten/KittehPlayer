import QtQuick 2.11
import QtQuick.Controls 2.4
import Qt.labs.settings 1.0

Action {
    id: trackItem
    property string trackType: "none"
    property string trackID: "none"
    checkable: true
    checked: false

    onTriggered: {
        checked = player.getTrack(trackType)
        player.setTrack(trackType, trackID)
    }
}
