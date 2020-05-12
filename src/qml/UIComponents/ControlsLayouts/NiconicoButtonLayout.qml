import QtQuick 2.0
import player 1.0

Item {
  objectName: "buttonLayout"
  id: layout
  anchors.fill: controlsBar

  PlayPauseButton {
    id: playPauseButton
    anchors {
      left: parent.left
      top: parent.top
      bottom: parent.bottom
    }
  }
  VolumeButton {
    id: volumeButton
    anchors {
      left: playPauseButton.right
      top: parent.top
      bottom: parent.bottom
    }
  }
  VolumeSlider {
    anchors {
      left: volumeButton.right
      top: parent.top
      bottom: parent.bottom
    }
  }

  PlaylistPrevButton {
    id: playlistPrevButton
    anchors {
      right: backwardButton.left
      top: parent.top
      bottom: parent.bottom
    }
  }
  BackwardButton {
    id: backwardButton
    anchors {
      right: timeLabel.left
      top: parent.top
      bottom: parent.bottom
    }
  }
  TimeLabel {
    id: timeLabel
    anchors {
      centerIn: parent
      top: parent.top
      bottom: parent.bottom
    }
  }
  ForwardButton {
    id: forwardButton
    anchors {
      left: timeLabel.right
      top: parent.top
      bottom: parent.bottom
    }
  }
  PlaylistNextButton {
    id: playlistNextButton
    anchors {
      left: forwardButton.right
      top: parent.top
      bottom: parent.bottom
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
