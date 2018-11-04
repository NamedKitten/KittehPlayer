import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import Qt.labs.settings 1.0
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

    function tracksMenuUpdate() {
        var tracks = player.getProperty("track-list/count")
        var track = 0
        subModel.clear()
        audioModel.clear()
        vidModel.clear()

        var aid = player.getProperty("aid")
        var sid = player.getProperty("sid")
        var vid = player.getProperty("vid")

        for (track = 0; track <= tracks; track++) {
            var trackID = player.getProperty("track-list/" + track + "/id")
            var trackType = player.getProperty("track-list/" + track + "/type")
            var trackLang = LanguageCodes.localeCodeToEnglish(
                        String(player.getProperty(
                                   "track-list/" + track + "/lang")))
            var trackTitle = player.getProperty(
                        "track-list/" + track + "/title")
            if (trackType == "sub") {
                subModel.append({
                                    key: trackLang,
                                    value: trackID
                                })
                if (player.getProperty("track-list/" + track + "/selected")) {
                    subList.currentIndex = subList.count - 1
                }
            } else if (trackType == "audio") {
                audioModel.append({
                                      key: (trackTitle === undefined ? "" : trackTitle + " ")
                                           + trackLang,
                                      value: trackID
                                  })
                if (player.getProperty("track-list/" + track + "/selected")) {
                    audioList.currentIndex = audioList.count - 1
                }
            } else if (trackType == "video") {
                vidModel.append({
                                    key: "Video " + trackID,
                                    value: trackID
                                })
                if (player.getProperty("track-list/" + track + "/selected")) {
                    vidList.currentIndex = vidList.count - 1
                }
            }
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

        Timer {
            id: initTimer
            interval: 1000
            running: false
            repeat: false
            onTriggered: {
                player.startPlayer()
            }
        }
        Component.onCompleted: {
            initTimer.start()
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

        function createTimestamp(d) {
            d = Number(d)
            var h = Math.floor(d / 3600)
            var m = Math.floor(d % 3600 / 60)
            var s = Math.floor(d % 3600 % 60)

            var hour = h > 0 ? h + ":" : ""
            var minute = m + ":"
            var second = s < 10 ? "0" + s : s
            return hour + minute + second
        }

        function setProgressBarEnd(val) {
            progressBar.to = val
        }

        function setProgressBarValue(val) {
            timeLabel.text = createTimestamp(val) + " / " + createTimestamp(
                        progressBar.to) + " (" + parseFloat(
                        player.getProperty("speed").toFixed(2)) + "x)"
            progressBar.value = val
        }

        function skipToNinth(val) {
            var skipto = 0
            if (val != 0) {
                skipto = Math.floor(progressBar.to / 9 * val)
            }
            player.command(["seek", skipto, "absolute"])
        }

        function updatePrev(val) {
            if (val != 0) {
                playlistPrevButton.visible = true
                playlistPrevButton.width = playPauseButton.width
            } else {
                playlistPrevButton.visible = false
                playlistPrevButton.width = 0
            }
        }

        function updateVolume(volume) {
            var muted = player.getProperty("mute")

            if (muted || volume === 0) {
                volumeButton.icon.source = "qrc:/player/icons/volume-mute.svg"
            } else {
                if (volume < 25) {
                    volumeButton.icon.source = "qrc:/player/icons/volume-down.svg"
                } else {
                    volumeButton.icon.source = "qrc:/player/icons/volume-up.svg"
                }
            }
        }

        function updateMuted(muted) {
            if (muted) {
                volumeButton.icon.source = "qrc:/player/icons/volume-mute.svg"
            }
        }
        function updatePlayPause() {
            var paused = player.getProperty("pause")
            if (paused) {
                playPauseButton.icon.source = "qrc:/player/icons/play.svg"
            } else {
                playPauseButton.icon.source = "qrc:/player/icons/pause.svg"
            }
        }

        function setTitle(title) {
            titleLabel.text = title
        }

        function setSubtitles(subs) {
            nativeSubs.text = subs
        }

        function isAnyMenuOpen() {
            return subtitlesMenu.visible || settingsMenu.visible
                    || fileMenuBarItem.opened || playbackMenuBarItem.opened
                    || viewMenuBarItem.opened || audioMenuBarItem.opened
                    || videoMenuBarItem.opened || subsMenuBarItem.opened
                    || aboutMenuBarItem.opened
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

        FileSaveDialog {
            id: screenshotSaveDialog
            title: translate.getTranslation("SAVE_SCREENSHOT", i18n.language)
            filename: "screenshot.png"
            nameFilters: ["Images (*.png)", "All files (*)"]
            onAccepted: {
                player.grabToImage(function (result) {
                    var filepath = String(screenshotSaveDialog.fileUrl).replace(
                                "file://", '')
                    result.saveToFile(filepath)
                    subtitlesBar.visible = appearance.useMpvSubs ? false : true
                })
            }
        }

        FileOpenDialog {
            id: fileDialog
            title: translate.getTranslation("OPEN_FILE", i18n.language)
            nameFilters: ["All files (*)"]
            onAccepted: {
                player.command(String(fileDialog.fileUrl))
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

            Menu {
                id: fileMenuBarItem
                title: translate.getTranslation("FILE_MENU", i18n.language)
                font.family: appearance.fontName
                width: 300
                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: 10
                    color: "black"
                    opacity: 0.6
                }
                delegate: CustomMenuItem {
                }

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

            Menu {
                id: playbackMenuBarItem
                title: translate.getTranslation("PLAYBACK", i18n.language)
                width: 300
                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: 10
                    color: "black"
                    opacity: 0.6
                }
                delegate: CustomMenuItem {
                    width: parent.width
                }

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

            Menu {
                id: audioMenuBarItem
                title: translate.getTranslation("AUDIO", i18n.language)
                width: 300
                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: 10
                    color: "black"
                    opacity: 0.6
                }
                delegate: CustomMenuItem {
                    width: parent.width
                }
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
            }

            Menu {
                id: videoMenuBarItem
                title: translate.getTranslation("VIDEO", i18n.language)
                width: 300
                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: 10
                    color: "black"
                    opacity: 0.6
                }
                delegate: CustomMenuItem {
                    width: parent.width
                }
                Action {
                    text: translate.getTranslation("CYCLE_VIDEO", i18n.language)
                    onTriggered: {
                        player.nextVideoTrack()
                    }
                    shortcut: keybinds.cycleVideo
                }
            }
            Menu {
                id: subsMenuBarItem
                title: translate.getTranslation("SUBTITLES", i18n.language)
                width: 300
                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: 10
                    color: "black"
                    opacity: 0.6
                }
                delegate: CustomMenuItem {
                    width: parent.width
                }
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
            }

            Menu {
                id: viewMenuBarItem
                title: translate.getTranslation("VIEW", i18n.language)
                width: 300
                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: 10
                    color: "black"
                    opacity: 0.6
                }
                delegate: CustomMenuItem {
                    width: parent.width
                }

                Action {
                    text: translate.getTranslation("FULLSCREEN", i18n.language)
                    onTriggered: {
                        toggleFullscreen()
                    }
                    shortcut: keybinds.fullscreen
                }
                Action {
                    text: translate.getTranslation("TRACK_MENU", i18n.language)
                    onTriggered: {
                        tracksMenuUpdate()
                        subtitlesMenu.visible = !subtitlesMenu.visible
                        subtitlesMenuBackground.visible = !subtitlesMenuBackground.visible
                    }
                    shortcut: keybinds.tracks
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
            }
            Menu {
                id: aboutMenuBarItem
                title: translate.getTranslation("ABOUT", i18n.language)
                width: 300
                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: 10
                    color: "black"
                    opacity: 0.6
                }
                delegate: CustomMenuItem {
                    width: parent.width
                }

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
        }

        Rectangle {
            id: subtitlesMenuBackground
            anchors.fill: subtitlesMenu
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: false
            color: "black"
            opacity: 0.6
        }

        Rectangle {
            id: subtitlesMenu
            color: "transparent"
            width: childrenRect.width
            height: childrenRect.height
            visible: false
            anchors.centerIn: player
            border.color: "black"
            border.width: 2

            Text {
                id: audioLabel
                anchors.left: parent.left
                anchors.right: parent.right
                text: translate.getTranslation("AUDIO", i18n.language)
                color: "white"
                font.family: appearance.fontName
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                opacity: 1
            }
            ComboBox {
                id: audioList
                textRole: "key"
                anchors.top: audioLabel.bottom
                model: ListModel {
                    id: audioModel
                }
                onActivated: {
                    player.command(["set", "aid", String(audioModel.get(
                                                             index).value)])
                }
                opacity: 1
            }
            Text {
                id: subLabel
                anchors.left: parent.left
                anchors.right: parent.right
                text: translate.getTranslation("SUBTITLES", i18n.language)
                color: "white"
                font.family: appearance.fontName
                font.pixelSize: 14
                anchors.top: audioList.bottom
                horizontalAlignment: Text.AlignHCenter
                opacity: 1
            }
            ComboBox {
                id: subList
                textRole: "key"
                anchors.top: subLabel.bottom
                model: ListModel {
                    id: subModel
                }
                onActivated: {
                    player.command(["set", "sid", String(subModel.get(
                                                             index).value)])
                }
                opacity: 1
            }
            Text {
                id: vidLabel
                anchors.left: parent.left
                anchors.right: parent.right
                text: translate.getTranslation("VIDEO", i18n.language)
                color: "white"
                font.family: appearance.fontName
                font.pixelSize: 14
                anchors.top: subList.bottom
                horizontalAlignment: Text.AlignHCenter
                opacity: 1
            }
            ComboBox {
                id: vidList
                textRole: "key"
                anchors.top: vidLabel.bottom
                model: ListModel {
                    id: vidModel
                }
                onActivated: {
                    player.command(["set", "vid", String(vidModel.get(
                                                             index).value)])
                }
                opacity: 1
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

                background: Rectangle {
                    id: progressBackground
                    x: progressBar.leftPadding
                    y: progressBar.topPadding + progressBar.availableHeight / 2 - height / 2
                    implicitHeight: Math.max(Screen.height / 256,
                                             fun.nyanCat ? 12 : 2)
                    width: progressBar.availableWidth
                    height: implicitHeight
                    color: Qt.rgba(255, 255, 255, 0.6)

                    Rectangle {
                        id: progressLength
                        width: progressBar.visualPosition * parent.width
                        height: parent.height
                        color: "red"
                        opacity: 1
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
                    implicitHeight: 12
                    implicitWidth: 12
                    radius: 12
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
                //icon.name: "prev"
                icon.source: "icons/prev.svg"
                icon.color: "white"
                display: AbstractButton.IconOnly
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                visible: false
                width: 0
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
                icon.source: "icons/pause.svg"
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
                    player.prevPlaylistItem()
                }
                background: Rectangle {
                    color: "transparent"
                }
            }

            Button {
                id: volumeButton
                //icon.name: "volume-up"
                icon.source: "icons/volume-up.svg"
                icon.color: "white"
                display: AbstractButton.IconOnly
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: playlistNextButton.right
                onClicked: {
                    player.toggleMute()
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
                    player.setVolume(Math.round(
                                        volumeBar.value).toString())
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
                id: subtitlesButton
                //icon.name: "subtitles"
                icon.source: "icons/subtitles.svg"
                icon.color: "white"
                anchors.right: settingsButton.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                display: AbstractButton.IconOnly
                onClicked: {
                    tracksMenuUpdate()
                    subtitlesMenu.visible = !subtitlesMenu.visible
                    subtitlesMenuBackground.visible = !subtitlesMenuBackground.visible
                }
                background: Rectangle {
                    color: "transparent"
                }
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
