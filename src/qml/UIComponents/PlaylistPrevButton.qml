import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

Button {
    id: playlistPrevButton
    objectName: "playlistPrevButton"
    icon.source: "icons/" + appearance.themeName + "/prev.svg"
    hoverEnabled: true
    icon.color: hovered ? getAppearanceValueForTheme(
                              appearance.themeName,
                              "buttonHoverColor") : getAppearanceValueForTheme(
                              appearance.themeName, "buttonColor")
    display: AbstractButton.IconOnly
    visible: appearance.themeName == "Youtube" ? false : true
    onClicked: {
        player.playerCommand(Enums.Commands.PreviousPlaylistItem)
    }
    background: Item {
    }
    Connections {
        target: player
        enabled: true
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
