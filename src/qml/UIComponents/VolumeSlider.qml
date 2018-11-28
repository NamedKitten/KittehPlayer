import QtQuick 2.11
import QtQuick.Controls 2.4
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

                implicitWidth: Math.max(
                                   background ? background.implicitWidth : 0,
                                                (handle ? handle.implicitWidth : 0)
                                                + leftPadding + rightPadding)
                implicitHeight: Math.max(
                                    background ? background.implicitHeight : 0,
                                                 (handle ? handle.implicitHeight : 0)
                                                 + topPadding + bottomPadding)
                onMoved: {
                    player.playerCommand(Enums.Commands.SetVolume,
                                         Math.round(volumeBar.value).toString())
                }
                Connections {
                    target: player
                    enabled: true
                    onVolumeChanged: function (volume){
                        volumeBar.value = volume
                    }
                }
                handle: Rectangle {
                    x: volumeBar.leftPadding + volumeBar.visualPosition
                       * (volumeBar.availableWidth - width)
                    y: volumeBar.topPadding + volumeBar.availableHeight / 2 - height / 2
                    implicitWidth: 12
                    implicitHeight: 12
                    radius: 12
                    visible: appearance.themeName == "Niconico" ? false : true
                    color: "#f6f6f6"
                    border.color: "#f6f6f6"
                }

                background: Rectangle {
                    x: volumeBar.leftPadding
                    y: volumeBar.topPadding + volumeBar.availableHeight / 2 - height / 2
                    implicitWidth: appearance.themeName == "Niconico" ? 80 : 60
                    implicitHeight: appearance.themeName == "Niconico" ? 4 : 3
                    width: volumeBar.availableWidth
                    height: implicitHeight
                    color: appearance.progressBackgroundColor
                    Rectangle {
                        width: volumeBar.visualPosition * parent.width
                        height: parent.height
                        color: appearance.volumeSliderBackground
                    }
                }
            }

