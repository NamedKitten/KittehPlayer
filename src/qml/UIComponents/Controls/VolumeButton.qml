import QtQuick 2.0
import player 1.0

SmoothButton {
  id: volumeButton
  iconSource: "icons/" + appearance.themeName + "/volume-up.svg"
  onClicked: {
    player.playerCommand(Enums.Commands.ToggleMute)
  }
  Connections {
    target: player
    onVolumeStatusChanged: function (status) {
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
