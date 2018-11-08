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

            player.setOption("ytdl-format", "bestvideo[width<=" + Screen.width
                             + "][height<=" + Screen.height + "]+bestaudio")
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
                            if (splitArg[0] == "fullscreen") {
                                toggleFullscreen()
                            } else {
                                if (splitArg[1].length == 0) {
                                    splitArg[1] = "true"
                                }
                                player.setOption(splitArg[0], splitArg[1])
                            }
                        }
                    } else {
                        player.loadFile(argument)
                    }
                }
            }
        }

        function tracksUpdate() {
            for (var i = 0, len = audioMenu.count; i < len; i++) {
                var audioAction = audioMenu.actionAt(i)
                if (audioAction.trackID != "no") {
                    audioMenu.removeAction(audioAction)
                }
            }
            for (var i = 0, len = videoMenu.count; i < len; i++) {
                var videoAction = audioMenu.actionAt(i)
                if (videoAction.trackID != "no") {
                    videoMenu.removeAction(videoAction)
                }
            }
            for (var i = 0, len = subMenu.count; i < len; i++) {
                var subAction = subMenu.actionAt(i)
                if (subAction.trackID != "no") {
                    subMenu.removeAction(subAction)
                }
            }
            var newTracks = player.getTracks()

            for (var i = 0, len = newTracks.length; i < len; i++) {
                var track = newTracks[i]
                var trackID = track["id"]
                var trackType = track["type"]
                var trackLang = LanguageCodes.localeCodeToEnglish(
                            String(track["lang"]))
                var trackTitle = track["title"]
                if (trackType == "sub") {
                    var component = Qt.createComponent("TrackItem.qml")
                    var action = component.createObject(subMenu, {
                                                            text: trackLang,
                                                            trackID: String(
                                                                         trackID),
                                                            trackType: "sid",
                                                            checked: track["selected"]
                                                        })
                    action.ActionGroup.group = subMenuGroup
                    subMenu.addAction(action)
                } else if (trackType == "audio") {
                    var component = Qt.createComponent("TrackItem.qml")
                    var action = component.createObject(audioMenu, {
                                                            text: (trackTitle == "undefined" ? "" : trackTitle + " ") + (trackLang == "undefined" ? "" : trackLang),
                                                            trackID: String(
                                                                         trackID),
                                                            trackType: "aid",
                                                            checked: track["selected"]
                                                        })
                    action.ActionGroup.group = audioMenuGroup
                    audioMenu.addAction(action)
                } else if (trackType == "video") {
                    var component = Qt.createComponent("TrackItem.qml")
                    var action = component.createObject(videoMenu, {
                                                            text: "Video " + trackID,
                                                            trackID: String(
                                                                         trackID),
                                                            trackType: "vid",
                                                            checked: track["selected"]
                                                        })
                    action.ActionGroup.group = videoMenuGroup
                    videoMenu.addAction(action)
                }
            }
        }

        function skipToNinth(val) {
            var skipto = 0
            if (val != 0) {
                skipto = Math.floor(progressBar.to / 9 * val)
            }
            player.command(["seek", skipto, "absolute"])
        }

        function isAnyMenuOpen() {
            return settingsMenu.visible || fileMenuBarItem.opened
                    || playbackMenuBarItem.opened || viewMenuBarItem.opened
                    || audioMenuBarItem.opened || videoMenuBarItem.opened
                    || subsMenuBarItem.opened || aboutMenuBarItem.opened
        }

        function hideControls(force) {
            if (!isAnyMenuOpen() || force) {
                controlsBar.visible = false
                controlsBackground.visible = false
                titleBar.visible = false
                titleBackground.visible = false
                menuBar.visible = false
            }
        }

        function showControls() {
            if (!controlsBar.visible) {
                controlsBar.visible = true
                controlsBackground.visible = true
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

        LabsPlatform.FileDialog {
            id: screenshotSaveDialog
            title: translate.getTranslation("SAVE_SCREENSHOT", i18n.language)
            fileMode: LabsPlatform.FileDialog.SaveFile
            defaultSuffix: "png"
            nameFilters: ["Images (*.png)", "All files (*)"]
            onAccepted: {
                player.grabToImage(function (result) {
                    var filepath = String(screenshotSaveDialog.file).replace(
                                "file://", '')
                    result.saveToFile(filepath)
                    subtitlesBar.visible = appearance.useMpvSubs ? false : true
                })
            }
        }

        LabsPlatform.FileDialog {
            id: fileDialog
            title: translate.getTranslation("OPEN_FILE", i18n.language)
            nameFilters: ["All files (*)"]
            onAccepted: {
                player.loadFile(String(fileDialog.file))
                fileDialog.close()
            }
            onRejected: {
                fileDialog.close()
            }
        }

        Dialog {
            id: loadDialog
            title: translate.getTranslation("URL_FILE_PATH", i18n.language)
            standardButtons: StandardButton.Cancel | StandardButton.Open
            onAccepted: {
                player.loadFile(pathText.text)
                pathText.text = ""
            }
            TextField {
                id: pathText
                placeholderText: translate.getTranslation("URL_FILE_PATH",
                                                          i18n.language)
            }
        }

        MouseArea {
            id: mouseAreaBar
            x: 0
            y: parent.height
            width: parent.width
            height: (controlsBar.height * 2) + progressBar.height
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
            property string decreaseSpeedBy10Percent: "["
            property string increaseSpeedBy10Percent: "]"
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
        MenuBar {
            id: menuBar
            //width: parent.width
            height: Math.max(24, Screen.height / 32)
            delegate: MenuBarItem {
                id: menuBarItem

                padding: 4
                topPadding: padding
                leftPadding: padding
                rightPadding: padding
                bottomPadding: padding

                contentItem: Text {
                    id: menuBarItemText
                    text: menuBarItem.text
                    font.family: appearance.fontName
                    font.pixelSize: 14
                    font.bold: menuBarItem.highlighted
                    opacity: 1
                    color: menuBarItem.highlighted ? "#5a50da" : "white"
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    renderType: Text.NativeRendering
                }

                background: Rectangle {
                    implicitWidth: 10
                    implicitHeight: 10
                    opacity: 1
                    color: menuBarItem.highlighted ? "#c0c0f0" : "transparent"
                }
            }

            background: Rectangle {
                width: parent.width
                implicitHeight: 10
                color: "black"
                opacity: 0.6
            }

            CustomMenu {
                id: fileMenuBarItem
                title: translate.getTranslation("FILE_MENU", i18n.language)
                font.family: appearance.fontName

                Action {
                    text: translate.getTranslation("OPEN_FILE", i18n.language)
                    onTriggered: fileDialog.open()
                    shortcut: keybinds.openFile
                }
                Action {
                    text: translate.getTranslation("OPEN_URL", i18n.language)
                    onTriggered: loadDialog.open()
                    shortcut: keybinds.openURI
                }
                Action {
                    text: translate.getTranslation("SCREENSHOT", i18n.language)
                    onTriggered: {
                        player.hideControls(true)
                        screenshotSaveDialog.open()
                    }
                    shortcut: keybinds.screenshot
                }
                Action {
                    text: translate.getTranslation(
                              "SCREENSHOT_WITHOUT_SUBTITLES", i18n.language)
                    onTriggered: {
                        player.hideControls(true)
                        subtitlesBar.visible = false
                        screenshotSaveDialog.open()
                    }
                    shortcut: keybinds.screenshotWithoutSubtitles
                }
                Action {
                    text: translate.getTranslation("FULL_SCREENSHOT",
                                                   i18n.language)
                    onTriggered: {
                        screenshotSaveDialog.open()
                    }
                    shortcut: keybinds.fullScreenshot
                }
                Action {
                    text: translate.getTranslation("EXIT", i18n.language)
                    onTriggered: Qt.quit()
                    shortcut: keybinds.quit
                }
            }

            CustomMenu {
                id: playbackMenuBarItem
                title: translate.getTranslation("PLAYBACK", i18n.language)
                Action {
                    text: translate.getTranslation("PLAY_PAUSE", i18n.language)
                    onTriggered: {
                        player.togglePlayPause()
                    }
                    shortcut: String(keybinds.playPause)
                }
                Action {
                    text: translate.getTranslation("REWIND_10S", i18n.language)
                    onTriggered: {
                        player.seek("-10")
                    }
                    shortcut: keybinds.rewind10
                }
                Action {
                    text: translate.getTranslation("FORWARD_10S", i18n.language)
                    onTriggered: {
                        player.seek("10")
                    }
                    shortcut: keybinds.forward10
                }
                Action {
                    text: translate.getTranslation("FORWARD_5S", i18n.language)
                    onTriggered: {
                        player.seek("-5")
                    }
                    shortcut: keybinds.rewind5
                }
                Action {
                    text: translate.getTranslation("FORWARD_5S", i18n.language)
                    onTriggered: {
                        player.seek("5")
                    }
                    shortcut: keybinds.forward5
                }
                Action {
                    text: translate.getTranslation("SPEED_DECREASE_10PERCENT",
                                                   i18n.language)
                    onTriggered: {
                        player.command(["multiply", "speed", "1/1.1"])
                    }
                    shortcut: keybinds.decreaseSpeedBy10Percent
                }
                Action {
                    text: translate.getTranslation("SPEED_INCREASE_10PERCENT",
                                                   i18n.language)
                    onTriggered: {
                        player.command(["multiply", "speed", "1.1"])
                    }
                    shortcut: keybinds.increaseSpeedBy10Percent
                }
                Action {
                    text: translate.getTranslation("HALVE_SPEED", i18n.language)
                    onTriggered: {
                        player.command(["multiply", "speed", "0.5"])
                    }
                    shortcut: keybinds.halveSpeed
                }
                Action {
                    text: translate.getTranslation("DOUBLE_SPEED",
                                                   i18n.language)
                    onTriggered: {
                        player.command(["multiply", "speed", "2.0"])
                    }
                    shortcut: keybinds.doubleSpeed
                }
                Action {
                    text: translate.getTranslation("FORWARD_FRAME",
                                                   i18n.language)
                    onTriggered: {
                        player.command(["frame-step"])
                    }
                    shortcut: keybinds.forwardFrame
                }
                Action {
                    text: translate.getTranslation("BACKWARD_FRAME",
                                                   i18n.language)
                    onTriggered: {
                        player.command(["frame-back-step"])
                    }
                    shortcut: keybinds.backwardFrame
                }
            }

            CustomMenu {
                id: audioMenuBarItem
                title: translate.getTranslation("AUDIO", i18n.language)
                Action {
                    text: translate.getTranslation("CYCLE_AUDIO_TRACK",
                                                   i18n.language)
                    onTriggered: {
                        player.nextAudioTrack()
                    }
                    shortcut: keybinds.cycleAudio
                }
                Action {
                    text: translate.getTranslation("INCREASE_VOLUME",
                                                   i18n.language)
                    onTriggered: {
                        player.addVolume("2")
                    }
                    shortcut: keybinds.increaseVolume
                }
                Action {
                    text: translate.getTranslation("DECREASE_VOLUME",
                                                   i18n.language)
                    onTriggered: {
                        player.addVolume("-2")
                    }
                    shortcut: keybinds.decreaseVolume
                }
                Action {
                    text: translate.getTranslation("MUTE_VOLUME", i18n.language)
                    onTriggered: {
                        player.toggleMute()
                    }
                    shortcut: keybinds.mute
                }
                MenuSeparator {
                }

                CustomMenu {
                    title: translate.getTranslation("AUDIO", i18n.language)
                    id: audioMenu
                    ActionGroup {
                        id: audioMenuGroup
                    }
                    TrackItem {
                        text: translate.getTranslation("DISABLE_TRACK",
                                                       i18n.language)
                        trackType: "aid"
                        trackID: "no"
                        ActionGroup.group: audioMenuGroup
                    }
                }
            }

            CustomMenu {
                id: videoMenuBarItem
                title: translate.getTranslation("VIDEO", i18n.language)
                Action {
                    text: translate.getTranslation("CYCLE_VIDEO", i18n.language)
                    onTriggered: {
                        player.nextVideoTrack()
                    }
                    shortcut: keybinds.cycleVideo
                }
                MenuSeparator {
                }

                CustomMenu {
                    title: translate.getTranslation("VIDEO", i18n.language)
                    id: videoMenu
                    ActionGroup {
                        id: videoMenuGroup
                    }
                    TrackItem {
                        text: translate.getTranslation("DISABLE_TRACK",
                                                       i18n.language)
                        trackType: "vid"
                        trackID: "no"
                        ActionGroup.group: videoMenuGroup
                    }
                }
            }
            CustomMenu {
                id: subsMenuBarItem
                title: translate.getTranslation("SUBTITLES", i18n.language)
                Action {
                    text: translate.getTranslation("CYCLE_SUB_TRACK",
                                                   i18n.language)
                    onTriggered: {
                        player.nextSubtitleTrack()
                    }
                    shortcut: keybinds.cycleSub
                }
                Action {
                    text: translate.getTranslation("TOGGLE_MPV_SUBS",
                                                   i18n.language)
                    onTriggered: {
                        appearance.useMpvSubs = !appearance.useMpvSubs
                    }
                    shortcut: keybinds.cycleSubBackwards
                }
                MenuSeparator {
                }

                CustomMenu {
                    title: translate.getTranslation("SUBTITLES", i18n.language)
                    id: subMenu
                    ActionGroup {
                        id: subMenuGroup
                    }
                    TrackItem {
                        text: translate.getTranslation("DISABLE_TRACK",
                                                       i18n.language)
                        trackType: "sid"
                        trackID: "no"
                        ActionGroup.group: subMenuGroup
                    }
                }
            }

            CustomMenu {
                id: viewMenuBarItem
                title: translate.getTranslation("VIEW", i18n.language)

                Action {
                    text: translate.getTranslation("FULLSCREEN", i18n.language)
                    onTriggered: {
                        toggleFullscreen()
                    }
                    shortcut: keybinds.fullscreen
                }
                Action {
                    text: translate.getTranslation("STATS", i18n.language)
                    onTriggered: {
                        player.command(
                                    ["script-binding", "stats/display-stats-toggle"])
                    }
                    shortcut: keybinds.statsForNerds
                }

                Action {
                    text: translate.getTranslation("TOGGLE_NYAN_CAT",
                                                   i18n.language)
                    onTriggered: {
                        fun.nyanCat = !fun.nyanCat
                    }
                    shortcut: keybinds.nyanCat
                }
                Action {
                    text: translate.getTranslation("TOGGLE_ALWAYS_ON_TOP",
                                                   i18n.language)
                    onTriggered: {
                        player.toggleOnTop()
                    }
                }
            }
            CustomMenu {
                id: aboutMenuBarItem
                title: translate.getTranslation("ABOUT", i18n.language)

                Action {
                    text: translate.getTranslation("ABOUT_QT", i18n.language)
                    onTriggered: {
                        player.launchAboutQt()
                    }
                }
            }

            Action {
                onTriggered: player.skipToNinth(parseInt(shortcut))
                shortcut: "1"
            }
            Action {
                onTriggered: player.skipToNinth(parseInt(shortcut))
                shortcut: "2"
            }
            Action {
                onTriggered: player.skipToNinth(parseInt(shortcut))
                shortcut: "3"
            }
            Action {
                onTriggered: player.skipToNinth(parseInt(shortcut))
                shortcut: "4"
            }
            Action {
                onTriggered: player.skipToNinth(parseInt(shortcut))
                shortcut: "5"
            }
            Action {
                onTriggered: player.skipToNinth(parseInt(shortcut))
                shortcut: "6"
            }
            Action {
                onTriggered: player.skipToNinth(parseInt(shortcut))
                shortcut: "7"
            }
            Action {
                onTriggered: player.skipToNinth(parseInt(shortcut))
                shortcut: "8"
            }
            Action {
                onTriggered: player.skipToNinth(parseInt(shortcut))
                shortcut: "9"
            }
            Action {
                onTriggered: player.skipToNinth(parseInt(shortcut))
                shortcut: "0"
            }

            Action {
                onTriggered: player.command(keybinds.customKeybind0Command)
                shortcut: keybinds.customKeybind0
            }
            Action {
                onTriggered: player.command(keybinds.customKeybind1Command)
                shortcut: keybinds.customKeybind1
            }
            Action {
                onTriggered: player.command(keybinds.customKeybind2Command)
                shortcut: keybinds.customKeybind2
            }
            Action {
                onTriggered: player.command(keybinds.customKeybind3Command)
                shortcut: keybinds.customKeybind3
            }
            Action {
                onTriggered: player.command(keybinds.customKeybind4Command)
                shortcut: keybinds.customKeybind4
            }
            Action {
                onTriggered: player.command(keybinds.customKeybind5Command)
                shortcut: keybinds.customKeybind5
            }
            Action {
                onTriggered: player.command(keybinds.customKeybind6Command)
                shortcut: keybinds.customKeybind6
            }
            Action {
                onTriggered: player.command(keybinds.customKeybind7Command)
                shortcut: keybinds.customKeybind7
            }
            Action {
                onTriggered: player.command(keybinds.customKeybind8Command)
                shortcut: keybinds.customKeybind8
            }
            Action {
                onTriggered: player.command(keybinds.customKeybind9Command)
                shortcut: keybinds.customKeybind9
            }
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

        Rectangle {
            id: controlsBackground
            height: controlsBar.visible ? controlsBar.height + progressBackground.height
                                          + (progressBar.topPadding * 2)
                                          - (progressBackground.height * 2) : 0
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "black"
            opacity: 0.6
        }

        Rectangle {
            id: subtitlesBar
            visible: !appearance.useMpvSubs
            color: "transparent"
            height: player.height / 8
            anchors.bottom: controlsBackground.top
            anchors.bottomMargin: 5
            anchors.right: parent.right
            anchors.left: parent.left

            RowLayout {
                id: nativeSubtitles
                visible: true
                anchors.left: subtitlesBar.left
                anchors.right: subtitlesBar.right
                height: childrenRect.height
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10

                Rectangle {
                    id: subsContainer
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.rightMargin: 0
                    Layout.leftMargin: 0
                    Layout.maximumWidth: nativeSubtitles.width
                    color: "transparent"
                    height: childrenRect.height

                    Label {
                        id: nativeSubs
                        objectName: "nativeSubs"
                        onWidthChanged: {

                            if (width > parent.width - 10)
                                width = parent.width - 10
                        }
                        onTextChanged: if (width <= parent.width - 10)
                                           width = undefined
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: Screen.height / 24
                        font.family: appearance.fontName
                        horizontalAlignment: Text.AlignHCenter
                        opacity: 1
                        background: Rectangle {
                            id: subsBackground
                            color: Qt.rgba(0, 0, 0, 0.6)
                            width: subsContainer.childrenRect.width
                            height: subsContainer.childrenRect.height
                        }
                    }
                }
            }
        }

        function setCachedDuration(val) {
            cachedLength.width = ((progressBar.width / progressBar.to) * val) - progressLength.width
        }

        Rectangle {
            id: controlsBar
            height: controlsBar.visible ? Screen.height / 24 : 0
            anchors.right: parent.right
            anchors.rightMargin: parent.width / 128
            anchors.left: parent.left
            anchors.leftMargin: parent.width / 128
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 1
            visible: true
            color: "transparent"
            Rectangle {
                id: settingsMenuBackground
                anchors.fill: settingsMenu
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: false
                color: "black"
                opacity: 0.6
                radius: 5
            }

            Rectangle {
                id: settingsMenu
                color: "transparent"
                width: childrenRect.width
                height: childrenRect.height
                visible: false
                anchors.right: settingsButton.right
                anchors.bottom: progressBar.top
                radius: 5
            }

            Slider {
                id: progressBar
                objectName: "progressBar"
                to: 1
                value: 0.0
                anchors.bottom: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottomMargin: 0
                anchors.topMargin: progressBackground.height
                bottomPadding: 0

                onMoved: {
                    player.command(["seek", progressBar.value, "absolute"])
                }

                function getProgressBarHeight(nyan, isMouse) {
                    var x = Math.max(Screen.height / 256, fun.nyanCat ? 12 : 2)
                    return isMouse & !fun.nyanCat ? x * 2 : x
                }

                MouseArea {
                    id: mouseAreaProgressBar
                    y: parent.height
                    width: parent.width
                    height: parent.height
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true
                    acceptedButtons: Qt.NoButton
                }

                background: Rectangle {
                    id: progressBackground
                    x: progressBar.leftPadding
                    y: progressBar.topPadding + progressBar.availableHeight / 2 - height / 2
                    implicitHeight: progressBar.getProgressBarHeight(
                                        fun.nyanCat,
                                        mouseAreaProgressBar.containsMouse)
                    width: progressBar.availableWidth
                    height: implicitHeight
                    color: Qt.rgba(255, 255, 255, 0.6)
                    radius: height
                    Rectangle {
                        id: progressLength
                        width: progressBar.visualPosition * parent.width
                        height: parent.height
                        color: "red"
                        opacity: 1
                        radius: height
                        anchors.leftMargin: 100

                        Image {
                            visible: fun.nyanCat
                            id: rainbow
                            anchors.fill: parent
                            height: parent.height
                            width: parent.width
                            source: "qrc:/player/icons/rainbow.png"
                            fillMode: Image.TileHorizontally
                        }
                    }
                    Rectangle {
                        id: cachedLength
                        z: 10
                        radius: height
                        anchors.left: progressLength.right
                        anchors.leftMargin: progressBar.handle.width - 2
                        //anchors.left: progressBar.handle.horizontalCenter
                        anchors.bottom: progressBar.background.bottom
                        anchors.top: progressBar.background.top
                        height: progressBar.background.height
                        color: "white"
                        opacity: 0.8
                    }
                }

                handle: Rectangle {

                    id: handleRect
                    x: progressBar.leftPadding + progressBar.visualPosition
                       * (progressBar.availableWidth - width)
                    y: progressBar.topPadding + progressBar.availableHeight / 2 - height / 2
                    implicitHeight: radius
                    implicitWidth: radius
                    radius: 12 + (progressBackground.height / 2)
                    color: fun.nyanCat ? "transparent" : "red"
                    //border.color: "red"
                    AnimatedImage {
                        visible: fun.nyanCat
                        paused: progressBar.pressed
                        height: 30
                        id: nyanimation
                        anchors.centerIn: parent
                        source: "qrc:/player/icons/nyancat.gif"
                        fillMode: Image.PreserveAspectFit
                    }
                }
            }

            Button {
                id: playlistPrevButton
                objectName: "playlistPrevButton"
                //icon.name: "prev"
                icon.source: "icons/prev.svg"
                icon.color: "white"
                display: AbstractButton.IconOnly
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                visible: false
                width: visible ? playPauseButton.width : 0
                onClicked: {
                    player.prevPlaylistItem()
                }
                background: Rectangle {
                    color: "transparent"
                }
            }

            Button {
                id: playPauseButton
                //icon.name: "pause"
                objectName: "playPauseButton"
                property string iconSource: "icons/pause.svg"
                icon.source: iconSource
                icon.color: "white"
                display: AbstractButton.IconOnly
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: playlistPrevButton.right
                onClicked: {
                    player.togglePlayPause()
                }
                background: Rectangle {
                    color: "transparent"
                }
            }

            Button {
                id: playlistNextButton
                //icon.name: "next"
                icon.source: "icons/next.svg"
                icon.color: "white"
                display: AbstractButton.IconOnly
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: playPauseButton.right
                onClicked: {
                    player.nextPlaylistItem()
                }
                background: Rectangle {
                    color: "transparent"
                }
            }

            Button {
                id: volumeButton
                objectName: "volumeButton"
                property string iconSource: "icons/volume-up.svg"
                icon.source: iconSource
                icon.color: "white"
                display: AbstractButton.IconOnly
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: playlistNextButton.right
                onClicked: {
                    player.toggleMute()
                    player.updateVolume(player.getProperty("volume"))
                }
                background: Rectangle {
                    color: "transparent"
                }
            }
            Slider {
                id: volumeBar
                to: 100
                value: 100
                palette.dark: "#f00"

                implicitWidth: Math.max(
                                   background ? background.implicitWidth : 0,
                                                (handle ? handle.implicitWidth : 0)
                                                + leftPadding + rightPadding)
                implicitHeight: Math.max(
                                    background ? background.implicitHeight : 0,
                                                 (handle ? handle.implicitHeight : 0)
                                                 + topPadding + bottomPadding)

                anchors.left: volumeButton.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                onMoved: {
                    player.setVolume(Math.round(volumeBar.value).toString())
                }

                handle: Rectangle {
                    x: volumeBar.leftPadding + volumeBar.visualPosition
                       * (volumeBar.availableWidth - width)
                    y: volumeBar.topPadding + volumeBar.availableHeight / 2 - height / 2
                    implicitWidth: 12
                    implicitHeight: 12
                    radius: 12
                    color: "#f6f6f6"
                    border.color: "#f6f6f6"
                }

                background: Rectangle {
                    x: volumeBar.leftPadding
                    y: volumeBar.topPadding + volumeBar.availableHeight / 2 - height / 2
                    implicitWidth: 60
                    implicitHeight: 3
                    width: volumeBar.availableWidth
                    height: implicitHeight
                    color: "#33333311"
                    Rectangle {
                        width: volumeBar.visualPosition * parent.width
                        height: parent.height
                        color: "white"
                    }
                }
            }

            Text {
                id: timeLabel
                objectName: "timeLabel"
                text: "0:00 / 0:00"
                color: "white"
                anchors.left: volumeBar.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                padding: 2
                font.family: appearance.fontName
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                renderType: Text.NativeRendering
            }

            Button {
                id: settingsButton
                //icon.name: "settings"
                icon.source: "icons/settings.svg"
                icon.color: "white"
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                anchors.right: fullscreenButton.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                display: AbstractButton.IconOnly
                onClicked: {
                    settingsMenu.visible = !settingsMenu.visible
                    settingsMenuBackground.visible = !settingsMenuBackground.visible
                }
                background: Rectangle {
                    color: "transparent"
                }
            }

            Button {
                id: fullscreenButton
                //icon.name: "fullscreen"
                icon.source: "icons/fullscreen.svg"
                icon.color: "white"
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                display: AbstractButton.IconOnly
                onClicked: {
                    toggleFullscreen()
                }

                background: Rectangle {
                    color: "transparent"
                }
            }
        }
    }
}
