import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

Item {
    objectName: "buttonLayout"
    id: layout
    anchors.fill: controlsBar

    PlayPauseButton {
        id: playPauseButton
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        icon.height: parent.height / 2
        icon.width: parent.height / 2
    }
    VolumeButton {
        id: volumeButton
        anchors.left: playPauseButton.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        icon.height: parent.height / 2
        icon.width: parent.height / 2
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
        icon.height: parent.height / 2
        icon.width: parent.height / 2
    }
    BackwardButton {
        id: backwardButton
        anchors.right: timeLabel.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        icon.height: parent.height / 2
        icon.width: parent.height / 2
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
        icon.height: parent.height / 2
        icon.width: parent.height / 2
    }
    PlaylistNextButton {
        id: playlistNextButton
        anchors.left: forwardButton.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        icon.height: parent.height / 2
        icon.width: parent.height / 2
    }

    FullscreenButton {
        id: fullscreenButton
        anchors.right: settingsButton.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        icon.height: parent.height / 2
        icon.width: parent.height / 2
    }
    SettingsButton {
        id: settingsButton
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        icon.height: parent.height / 2
        icon.width: parent.height / 2
    }
}
