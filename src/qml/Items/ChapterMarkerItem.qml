import QtQuick 2.0
import QtQuick.Controls 2.3
import Qt.labs.settings 1.0
import player 1.0

Rectangle {
    id: chapterMarker
    property int time: 0
    color: getAppearanceValueForTheme(appearance.themeName,
                                      "chapterMarkerColor")
    width: 4
    height: parent.height
    x: progressBar.background.width / progressBar.to * time
    z: 9000
    anchors {
        top: parent.top
        bottom: parent.bottom
    }

    Connections {
        target: player
        enabled: true
        onChaptersChanged: {
            chapterMarker.destroy()
        }
    }
}
