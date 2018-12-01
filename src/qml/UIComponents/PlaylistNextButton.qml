import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

Button {
    id: playlistNextButton
    //icon.name: "next"
    icon.source: "icons/" + appearance.themeName + "/next.svg"
    icon.color: getAppearanceValueForTheme(appearance.themeName, "buttonColor")
    display: AbstractButton.IconOnly
    onClicked: {
        player.playerCommand(Enums.Commands.NextPlaylistItem)
    }
    background: Item {
    }
}
