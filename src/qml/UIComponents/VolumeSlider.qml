import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

Slider {
    id: volumeBar
    to: 100
    value: 100
    palette.dark: "#f00"

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                                         (handle ? handle.implicitWidth : 0)
                                         + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                                          (handle ? handle.implicitHeight : 0)
                                          + topPadding + bottomPadding)
    onMoved: {
        player.playerCommand(Enums.Commands.SetVolume,
                             Math.round(volumeBar.value).toString())
    }
    Connections {
        target: player
        onVolumeChanged: function (volume) {
            volumeBar.value = volume
        }
    }
    handle: Rectangle {
        x: volumeBar.leftPadding + volumeBar.visualPosition * (volumeBar.availableWidth - width)
        y: volumeBar.topPadding + volumeBar.availableHeight / 2 - height / 2
        implicitWidth: height
        implicitHeight: layout.height / 2.6
        radius: height
        visible: appearance.themeName == "Niconico" ? false : true
        color: "#f6f6f6"
        border.color: "#f6f6f6"
    }

    background: Rectangle {
        x: volumeBar.leftPadding
        y: volumeBar.topPadding + volumeBar.availableHeight / 2 - height / 2
        implicitWidth: layout.width / 11
        implicitHeight: appearance.themeName == "Niconico" ? layout.height / 6 : layout.height / 10
        width: volumeBar.availableWidth
        height: implicitHeight
        color: getAppearanceValueForTheme(appearance.themeName,
                                          "progressBackgroundColor")
        Rectangle {
            width: volumeBar.visualPosition * parent.width
            height: parent.height
            color: getAppearanceValueForTheme(appearance.themeName,
                                              "volumeSliderBackground")
        }
    }
}
