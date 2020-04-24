import QtQuick 2.0
import player 1.0

SmoothButton {
    iconSource: "icons/" + appearance.themeName + "/pause.svg"
    onClicked: {
        player.playerCommand(Enums.Commands.TogglePlayPause)
    }
    Connections {
        target: player
        onPlayStatusChanged: function (status) {
            if (status == Enums.PlayStatus.Playing) {
                iconSource = "qrc:/icons/" + appearance.themeName + "/pause.svg"
            } else if (status == Enums.PlayStatus.Paused) {
                iconSource = "qrc:/icons/" + appearance.themeName + "/play.svg"
            }
        }
    }
}
