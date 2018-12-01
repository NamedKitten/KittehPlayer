import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

Button {
    id: settingsButton
    //icon.name: "settings"
    icon.source: "icons/" + appearance.themeName + "/settings.svg"
    icon.color: getAppearanceValueForTheme(appearance.themeName, "buttonColor")
    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
    display: AbstractButton.IconOnly
    onClicked: {
        appearance.themeName = appearance.themeName == "YouTube" ? "Niconico" : "YouTube"
        controlsBarItem.setControlsTheme(appearance.themeName)
        console.log("Settings Menu Not Yet Implemented.")
    }
    background: Item {
    }
}
