import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.3
import QtQuick.Window 2.11
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

Process {
    id: thumbnailerProcess
    property string name: ""
    onFinished: function () {
        if (String(name).indexOf("://") !== -1) {
            playlistDialog.addThumbnailToCache(name, getOutput())
        } else {
            playlistDialog.addThumbnailToCache(name,
                                               "/tmp/" + Qt.md5(name) + ".png")
        }
    }
}
