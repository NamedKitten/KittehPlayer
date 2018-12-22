import QtQuick 2.0
import QtQuick.Controls 2.3
import Qt.labs.settings 1.0
import player 1.0

Action {
    id: audioDeviceItem
    property string deviceID: "none"
    checkable: false
    checked: false

    onTriggered: {
        player.playerCommand(Enums.Commands.SetAudioDevice, deviceID)
    }
}
