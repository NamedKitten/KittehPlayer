import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

Item {
    objectName: "buttonLayout"
    id: layout

    PlaylistPrevButton {
        id: playlistPrevButton
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: visible ? playlistNextButton.width : 0
    }
    PlayPauseButton {
        id: playPauseButton
        anchors.left: playlistPrevButton.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
    PlaylistNextButton {
        id: playlistNextButton
        anchors.left: playPauseButton.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }

    VolumeButton {
        id: volumeButton
        anchors.left: playlistNextButton.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
    VolumeSlider {
        id: volumeSlider
        anchors.left: volumeButton.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
    TimeLabel {
        anchors.left: volumeSlider.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }

    SettingsButton {
        id: settingsButton
        anchors.right: fullscreenButton.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
    FullscreenButton {
        id: fullscreenButton
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
}
