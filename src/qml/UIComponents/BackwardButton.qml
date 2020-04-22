import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

SmoothButton {
    id: backwardButton
    iconSource: "icons/" + appearance.themeName + "/backward.svg"

    hoverEnabled: true
    iconColor: hovered ? getAppearanceValueForTheme(
                              appearance.themeName,
                              "buttonHoverColor") : getAppearanceValueForTheme(
                              appearance.themeName, "buttonColor")
    onClicked: {
        player.playerCommand(Enums.Commands.Seek, "-10")
    }
}
