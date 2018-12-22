import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

Button {
    id: playPauseButton
    icon.source: "icons/" + appearance.themeName + "/pause.svg"
    hoverEnabled: true
    icon.color: hovered ? getAppearanceValueForTheme(
                              appearance.themeName,
                              "buttonHoverColor") : getAppearanceValueForTheme(
                              appearance.themeName, "buttonColor")
    display: AbstractButton.IconOnly
    onClicked: {
        player.playerCommand(Enums.Commands.TogglePlayPause)
    }
    background: Item {
    }
    Connections {
        target: player
        onPlayStatusChanged: function (status) {
            if (status == Enums.PlayStatus.Playing) {
                icon.source = "qrc:/icons/" + appearance.themeName + "/pause.svg"
            } else if (status == Enums.PlayStatus.Paused) {
                icon.source = "qrc:/icons/" + appearance.themeName + "/play.svg"
            }
        }
    }
}
