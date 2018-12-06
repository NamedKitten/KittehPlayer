import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

Button {
    id: volumeButton
    objectName: "volumeButton"
    icon.source: "icons/" + appearance.themeName + "/volume-up.svg"
    hoverEnabled: true
    icon.color: hovered ? getAppearanceValueForTheme(
                              appearance.themeName,
                              "buttonHoverColor") : getAppearanceValueForTheme(
                              appearance.themeName, "buttonColor")
    display: AbstractButton.IconOnly
    onClicked: {
        player.playerCommand(Enums.Commands.ToggleMute)
    }
    background: Item {
    }

    function updateStatus(status) {
        if (volumeButton == null)
            console.log("OwO")

        if (status == Enums.VolumeStatus.Muted) {
            volumeButton.icon.source = "qrc:/icons/" + appearance.themeName + "/volume-mute.svg"
        } else if (status == Enums.VolumeStatus.Low) {
            volumeButton.icon.source = "qrc:/icons/" + appearance.themeName + "/volume-down.svg"
        } else if (status == Enums.VolumeStatus.Normal) {
            volumeButton.icon.source = "qrc:/icons/" + appearance.themeName + "/volume-up.svg"
        }
    }

    Connections {
        target: player
        enabled: true
        onVolumeStatusChanged: updateStatus
    }
}
