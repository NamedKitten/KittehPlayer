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
    height: parent.height

    PlaylistPrevButton {
        id: playlistPrevButton
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: visible ? playlistNextButton.width : 0
        icon.height: parent.height / 2
        icon.width: parent.height / 2
    }
    PlayPauseButton {
        id: playPauseButton
        anchors.left: playlistPrevButton.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        icon.height: parent.height / 2
        icon.width: parent.height / 2
    }
    PlaylistNextButton {
        id: playlistNextButton
        anchors.left: playPauseButton.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        icon.height: parent.height / 2
        icon.width: parent.height / 2
    }

    MouseArea {
        id: mouseAreaVolumeArea
        anchors.bottom: parent.bottom
        anchors.left: volumeButton.left
        anchors.right: volumeSlider.right
        anchors.top: parent.top
        width: volumeButton.width + (volumeSlider.visible ? volumeSlider.width : 0)
        hoverEnabled: true
        propagateComposedEvents: true
        acceptedButtons: Qt.NoButton
    }

    VolumeButton {
        id: volumeButton
        anchors.left: playlistNextButton.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        icon.height: parent.height / 2
        icon.width: parent.height / 2
    }
    VolumeSlider {
        id: volumeSlider
        anchors.left: volumeButton.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        height: parent.height
        visible: mouseAreaVolumeArea.containsMouse || volumeButton.hovered
        width: visible ? implicitWidth : 0
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
        icon.height: parent.height / 2
        icon.width: parent.height / 2
    }
    FullscreenButton {
        id: fullscreenButton
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        icon.height: parent.height / 2
        icon.width: parent.height / 2
    }
}
