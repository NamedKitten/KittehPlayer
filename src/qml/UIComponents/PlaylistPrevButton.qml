import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

SmoothButton {
    id: playlistPrevButton
    objectName: "playlistPrevButton"
    iconSource: "icons/" + appearance.themeName + "/prev.svg"
    hoverEnabled: true
    iconColor: hovered ? getAppearanceValueForTheme(
                             appearance.themeName,
                             "buttonHoverColor") : getAppearanceValueForTheme(
                             appearance.themeName, "buttonColor")
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
