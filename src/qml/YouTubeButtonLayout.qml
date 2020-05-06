import QtQuick 2.0
import player 1.0

Item {
  objectName: "buttonLayout"
  id: layout
  anchors.fill: controlsBar
  height: parent.height

  PlaylistPrevButton {
    id: playlistPrevButton
    anchors {
      left: parent.left
      top: parent.top
      bottom: parent.bottom
    }
    width: visible ? playlistNextButton.width : 0
  }
  PlayPauseButton {
    id: playPauseButton
    anchors {
      left: playlistPrevButton.right
      top: parent.top
      bottom: parent.bottom
    }
    leftPadding: 14
  }
  PlaylistNextButton {
    id: playlistNextButton
    anchors {
      left: playPauseButton.right
      top: parent.top
      bottom: parent.bottom
    }
  }

  MouseArea {
    id: mouseAreaVolumeArea
    anchors.fill: volumeSlider
    width: volumeSlider.width
    hoverEnabled: true
    propagateComposedEvents: true
    acceptedButtons: Qt.NoButton
    z: 100
  }

  VolumeButton {
    id: volumeButton
    anchors {
      left: playlistNextButton.right
      top: parent.top
      bottom: parent.bottom
    }
    z: 50
  }
  VolumeSlider {
    id: volumeSlider
    anchors {
      left: volumeButton.right
      top: parent.top
      bottom: parent.bottom
    }
    height: parent.height
    visible: mouseAreaVolumeArea.containsMouse || volumeButton.hovered
    width: visible ? implicitWidth : 0
  }
  TimeLabel {
    anchors {
      left: volumeSlider.right
      top: parent.top
      bottom: parent.bottom
      leftMargin: parent.width / 128
    }
  }

  SettingsButton {
    id: settingsButton
    anchors {
      right: fullscreenButton.left
      top: parent.top
      bottom: parent.bottom
    }
  }
  FullscreenButton {
    id: fullscreenButton
    anchors {
      right: parent.right
      top: parent.top
      bottom: parent.bottom
    }
  }
}
