import QtQuick 2.11
import QtQuick.Controls 2.4
import Qt.labs.settings 1.0

Action {
    id: audioDeviceItem
    property string deviceID: "none"
    checkable: true
    checked: false

    onTriggered: {
        player.setAudioDevice(deviceID)
    }
}
