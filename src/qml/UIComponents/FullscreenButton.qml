import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

Button {
    id: fullscreenButton
    icon.source: "icons/" + appearance.themeName + "/fullscreen.svg"
    hoverEnabled: true
    icon.color: hovered ? getAppearanceValueForTheme(
                              appearance.themeName,
                              "buttonHoverColor") : getAppearanceValueForTheme(
                              appearance.themeName, "buttonColor")
    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

    display: AbstractButton.IconOnly
    onClicked: {
        toggleFullscreen()
    }

    background: Item {
    }
}
