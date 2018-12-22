import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

Rectangle {
    id: volumeSliderArea
    height: visible ? 70 : 0
    color: getAppearanceValueForTheme(appearance.themeName, "mainBackground")
    visible: false
    Slider {
        id: volumeSlider
        anchors.fill: parent
        to: 100
        value: 100

        orientation: Qt.Vertical

        implicitWidth: Math.max(background ? background.implicitWidth : 0,
                                             (handle ? handle.implicitWidth : 0)
                                             + leftPadding + rightPadding)
        implicitHeight: Math.max(
                            background.implicitHeight,
                            handle.implicitHeight + topPadding + bottomPadding)

        padding: 6

        Connections {
            target: player
            onVolumeChanged: function (volume) {
                volumeSlider.value = volume
            }
        }

        onMoved: {
            player.playerCommand(Enums.Commands.SetVolume,
                                 Math.round(volumeSlider.value).toString())
        }

        handle: Rectangle {
            x: volumeSlider.leftPadding + ((volumeSlider.availableWidth - width) / 2)
            y: volumeSlider.topPadding + (volumeSlider.visualPosition
                                          * (volumeSlider.availableHeight - height))
            implicitWidth: 10
            implicitHeight: 10
            radius: width / 2
            color: "white"
            border.width: 0
        }

        background: Rectangle {
            x: volumeSlider.leftPadding + ((volumeSlider.availableWidth - width) / 2)
            y: volumeSlider.topPadding
            implicitWidth: 4
            implicitHeight: 70
            width: implicitWidth
            height: volumeSlider.availableHeight
            radius: 3
            color: getAppearanceValueForTheme(appearance.themeName,
                                              "progressBackgroundColor")

            Rectangle {
                y: volumeSlider.visualPosition * parent.height
                width: 4
                height: volumeSlider.position * parent.height

                radius: 3
                color: getAppearanceValueForTheme(appearance.themeName,
                                                  "volumeSliderBackground")
            }
        }
    }
}
