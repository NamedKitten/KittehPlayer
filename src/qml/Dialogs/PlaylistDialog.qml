import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.3
import QtQuick.Window 2.11
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

Dialog {
    id: playlistDialog
    title: "Playlist"
    height: Math.max(480, childrenRect.height * playlistListView.count)
    width: 720
    modality: Qt.NonModal
    Connections {
        target: player
        enabled: true
        onPlaylistChanged: function(playlist) {
            playlistModel.clear()
            for (var thing in playlist) {
                var item = playlist[thing]
                playlistModel.append({
                                        playlistItemTitle: item["title"],
                                        playlistItemFilename: item["filename"],
                                        current: item["current"],
                                        playlistPos: thing
                                    })
            }
        }
    }

    Component {
        id: playlistDelegate
        Item {
            id: playlistItem
            width: playlistDialog.width
            height: childrenRect.height
            Button {
                width: parent.width
                id: playlistItemButton
                font.pixelSize: 12
                padding: 0
                bottomPadding: 0
                contentItem: Text {
                    id: playlistItemText
                    font: parent.font
                    bottomPadding: 0
                    color: "white"
                    text: playlistItemButton.text
                    height: parent.height
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                }

                onClicked: {
                    player.playerCommand(Enums.Commands.SetPlaylistPos,
                                         playlistPos)
                }
                background: Rectangle {
                    color: current ? "orange" : "transparent"
                }
            }

            Component.onCompleted: {
                var itemText = ""
                if (typeof playlistItemTitle !== "undefined") {
                    itemText += '<b>Title:</b> ' + playlistItemTitle + "<br>"
                }
                if (typeof playlistItemFilename !== "undefined") {
                    itemText += '<b>Filename:</b> ' + playlistItemFilename
                }
                playlistItemText.text = itemText
            }
        }
    }

    ListView {
        id: playlistListView
        anchors.fill: parent
        model: ListModel {
            id: playlistModel
        }
        delegate: playlistDelegate
        highlight: Item {
        }
        focus: true
    }
}
