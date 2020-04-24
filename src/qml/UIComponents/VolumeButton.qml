import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

SmoothButton {
    id: volumeButton
    iconSource: "icons/" + appearance.themeName + "/volume-up.svg"
    onClicked: {
        player.playerCommand(Enums.Commands.ToggleMute)
    }
    Connections {
        target: player
        onVolumeStatusChanged: function(status) {
            if (status == Enums.VolumeStatus.Muted) {
                volumeButton.iconSource = "qrc:/icons/" + appearance.themeName + "/volume-mute.svg"
            } else if (status == Enums.VolumeStatus.Low) {
                volumeButton.iconSource = "qrc:/icons/" + appearance.themeName + "/volume-down.svg"
            } else if (status == Enums.VolumeStatus.Normal) {
                volumeButton.iconSource = "qrc:/icons/" + appearance.themeName + "/volume-up.svg"
            }
        }
    }
}
