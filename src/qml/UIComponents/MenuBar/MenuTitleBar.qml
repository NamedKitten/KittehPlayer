import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Window 2.2

Item {
  id: menuTitleBar
  height: menuBar.height
  visible: mainWindow.controlsShowing
  
  function anythingOpen() {
    return menuBar.anythingOpen()
  }

  anchors {
    left: parent.left
    right: parent.right
    top: parent.top
  }

  MainMenu {
    id: menuBar
  }

  Rectangle {
    height: menuBar.height
    color: getAppearanceValueForTheme(appearance.themeName, "mainBackground")
    anchors {
      right: parent.right
      left: menuBar.right
      top: parent.top
    }

    Text {
      id: titleLabel
      objectName: "titleLabel"
      text: translate.getTranslation("TITLE", i18n.language)
      color: "white"
      width: parent.width
      height: parent.height
      fontSizeMode: Text.VerticalFit
      opacity: 1
      visible: menuTitleBar.visible
               && ((!appearance.titleOnlyOnFullscreen)
                   || (mainWindow.visibility == Window.FullScreen
                       || mainWindow.visibility == Window.Maximized))
      font {
        family: appearance.fontName
        bold: true
        pixelSize: appearance.scaleFactor * (height - anchors.topMargin - anchors.bottomMargin - 2)
      }
      anchors {
        left: parent.left
        leftMargin: 4
        bottom: parent.bottom
        bottomMargin: 4
        top: parent.top
      }

      Connections {
        target: player
        onTitleChanged: function (title) {
          titleLabel.text = title
          mainWindow.title = "KittehPlayer - " + title
        }
      }
    }
  }
}
