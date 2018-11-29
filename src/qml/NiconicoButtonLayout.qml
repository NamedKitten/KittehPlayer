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
    anchors.fill: controlsBar

    PlayPauseButton {
        id: playPauseButton
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        height: 16
        width: 26
        icon.height: 16
        icon.width: 26
    }
    VolumeButton {
        id: volumeButton
        anchors.left: playPauseButton.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        icon.height: 16
        icon.width: 16
    }
    VolumeSlider {
        anchors.left: volumeButton.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }

    PlaylistPrevButton {
        id: playlistPrevButton
        anchors.right: backwardButton.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        icon.height: 16
        icon.width: 16
    }
    BackwardButton {
        id: backwardButton
        anchors.right: timeLabel.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        icon.height: 32
        icon.width: 32
    }
    TimeLabel {
        id: timeLabel
        anchors.centerIn: parent
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
    ForwardButton {
        id: forwardButton
        anchors.left: timeLabel.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        icon.height: 32
        icon.width: 32
    }
    PlaylistNextButton {
        id: playlistNextButton
        anchors.left: forwardButton.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        icon.height: 16
        icon.width: 16
    }

    FullscreenButton {
        id: fullscreenButton
        anchors.right: settingsButton.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        icon.height: 16
        icon.width: 16
    }
    SettingsButton {
        id: settingsButton
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        icon.height: 16
        icon.width: 16
    }
}
