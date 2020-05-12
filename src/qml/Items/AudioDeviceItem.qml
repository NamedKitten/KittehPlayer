import QtQuick.Controls 2.3
import player 1.0

Action {
  property string deviceID: "none"
  checkable: false
  checked: false

  onTriggered: {
    player.playerCommand(Enums.Commands.SetAudioDevice, deviceID)
  }
}
