import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Window 2.2
import Qt.labs.settings 1.0
import player 1.0

Window {
  id: mainWindow
  title: "KittehPlayer"
  visible: true
  width: Math.min(720, Screen.width)
  height: Math.min(480, Screen.height)
  property bool controlsShowing: true
  property int virtualHeight: Screen.height * appearance.scaleFactor
  property int virtualWidth: Screen.width * appearance.scaleFactor
  property bool onTop: false

  QMLDebugger {
    id: qmlDebugger
  }

  Item {
    id: globalConnections
    signal showUI
    signal hideUI
  }

  function getAppearanceValueForTheme(themeName, name) {
    switch (themeName) {
    case "YouTube":
      return youTubeAppearance[name]
    case "Niconico":
      return nicoNicoAppearance[name]
    case "RoosterTeeth":
      return roosterTeethAppearance[name]
    default:
      appearance.themeName = "YouTube"
      return youTubeAppearance[name]
    }
  }

  Translator {
    id: translate
  }

  Settings {
    id: loggingSettings
    category: "Logging"
    property string logFile: "/tmp/KittehPlayer.log"
    property bool logBackend: true
  }

  Settings {
    id: backendSettings
    category: "Backend"
    property string backend: "mpv"
    property bool fbo: true
    property bool direct: false
  }

  Settings {
    id: appearance
    category: "Appearance"
    property bool titleOnlyOnFullscreen: true
    property string themeName: "YouTube"
    property string fontName: "Roboto"
    property double scaleFactor: 1.0
    property int subtitlesFontSize: 24
    property int uiFadeTimer: 1000
    property bool doubleTapToSeek: true
    property double doubleTapToSeekBy: 5
    property bool swipeToResize: true
    // Can fix some screen tearing on some devices.
    property bool maximizeInsteadOfFullscreen: false
  }

  Settings {
    id: youTubeAppearance
    category: "YouTubeAppearance"
    property string mainBackground: "#9C000000"
    property string progressBackgroundColor: "#33FFFFFF"
    property string progressCachedColor: "#66FFFFFF"
    property string buttonColor: "white"
    property string buttonHoverColor: "white"
    property string progressSliderColor: "red"
    property string chapterMarkerColor: "#fc0"
    property string volumeSliderBackground: "white"
  }

  Settings {
    id: nicoNicoAppearance
    category: "NicoNicoAppearance"
    property string mainBackground: "#9C000000"
    property string progressBackgroundColor: "#444"
    property string progressCachedColor: "#66FFFFFF"
    property string buttonColor: "white"
    property string buttonHoverColor: "white"
    property string progressSliderColor: "#007cff"
    property string chapterMarkerColor: "#fc0"
    property string volumeSliderBackground: "#007cff"
  }

  Settings {
    id: roosterTeethAppearance
    category: "RoosterTeethAppearance"
    property string mainBackground: "#CC2B333F"
    property string progressBackgroundColor: "#444"
    property string progressCachedColor: "white"
    property string buttonColor: "white"
    property string buttonHoverColor: "#c9373f"
    property string progressSliderColor: "#c9373f"
    property string chapterMarkerColor: "#fc0"
    property string volumeSliderBackground: "#c9373f"
  }

  Settings {
    id: i18n
    category: "I18N"
    property string language: "english"
  }

  Settings {
    id: fun
    category: "Fun"
    property bool nyanCat: false
  }

  Settings {
    id: keybinds
    category: "Keybinds"
    property string playPause: "K"
    property string forward10: "L"
    property string rewind10: "J"
    property string forward5: "Right"
    property string rewind5: "Left"
    property string openFile: "Ctrl+O"
    property string openURI: "Ctrl+Shift+O"
    property string quit: "Ctrl+Q"
    property string fullscreen: "F"
    property string tracks: "Ctrl+T"
    property string statsForNerds: "I"
    property string forwardFrame: "."
    property string backwardFrame: ","
    property string cycleSub: "Alt+S"
    property string cycleSubBackwards: "Alt+Shift+S"
    property string cycleAudio: "A"
    property string cycleVideo: "V"
    property string cycleVideoAspect: "Shift+A"
    property string screenshot: "S"
    property string screenshotWithoutSubtitles: "Shift+S"
    property string fullScreenshot: "Ctrl+S"
    property string nyanCat: "Ctrl+N"
    property string decreaseSpeedByPointOne: "["
    property string increaseSpeedByPointOne: "]"
    property string halveSpeed: "{"
    property string doubleSpeed: "}"
    property string increaseVolume: "*"
    property string decreaseVolume: "/"
    property string mute: "m"
    property string increaseScale: "Ctrl+Shift+="
    property string resetScale: "Ctrl+Shift+0"
    property string decreaseScale: "Ctrl+Shift+-"
    property string customKeybind0: ""
    property string customKeybind0Command: ""
    property string customKeybind1: ""
    property string customKeybind1Command: ""
    property string customKeybind2: ""
    property string customKeybind2Command: ""
    property string customKeybind3: ""
    property string customKeybind3Command: ""
    property string customKeybind4: ""
    property string customKeybind4Command: ""
    property string customKeybind5: ""
    property string customKeybind5Command: ""
    property string customKeybind6: ""
    property string customKeybind6Command: ""
    property string customKeybind7: ""
    property string customKeybind7Command: ""
    property string customKeybind8: ""
    property string customKeybind8Command: ""
    property string customKeybind9: ""
    property string customKeybind9Command: ""
  }

  property int lastScreenVisibility

  function toggleFullscreen() {
    var fs = Window.FullScreen
    if (appearance.maximizeInsteadOfFullscreen) {
      fs = Window.Maximized
    }

    if (mainWindow.visibility != fs) {
      lastScreenVisibility = mainWindow.visibility
      mainWindow.visibility = fs
    } else {
      mainWindow.visibility = lastScreenVisibility
    }
  }

  Utils {
    id: utils
  }

  PlayerBackend {
    id: player
    anchors.fill: parent
    width: parent.width
    height: parent.height
    logging: loggingSettings.logBackend
    z: 1

    Action {
      onTriggered: {
        appearance.scaleFactor += 0.1
      }
      shortcut: keybinds.increaseScale
    }
    Action {
      onTriggered: {
        appearance.scaleFactor = 1
      }
      shortcut: keybinds.resetScale
    }
    Action {
      onTriggered: {
        appearance.scaleFactor -= 0.1
      }
      shortcut: keybinds.decreaseScale
    }

    function startPlayer() {
      //console.info(qmlDebugger.properties(player))
      console.info("OwO!")

      var args = Qt.application.arguments
      var len = Qt.application.arguments.length
      var argNo = 0
      if (len > 1) {
        for (argNo = 1; argNo < len; argNo++) {
          var argument = args[argNo]
          if (argument.indexOf("KittehPlayer") !== -1) {
            continue
          }
          if (argument.startsWith("--")) {
            argument = argument.substr(2)
            if (argument.length > 0) {
              var splitArg = argument.split(/=(.+)/)
              if (splitArg[0] == "screen" || splitArg[0] == "fs-screen") {
                for (var i = 0, len = Qt.application.screens.length; i < len; i++) {
                  var screen = Qt.application.screens[i]
                  console.log(
                        "Screen Name: " + screen["name"] + " Screen Number: " + String(
                          i))
                  if (screen["name"] == splitArg[1] || String(
                        i) == splitArg[1]) {
                    console.log("Switching to screen: " + screen["name"])
                    mainWindow.screen = screen
                    mainWindow.width = mainWindow.screen.width / 2
                    mainWindow.height = mainWindow.screen.height / 2
                    mainWindow.x = mainWindow.screen.virtualX + mainWindow.width / 2
                    mainWindow.y = mainWindow.screen.virtualY + mainWindow.height / 2
                    if (splitArg[0] == "fs-screen") {
                      toggleFullscreen()
                    }
                    continue
                  }
                }
                continue
              }
              if (splitArg[0] == "fullscreen") {
                toggleFullscreen()
                continue
              }
              if (splitArg[1] == undefined || splitArg[1].length == 0) {
                splitArg[1] = "yes"
              }
              player.setOption(splitArg[0], splitArg[1])
            }
          } else {
            player.playerCommand(Enums.Commands.AppendFile, argument)
          }
        }
      }
    }
  }

  Item {
    id: controlsOverlay
    anchors.centerIn: player
    height: player.height
    width: player.width
    z: 2

    MouseArea {
      id: mouseAreaBar
      width: parent.width
      height: controlsBar.combinedHeight * 1.5
      hoverEnabled: true
      anchors {
        bottom: parent.bottom
        bottomMargin: 0
      }
      onEntered: {
        mouseAreaPlayerTimer.stop()
      }
    }

    MouseArea {
      id: mouseAreaPlayer
      z: 10
      focus: true
      width: parent.width
      hoverEnabled: true
      propagateComposedEvents: true
      cursorShape: mainWindow.controlsShowing ? Qt.ArrowCursor : Qt.BlankCursor
      property real velocity: 0.0
      property int xStart: 0
      property int xPrev: 0
      anchors {
        bottom: mouseAreaBar.top
        bottomMargin: 10
        right: parent.right
        rightMargin: 0
        left: parent.left
        leftMargin: 0
        top: topBar.bottom
        topMargin: 0
      }

      Timer {
        id: mouseTapTimer
        interval: 200
        onTriggered: {
          mainWindow.controlsShowing = !mainWindow.controlsShowing || topBar.anythingOpen() || mouseAreaTopBar.containsMouse
          mouseAreaPlayerTimer.restart()
        }
      }

      function doubleMouseClick(mouse) {
        if (appearance.doubleTapToSeek) {
          if (mouse.x > (mouseAreaPlayer.width / 2)) {
            player.playerCommand(Enums.Commands.Seek,
                                 String(appearance.doubleTapToSeekBy))
          } else {
            player.playerCommand(Enums.Commands.Seek,
                                 "-" + String(appearance.doubleTapToSeekBy))
          }
        } else {
          toggleFullscreen()
        }
      }
      onClicked: function (mouse) {
        xStart = mouse.x
        xPrev = mouse.x
        velocity = 0
        if (mouseTapTimer.running) {
          doubleMouseClick(mouse)
          mouseTapTimer.stop()
        } else {
          mouseTapTimer.restart()
        }
      }
      onReleased: {
        var isLongEnough = Math.sqrt(xStart * xStart,
                                     mouse.x * mouse.x) > mainWindow.width * 0.3
        if (velocity > 2 && isLongEnough) {
          appearance.scaleFactor += 0.2
        } else if (velocity < -2 && isLongEnough) {
          if (appearance.scaleFactor > 0.8) {
            appearance.scaleFactor -= 0.2
          }
        }
      }
      onPositionChanged: {
        if (mouseAreaPlayer.containsPress) {
          var currVel = (mouse.x - xPrev)
          velocity = (velocity + currVel) / 2.0
          xPrev = mouse.x
        }
        mainWindow.controlsShowing = true
        mouseAreaPlayerTimer.restart()
      }
      Action {
        onTriggered: {
          toggleFullscreen()
        }
        shortcut: "Esc"
      }

      Timer {
        id: mouseAreaPlayerTimer
        interval: appearance.uiFadeTimer
        running: (!appearance.uiFadeTimer == 0)
        repeat: false
        onTriggered: {
          if (!(appearance.uiFadeTimer == 0)) {
            mainWindow.controlsShowing = !mainWindow.controlsShowing || topBar.anythingOpen() || mouseAreaTopBar.containsMouse
          }
        }
      }
    }

    Timer {
      id: statsUpdater
      interval: 1000
      running: statsForNerdsText.visible
      repeat: true
      onTriggered: {
        statsForNerdsText.text = player.getStats()
      }
    }

    Text {
      id: statsForNerdsText
      text: ""
      color: "white"
      visible: false
      height: parent.height
      width: parent.width
      textFormat: Text.RichText
      horizontalAlignment: Text.AlignLeft
      verticalAlignment: Text.AlignTop
      renderType: Text.NativeRendering
      lineHeight: 1
      font {
        family: appearance.fontName
        pixelSize: mainWindow.virtualHeight / 50
      }
      anchors {
        fill: parent
        topMargin: mainWindow.virtualHeight / 20
        leftMargin: mainWindow.virtualHeight / 20
      }
      Component.onCompleted: {
        console.error(statsForNerdsText.lineHeight, font.pixelSize)
      }
    }

    MenuTitleBar {
      id: topBar
      z: 200
    }

    ControlsBar {
      id: controlsBar
    }
  }
  MouseArea {
    id: mouseAreaTopBar
    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
    }
    height: topBar.height * 3
    hoverEnabled: true
    propagateComposedEvents: true
  } 

  MouseArea {
    anchors.fill: parent
    onExited: {
      mouseAreaPlayerTimer.start()
    }
  }
}
