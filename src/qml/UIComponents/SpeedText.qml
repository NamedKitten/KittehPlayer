import QtQuick 2.0
import QtQuick.Controls 2.3
import player 1.0

Text {
    id: speedText
    text: "1x"
    verticalAlignment: Text.AlignVCenter
    color: speedStatusMouseArea.containsMouse ? getAppearanceValueForTheme(
                                                    appearance.themeName,
                                                    "buttonHoverColor") : getAppearanceValueForTheme(
                                                    appearance.themeName,
                                                    "buttonColor")
    font {
        family: appearance.fontName
        pixelSize: layout.height / 2.5
    }
    Connections {
        target: player
        onSpeedChanged: function (speed) {
            text = String(speed) + "x"
        }
    }
    MouseArea {
        id: speedStatusMouseArea
        anchors.fill: parent
        height: parent.height
        hoverEnabled: true
        propagateComposedEvents: true
        acceptedButtons: Qt.NoButton
    }
}
