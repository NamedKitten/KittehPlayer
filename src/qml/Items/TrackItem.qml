import QtQuick.Controls 2.3
import player 1.0

Action {
  id: trackItem
  property string trackType: "none"
  property string trackID: "none"
  checkable: true
  checked: false

  onTriggered: {
    player.playerCommand(Enums.Commands.SetTrack, [trackType, trackID])
  }
}
