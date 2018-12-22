import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

Text {
    id: speedText
    text: "1x"
    font.family: appearance.fontName
    font.pixelSize: layout.height / 2.5
    color: speedStatusMouseArea.containsMouse ? getAppearanceValueForTheme(
                                                    appearance.themeName,
                                                    "buttonHoverColor") : getAppearanceValueForTheme(
                                                    appearance.themeName,
                                                    "buttonColor")
    verticalAlignment: Text.AlignVCenter
    Connections {
        target: player
        onSpeedChanged: function (speed) {
            speedText.text = String(speed) + "x"
        }
    }
    MouseArea {
        id: speedStatusMouseArea
        anchors.fill: parent
        height: parent.height
        hoverEnabled: true
        propagateComposedEvents: false
        acceptedButtons: Qt.NoButton
    }
}
