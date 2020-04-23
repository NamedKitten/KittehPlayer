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
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        iconHeight: parent.height / 1.25
        iconWidth: parent.height / 1.25
    }

    MouseArea {
        id: mouseAreaVolumeArea
        anchors.right: volumeSliderArea.right
        anchors.bottom: volumeButton.bottom
        anchors.left: volumeButton.left
        height: parent.height + (volumeSliderArea.visible ? volumeSliderArea.height : 0)
        hoverEnabled: true
        z: 500
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
        iconHeight: parent.height / 1.25
        iconWidth: parent.height / 1.25
        hoverEnabled: true
        iconColor: hovered
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
        anchors.leftMargin: parent.width / 128
        anchors.rightMargin: parent.width / 128
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        height: parent.height
        to: progressBar.to
        value: progressBar.value
        center: true
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
        iconHeight: parent.height / 1.25
        iconWidth: parent.height / 1.25
    }
    SettingsButton {
        id: settingsButton
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        iconHeight: parent.height / 1.25
        iconWidth: parent.height / 1.25
    }
}
