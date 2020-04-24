import player 1.0

SmoothButton {
    iconSource: "icons/" + appearance.themeName + "/backward.svg"
    onClicked: {
        player.playerCommand(Enums.Commands.Seek, "-10")
    }
}
