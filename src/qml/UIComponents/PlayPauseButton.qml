import QtQuick 2.0
import player 1.0

SmoothButton {
    property var playing: Enums.PlayStatus.Playing
    iconSource: "icons/" + appearance.themeName + (playing  == Enums.PlayStatus.Playing ? "/pause.svg" : "/play.svg")
    onClicked: {
        player.playerCommand(Enums.Commands.TogglePlayPause)
    }
    Connections {
        target: player
        onPlayStatusChanged: function (status) {
            playing = status
        }
    }
}
