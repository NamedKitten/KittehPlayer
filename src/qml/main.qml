import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

import "codes.js" as LanguageCodes

ApplicationWindow {
    id: mainWindow
    title: titleLabel.text
    visible: true
    width: 720
    height: 480
    Translator {
        id: translate
    }

    property int lastScreenVisibility

    function toggleFullscreen() {
        if (mainWindow.visibility != Window.FullScreen) {
            lastScreenVisibility = mainWindow.visibility
            mainWindow.visibility = Window.FullScreen
        } else {
            mainWindow.visibility = lastScreenVisibility
        }
    }

    PlayerBackend {
        id: player
        anchors.fill: parent
        width: parent.width
        height: parent.height

        Settings {
            id: appearance
            category: "Appearance"
            property bool titleOnlyOnFullscreen: true
            property bool clickToPause: true
            property bool useMpvSubs: false
            property string fontName: "Roboto"
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

        function startPlayer() {
            var args = Qt.application.arguments
            var len = Qt.application.arguments.length
            var argNo = 0

            if (!appearance.useMpvSubs) {
                player.setOption("sub-font", "Noto Sans")
                player.setOption("sub-font-size", "24")
                player.setOption("sub-ass-override", "force")
                player.setOption("sub-ass", "off")
                player.setOption("sub-border-size", "0")
                player.setOption("sub-bold", "off")
                player.setOption("sub-scale-by-window", "on")
                player.setOption("sub-scale-with-window", "on")
                player.setOption("sub-color", "0.0/0.0/0.0/0.0")
                player.setOption("sub-border-color", "0.0/0.0/0.0/0.0")
                player.setOption("sub-back-color", "0.0/0.0/0.0/0.0")
            }

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
                                    var screen = Qt.application.screens[i];
                                    console.log("Screen Name: " + screen["name"] + " Screen Number: " + String(i))
                                    if (screen["name"] == splitArg[1] || String(i) == splitArg[1] ) {
                                        console.log("Switching to screen: " + screen["name"])
                                        mainWindow.screen = screen
                                        mainWindow.width = mainWindow.screen.width / 2
                                        mainWindow.height = mainWindow.screen.height / 2
                                        mainWindow.x = mainWindow.screen.virtualX + mainWindow.width / 2
                                        mainWindow.y = mainWindow.screen.virtualY + mainWindow.height / 2
                                        if (splitArg[0] == "fs-screen" ) {
                                            toggleFullscreen()
                                        }
                                        continue
                                    }
                                }
                                continue
                            }
                            if (splitArg[0] == "fullscreen") {
                                toggleFullscreen()
                                continue;
                            } 
                             if (splitArg[1].length == 0) {
                                splitArg[1] = "true"
                            }
                            player.setOption(splitArg[0], splitArg[1])
                            
                        }
                    } else {
                        player.loadFile(argument)
                    }
                }
            }
        }

        function skipToNinth(val) {
            var skipto = 0
            if (val != 0) {
                skipto = Math.floor(controlsBar.controls.progress.to / 9 * val)
            }
            player.seekAbsolute(skipto)
        }

        function isAnyMenuOpen() {
            return menuBar.anythingOpen
        }

        function hideControls(force) {
            if (!isAnyMenuOpen() || force) {
                controlsBar.controls.visible = false
                controlsBar.background.visible = false
                titleBar.visible = false
                titleBackground.visible = false
                menuBar.visible = false
            }
        }

        function showControls() {
            if (!controlsBar.controls.visible) {
                controlsBar.controls.visible = true
                controlsBar.background.visible = true
                if (appearance.titleOnlyOnFullscreen) {
                    if (mainWindow.visibility == Window.FullScreen) {
                        titleBar.visible = true
                    }
                } else {
                    titleBar.visible = true
                }
                titleBackground.visible = true
                menuBar.visible = true
            }
        }

        MouseArea {
            id: mouseAreaBar
            x: 0
            y: parent.height
            width: parent.width
            height: (controlsBar.controls.height * 2) + controlsBar.progress.height
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            hoverEnabled: true
            onEntered: {
                mouseAreaPlayerTimer.stop()
            }
        }

        MouseArea {
            id: mouseAreaPlayer
            z: 1000
            focus: true
            width: parent.width
            anchors.bottom: mouseAreaBar.top
            anchors.bottomMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: titleBar.bottom
            anchors.topMargin: 0
            hoverEnabled: true
            cursorShape: controlsBar.visible ? Qt.ArrowCursor : Qt.BlankCursor
            onClicked: {
                if (appearance.clickToPause) {
                    player.togglePlayPause()
                }
            }
            Timer {
                id: mouseAreaPlayerTimer
                interval: 1000
                running: true
                repeat: false
                onTriggered: {
                    player.hideControls()
                }
            }
            onPositionChanged: {
                player.showControls()
                mouseAreaPlayerTimer.restart()
            }
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

        MainMenu {
            id: menuBar
        }

        Rectangle {
            id: titleBackground
            height: titleBar.height
            anchors.top: titleBar.top
            anchors.left: titleBar.left
            anchors.right: titleBar.right
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "black"
            opacity: 0.6
        }

        Rectangle {
            id: titleBar
            height: menuBar.height
            anchors.right: parent.right
            anchors.left: menuBar.right
            anchors.top: parent.top

            visible: !appearance.titleOnlyOnFullscreen
            color: "transparent"

            Text {
                id: titleLabel
                objectName: "titleLabel"
                text: translate.getTranslation("TITLE", i18n.language)
                color: "white"
                width: parent.width
                height: parent.height
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.bottom: parent.bottom
                topPadding: 4
                bottomPadding: 4
                anchors.top: parent.top
                font.family: appearance.fontName
                font.pixelSize: 14
                font.bold: true
                opacity: 1
            }
        }

        ControlsBar {
            id: controlsBar
        }
    }
}
