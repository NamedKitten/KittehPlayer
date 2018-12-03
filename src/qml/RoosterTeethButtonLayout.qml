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
        icon.height: parent.height / 2
        icon.width: parent.height / 2
    }

    MouseArea {
        id: mouseAreaVolumeArea
        anchors.bottom: volumeButton.bottom
        anchors.left: volumeSliderArea.left
        anchors.right: volumeSliderArea.right
        anchors.top: volumeSliderArea.top
        height: layout.height + volumeButton.height
                + (volumeSliderArea.visible ? volumeSliderArea.height : 0)
        hoverEnabled: true
        propagateComposedEvents: true
        acceptedButtons: Qt.NoButton

        onEntered: {
            mouseAreaPlayerTimer.stop()
        }

        onExited: {
            mouseAreaPlayerTimer.restart()
        }
    }

    VolumeButton {
        id: volumeButton
        anchors.left: playPauseButton.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        icon.height: parent.height / 2
        icon.width: parent.height / 2
        icon.color: hovered
                    || mouseAreaVolumeArea.containsMouse ? getAppearanceValueForTheme(
                                                               appearance.themeName,
                                                               "buttonHoverColor") : getAppearanceValueForTheme(
                                                               appearance.themeName,
                                                               "buttonColor")
    }

    VerticalVolume {
        id: volumeSliderArea
        anchors.bottom: volumeButton.top
        anchors.left: volumeButton.left
        anchors.right: volumeButton.right
        width: volumeButton.width
        visible: mouseAreaVolumeArea.containsMouse || volumeButton.hovered
    }

    TimeLabel {
        id: timeLabel
        anchors.left: volumeButton.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }

    VideoProgress {
        id: videoProgressRoosterTeeth
        anchors.left: timeLabel.right
        anchors.right: speedText.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        height: parent.height
        to: progressBar.to
        value: progressBar.value
    }

    SpeedText {
        id: speedText
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: fullscreenButton.left
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
