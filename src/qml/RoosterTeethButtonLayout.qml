import QtQuick 2.0
import player 1.0

Item {
    objectName: "buttonLayout"
    id: layout
    anchors.fill: controlsBar

    PlayPauseButton {
        id: playPauseButton
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
    }

    MouseArea {
        id: mouseAreaVolumeArea
        anchors {
            right: volumeSliderArea.right
            bottom: volumeButton.bottom
            left: volumeButton.left
        }
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
        anchors {
            left: playPauseButton.right
            top: parent.top
            bottom: parent.bottom
        }
        hoverEnabled: true
    }

    VerticalVolume {
        id: volumeSliderArea
        anchors {
            bottom: volumeButton.top
            left: volumeButton.left
            right: volumeButton.right
        }
        width: volumeButton.width
        visible: mouseAreaVolumeArea.containsMouse || volumeButton.hovered
    }

    TimeLabel {
        id: timeLabel
        anchors {
            left: volumeButton.right
            top: parent.top
            bottom: parent.bottom
        }
    }

    VideoProgress {
        id: videoProgressRoosterTeeth
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: timeLabel.right
            leftMargin: parent.width / 128
            right: speedText.left
            rightMargin: parent.width / 128
        }
        height: parent.height
        to: progressBar.to
        value: progressBar.value
        center: true
    }

    SpeedText {
        id: speedText
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: fullscreenButton.left
        }
    }

    FullscreenButton {
        id: fullscreenButton
        anchors {
            right: settingsButton.left
            top: parent.top
            bottom: parent.bottom
        }
    }
    SettingsButton {
        id: settingsButton
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
    }
}
