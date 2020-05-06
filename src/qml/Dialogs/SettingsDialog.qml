import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import player 1.0

Dialog {
  id: settingsDialog
  title: translate.getTranslation("SETTINGS", i18n.language)
  height: 100
  width: 720
  modality: Qt.NonModal

  signal done

  ScrollView {
    id: content
    height: parent.height
    width: parent.width
    clip: true
    ScrollBar.vertical.policy: ScrollBar.AlwaysOn
    Item {
      id: settingsContent
      implicitHeight: childrenRect.height
      implicitWidth: childrenRect.width
      ColumnLayout {
        Text {
          height: 30
          text: translate.getTranslation("LANGUAGE", i18n.language)
          verticalAlignment: Text.AlignVCenter
        }
        LanguageSettings {
          Layout.leftMargin: 30
        }
        Text {
          height: 30
          text: translate.getTranslation("APPEARANCE", i18n.language)
          verticalAlignment: Text.AlignVCenter
        }
        CheckBox {
          checked: appearance.titleOnlyOnFullscreen
          onClicked: appearance.titleOnlyOnFullscreen = !appearance.titleOnlyOnFullscreen
          text: translate.getTranslation("TITLE_ONLY_ON_FULLSCREEN",
                                         i18n.language)
          Layout.leftMargin: 30
        }
        CheckBox {
          checked: appearance.doubleTapToSeek
          onClicked: appearance.doubleTapToSeek = !appearance.doubleTapToSeek
          text: translate.getTranslation("DOUBLE_TAP_TO_SEEK", i18n.language)
          Layout.leftMargin: 30
        }
        Item {
          Layout.leftMargin: 30
          Layout.bottomMargin: 10
          height: 30
          Text {
            id: seekByLabel
            height: 30
            text: translate.getTranslation("DOUBLE_TAP_TO_SEEK_BY",
                                           i18n.language)
            verticalAlignment: Text.AlignVCenter
          }
          TextField {
            id: seekBy
            anchors.left: seekByLabel.right
            anchors.leftMargin: 10
            validator: IntValidator {}
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            text: appearance.doubleTapToSeekBy
            function setSeekBy() {
              appearance.doubleTapToSeekBy = parseInt(seekBy.text)
            }
            onEditingFinished: setSeekBy()
          }
        }
        Item {
          height: 30
          Layout.bottomMargin: 10
          Layout.leftMargin: 30
          Text {
            id: fontLabel
            height: 30
            text: translate.getTranslation("FONT", i18n.language)
            verticalAlignment: Text.AlignVCenter
          }
          TextField {
            id: fontInput
            anchors.left: fontLabel.right
            anchors.leftMargin: 10
            text: appearance.fontName
            function setFont() {
              appearance.fontName = fontInput.text
            }
            onEditingFinished: setFont()
          }
        }
        Item {
          Layout.leftMargin: 30
          Layout.bottomMargin: 10
          height: 30
          Text {
            id: subtitlesFontSizeLabel
            height: 30
            text: translate.getTranslation("SUBTITLES_FONT_SIZE", i18n.language)
            verticalAlignment: Text.AlignVCenter
          }
          TextField {
            id: subtitlesFontSizeInput
            anchors.left: subtitlesFontSizeLabel.right
            anchors.leftMargin: 10
            validator: IntValidator {}
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            text: appearance.subtitlesFontSize
            function setSubtitlesFontSize() {
              appearance.subtitlesFontSize = parseInt(
                    subtitlesFontSizeInput.text)
            }
            onEditingFinished: setSubtitlesFontSize()
          }
        }
        Item {
          Layout.leftMargin: 30
          Layout.bottomMargin: 10
          height: 30
          Text {
            id: uiFadeTimeLabel
            height: 30
            text: translate.getTranslation("UI_FADE_TIME", i18n.language)
            verticalAlignment: Text.AlignVCenter
          }
          TextField {
            id: uiFadeTimeInput
            anchors.left: uiFadeTimeLabel.right
            anchors.leftMargin: 10
            validator: IntValidator {
              bottom: 0
            }
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            text: appearance.uiFadeTimer
            function setUIFadeTime() {
              appearance.uiFadeTimer = parseInt(uiFadeTimeInput.text)
            }
            onEditingFinished: setUIFadeTime()
          }
        }
      }
    }
  }

  Connections {
    target: settingsDialog
    onAccepted: {
      seekBy.setSeekBy()
      fontInput.setFont()
      subtitlesFontSizeInput.setSubtitlesFontSize()
      uiFadeTimeInput.setUIFadeTime()
      settingsDialog.done()
    }
  }
  Component.onCompleted: {
    settingsDialog.open()
  }
}
