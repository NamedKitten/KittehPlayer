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
    height: parent.height

    PlaylistPrevButton {
        id: playlistPrevButton
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: visible ? playlistNextButton.width : 0
        iconHeight: parent.height / 1.25
        iconWidth: parent.height / 1.25
    }
    PlayPauseButton {
        id: playPauseButton
        anchors.left: playlistPrevButton.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        iconHeight: parent.height / 1.25
        iconWidth: parent.height / 1.25
    }
    PlaylistNextButton {
        id: playlistNextButton
        anchors.left: playPauseButton.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        iconHeight: parent.height / 1.25
        iconWidth: parent.height / 1.25
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
        z: 500
    }

    VolumeButton {
        id: volumeButton
        anchors.left: playlistNextButton.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        iconHeight: parent.height / 1.25
        iconWidth: parent.height / 1.25
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
        iconHeight: parent.height / 1.25
        iconWidth: parent.height / 1.25
    }
    FullscreenButton {
        id: fullscreenButton
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        iconHeight: parent.height / 1.25
        iconWidth: parent.height / 1.25
    }
}
