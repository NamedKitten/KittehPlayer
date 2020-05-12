import QtQuick 2.0

Rectangle {
  id: chapterMarker
  property int time: 0
  color: getAppearanceValueForTheme(appearance.themeName, "chapterMarkerColor")
  width: 4
  height: parent.height
  x: progressBar.background.width / progressBar.to * time
  z: 90000
  anchors {
    top: parent.top
    bottom: parent.bottom
  }

  Connections {
    target: player
    onChaptersChanged: {
      chapterMarker.destroy()
    }
  }
}
