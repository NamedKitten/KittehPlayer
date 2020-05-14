import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import QtQuick.Window 2.2
import player 1.0

Dialog {
  id: debugDialog
  title: "Debug"
  height: 480
  width: 720
  modality: Qt.NonModal
  standardButtons: Dialog.NoButton

  Component {
      id: delegate
      Item {
          width: 200; height: 30
          Label {
              text: theOutput
          }
      }
  }

  ListModel {
    id: modelly
  }

  ListView {
    id: output
    model: modelly
    delegate: delegate
    height: 50
    width: parent.width
    anchors {
     top: parent.top
     bottom: input.top
     left: parent.left
     right: parent.right
    }
  }


  TextField {
    id: input
    width: parent.width
    height: 40
    anchors {
      bottom: parent.bottom
      left: parent.left
      right: parent.right
    }
    text: "h"
    function doJsEval() {
      var output;
      try {
        let result = eval(input.text)
        output = result instanceof Array ? "[" + String(result) + "]" : String(result)
        modelly.append({theOutput: output})
      } catch (e) {
        output = String(e)
        modelly.append({theOutput: output})
      }
    }

    Keys.onReturnPressed: {
      doJsEval()
      event.accepted = true
    }
  }
  Action {
    shortcut: "Ctrl+Shift+i"
    onTriggered: {
      debugDialog.open()
    }
  }
}
