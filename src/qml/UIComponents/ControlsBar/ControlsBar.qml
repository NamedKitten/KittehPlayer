import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.2
import player 1.0

Item {
  id: controlsBarItem
  property var combinedHeight: progressBar.height + controlsBackground.height
  anchors {
    bottom: parent.bottom
    left: parent.left
    right: parent.right
  }

  Connections {
    target: appearance
    onThemeNameChanged: setControlsTheme(appearance.themeName)
  }

  function setControlsTheme(themeName) {
    for (var i = 0; i < controlsBar.children.length; ++i) {
      if (controlsBar.children[i].objectName == "buttonLayout") {
        controlsBar.children[i].destroy()
      }
    }

    var component = Qt.createComponent(themeName + "ButtonLayout.qml")
    if (component.status == Component.Error) {
      console.error("Error loading component: " + component.errorString())
    }
    component.createObject(controlsBar, {})
  }

  VideoProgress {
    id: progressBar
    visible: mainWindow.controlsShowing
             && appearance.themeName != "RoosterTeeth"
    bottomPadding: 0
    rightPadding: 0
    leftPadding: 0
    z: 20
    anchors {
      bottom: controlsBackground.top
      left: controlsBackground.left
      right: controlsBackground.right
      leftMargin: parent.width / 128
      rightMargin: parent.width / 128
      bottomMargin: 0
    }
  }

  Rectangle {
    id: controlsBackground
    height: controlsBar.visible ? controlsBar.height
                                  + (appearance.themeName
                                     == "RoosterTeeth" ? 0 : progressBar.topPadding) : 0
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: getAppearanceValueForTheme(appearance.themeName, "mainBackground")
    visible: mainWindow.controlsShowing
    z: 10
    anchors {
      bottom: parent.bottom
      left: parent.left
      right: parent.right
    }
  }

  Item {
    id: controlsBar
    height: mainWindow.controlsShowing ? mainWindow.virtualHeight / 20 : 0
    visible: mainWindow.controlsShowing
    z: 30
    anchors {
      right: parent.right
      rightMargin: parent.width / 128
      left: parent.left
      leftMargin: parent.width / 128
      bottom: parent.bottom
      bottomMargin: 0
    }
  }

  Component.onCompleted: {
    setControlsTheme(appearance.themeName)
  }
}
