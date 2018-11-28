import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

            Button {
                id: playPauseButton
                icon.source: "icons/" + appearance.themeName + "/pause.svg"
                icon.color: appearance.buttonColor
                display: AbstractButton.IconOnly
                onClicked: {
                    player.playerCommand(Enums.Commands.TogglePlayPause)
                }
                background: Item {
                }
                Connections {
                    target: player
                    enabled: true
                    onPlayStatusChanged: function (status) {
                        console.log(icon.height)
                        if (status == Enums.PlayStatus.Playing) {
                            icon.source = "qrc:/icons/" + appearance.themeName + "/pause.svg"
                        } else if (status == Enums.PlayStatus.Paused) {
                            icon.source = "qrc:/icons/" + appearance.themeName + "/play.svg"
                        }
                    }
                }
            }
