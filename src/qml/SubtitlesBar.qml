import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import player 1.0

Item {
  id: subtitlesBar
  visible: !appearance.useMpvSubs
  height: player.height / 8
  anchors {
    bottomMargin: 5
    right: parent.right
    left: parent.left
  }
  RowLayout {
    id: nativeSubtitles
    height: childrenRect.height
    visible: true
    anchors {
      left: subtitlesBar.left
      right: subtitlesBar.right
      bottom: parent.bottom
      bottomMargin: 10
    }
    Item {
      id: subsContainer
      height: childrenRect.height
      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.rightMargin: 0
      Layout.leftMargin: 0
      Layout.maximumWidth: nativeSubtitles.width
      Label {
        id: nativeSubs
        objectName: "nativeSubs"
        anchors.horizontalCenter: parent.horizontalCenter
        color: "white"
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        horizontalAlignment: Text.AlignHCenter
        opacity: 1
        font {
          pixelSize: appearance.subtitlesFontSize
          family: appearance.fontName
        }
        background: Rectangle {
          id: subsBackground
          color: getAppearanceValueForTheme(appearance.themeName,
                                            "mainBackground")
          width: subsContainer.childrenRect.width
          height: subsContainer.childrenRect.height
        }
        onWidthChanged: {
          if (width > parent.width - 10)
            width = parent.width - 10
        }
        onTextChanged: if (width <= parent.width - 10)
                         width = undefined
        Connections {
          target: player
          onSubtitlesChanged: function (subtitles) {
            nativeSubs.text = subtitles
          }
        }
      }
    }
  }
}
