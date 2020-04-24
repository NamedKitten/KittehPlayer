import QtQuick 2.0
import player 1.0

SmoothButton {
    id: playlistPrevButton
    iconSource: "icons/" + appearance.themeName + "/prev.svg"
    visible: appearance.themeName == "Youtube" ? false : true
    onClicked: {
        player.playerCommand(Enums.Commands.PreviousPlaylistItem)
    }
    Connections {
        target: player
        onPlaylistPositionChanged: function (position) {
            if (appearance.themeName == "YouTube") {
                if (position != 0) {
                    visible = true
                } else {
                    visible = false
                }
            }
        }
    }
}
