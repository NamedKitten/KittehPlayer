import QtQuick 2.11
import QtQuick.Controls 2.4
import Qt.labs.settings 1.0
import player 1.0

Rectangle {
    id: chapterMarker
    property int time: 0
    color: getAppearanceValueForTheme(appearance.themeName,
                                      "chapterMarkerColor")
    Connections {
        target: player
        enabled: true
        onChaptersChanged: {
            chapterMarker.destroy()
        }
    }

    width: 4
    height: parent.height
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    x: progressBar.background.width / progressBar.to * time
    z: 9000
}
