import player 1.0

SmoothButton {
  iconSource: "icons/" + appearance.themeName + "/next.svg"
  onClicked: {
    player.playerCommand(Enums.Commands.NextPlaylistItem)
  }
}
