import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.3
import QtQuick.Window 2.11
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

import "codes.js" as LanguageCodes

MenuBar {
    id: menuBar
    //width: parent.width
    height: mainWindow.virtualHeight / 32
    function anythingOpen() {
        for (var i = 0, len = menuBar.count; i < len; i++) {
            if (menuBar.menuAt(i).opened) {
                return true
            }
        }
    }

    Connections {
        target: player
        enabled: true
        onTracksChanged: function (tracks) {
            menuBar.updateTracks(tracks)
        }
    }

    function updateTracks(tracks) {
        var newTracks = tracks
        var trackMenus = [audioMenu, videoMenu, subMenu]
        for (var a = 0; a < trackMenus.length; a++) {
            var menu = trackMenus[a]
            for (var i = 0, len = menu.count; i < len; i++) {
                var action = menu.actionAt(i)
                if (action.trackID != "no") {
                    menu.removeAction(action)
                }
            }
        }

        for (var i = 0, len = newTracks.length; i < len; i++) {
            var track = newTracks[i]
            var trackID = track["id"]
            var trackType = track["type"]
            var trackLang = LanguageCodes.localeCodeToEnglish(
                        String(track["lang"]))
            var trackTitle = track["title"]
            var component = Qt.createComponent("TrackItem.qml")
            if (trackType == "sub") {
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
                var action = component.createObject(audioMenu, {
                                                        text: (trackTitle == undefined ? "" : trackTitle + " ") + (trackLang == "undefined" ? "" : trackLang),
                                                        trackID: String(
                                                                     trackID),
                                                        trackType: "aid",
                                                        checked: track["selected"]
                                                    })
                action.ActionGroup.group = audioMenuGroup
                audioMenu.addAction(action)
            } else if (trackType == "video") {
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
            player.playerCommand(Enums.Commands.LoadFile,
                                 String(fileDialog.file))
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
            player.playerCommand(Enums.Commands.LoadFile, pathText.text)
            pathText.text = ""
        }
        TextField {
            id: pathText
            placeholderText: translate.getTranslation("URL_FILE_PATH",
                                                      i18n.language)
        }
    }

    PlaylistDialog {
        id: playlistDialog
    }

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
            font.pixelSize: menuBar.height / 2
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
        color: getAppearanceValueForTheme(appearance.themeName,
                                          "mainBackground")
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
            text: translate.getTranslation("SCREENSHOT_WITHOUT_SUBTITLES",
                                           i18n.language)
            onTriggered: {
                player.hideControls(true)
                subtitlesBar.visible = false
                screenshotSaveDialog.open()
            }
            shortcut: keybinds.screenshotWithoutSubtitles
        }
        Action {
            text: translate.getTranslation("FULL_SCREENSHOT", i18n.language)
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
        Action {
            text: translate.getTranslation("UPDATE", i18n.language)
            onTriggered: player.updateAppImage()
        }
    }

    CustomMenu {
        id: playbackMenuBarItem
        title: translate.getTranslation("PLAYBACK", i18n.language)
        Action {
            text: translate.getTranslation("PLAY_PAUSE", i18n.language)
            onTriggered: {
                player.playerCommand(Enums.Commands.TogglePlayPause)
            }
            shortcut: String(keybinds.playPause)
        }
        Action {
            text: translate.getTranslation("REWIND_10S", i18n.language)
            onTriggered: {
                player.playerCommand(Enums.Commands.Seek, "-10")
            }
            shortcut: keybinds.rewind10
        }
        Action {
            text: translate.getTranslation("FORWARD_10S", i18n.language)
            onTriggered: {
                player.playerCommand(Enums.Commands.Seek, "10")
            }
            shortcut: keybinds.forward10
        }
        Action {
            text: translate.getTranslation("FORWARD_5S", i18n.language)
            onTriggered: {
                player.playerCommand(Enums.Commands.Seek, "-5")
            }
            shortcut: keybinds.rewind5
        }
        Action {
            text: translate.getTranslation("FORWARD_5S", i18n.language)
            onTriggered: {
                player.playerCommand(Enums.Commands.Seek, "5")
            }
            shortcut: keybinds.forward5
        }
        Action {
            text: translate.getTranslation("SPEED_DECREASE_POINT_ONE",
                                           i18n.language)
            onTriggered: {
                player.playerCommand(Enums.Commands.SubtractSpeed, 0.1)
            }
            shortcut: keybinds.decreaseSpeedByPointOne
        }
        Action {
            text: translate.getTranslation("SPEED_INCREASE_POINT_ONE",
                                           i18n.language)
            onTriggered: {
                player.playerCommand(Enums.Commands.AddSpeed, 0.1)
            }
            shortcut: keybinds.increaseSpeedByPointOne
        }
        Action {
            text: translate.getTranslation("HALVE_SPEED", i18n.language)
            onTriggered: {
                player.playerCommand(Enums.Commands.ChangeSpeed, 0.5)
            }
            shortcut: keybinds.halveSpeed
        }
        Action {
            text: translate.getTranslation("DOUBLE_SPEED", i18n.language)
            onTriggered: {
                player.playerCommand(Enums.Commands.ChangeSpeed, 2)
            }
            shortcut: keybinds.doubleSpeed
        }
        Action {
            text: translate.getTranslation("FORWARD_FRAME", i18n.language)
            onTriggered: {
                player.playerCommand(Enums.Commands.ForwardFrame)
            }
            shortcut: keybinds.forwardFrame
        }
        Action {
            text: translate.getTranslation("BACKWARD_FRAME", i18n.language)
            onTriggered: {
                player.playerCommand(Enums.Commands.BackwardFrame)
            }
            shortcut: keybinds.backwardFrame
        }
    }

    CustomMenu {
        id: audioMenuBarItem
        title: translate.getTranslation("AUDIO", i18n.language)
        Action {
            text: translate.getTranslation("CYCLE_AUDIO_TRACK", i18n.language)
            onTriggered: {
                player.playerCommand(Enums.Commands.NextAudioTrack)
            }
            shortcut: keybinds.cycleAudio
        }
        Action {
            text: translate.getTranslation("INCREASE_VOLUME", i18n.language)
            onTriggered: {
                player.playerCommand(Enums.Commands.AddVolume, "2")
            }
            shortcut: keybinds.increaseVolume
        }
        Action {
            text: translate.getTranslation("DECREASE_VOLUME", i18n.language)
            onTriggered: {
                player.playerCommand(Enums.Commands.AddVolume, "-2")
            }
            shortcut: keybinds.decreaseVolume
        }
        Action {
            text: translate.getTranslation("MUTE_VOLUME", i18n.language)
            onTriggered: {
                player.playerCommand(Enums.Commands.ToggleMute)
            }
            shortcut: keybinds.mute
        }

        MenuSeparator {
        }

        CustomMenu {
            title: translate.getTranslation("AUDIO_DEVICES", i18n.language)
            id: audioDeviceMenu
            objectName: "audioDeviceMenu"

            Connections {
                target: player
                enabled: true
                onAudioDevicesChanged: function (ad) {
                    audioDeviceMenu.updateAudioDevices(ad)
                }
            }
            function updateAudioDevices(audioDevices) {
                for (var i = 0, len = audioDeviceMenu.count; i < len; i++) {
                    audioDeviceMenu.takeAction(0)
                }
                for (var thing in audioDevices) {
                    var audioDevice = audioDevices[thing]
                    var name = audioDevice["name"]
                    var description = audioDevice["description"]
                    var selected = audioDevice["selected"]
                    var component = Qt.createComponent("AudioDeviceItem.qml")
                    var action = component.createObject(audioDeviceMenu, {
                                                            text: description,
                                                            deviceID: String(
                                                                          name),
                                                            checked: audioDevice["selected"]
                                                        })
                    action.ActionGroup.group = audioDeviceMenuGroup
                    audioDeviceMenu.addAction(action)
                }
            }

            ActionGroup {
                id: audioDeviceMenuGroup
            }
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
                text: translate.getTranslation("DISABLE_TRACK", i18n.language)
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
                player.playerCommand(Enums.Commands.NextVideoTrack)
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
                text: translate.getTranslation("DISABLE_TRACK", i18n.language)
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
            text: translate.getTranslation("CYCLE_SUB_TRACK", i18n.language)
            onTriggered: {
                player.playerCommand(Enums.Commands.NextSubtitleTrack)
            }
            shortcut: keybinds.cycleSub
        }
        Action {
            text: translate.getTranslation("TOGGLE_MPV_SUBS", i18n.language)
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
                text: translate.getTranslation("DISABLE_TRACK", i18n.language)
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
                player.playerCommand(Enums.Commands.ToggleStats)
            }
            shortcut: keybinds.statsForNerds
        }

        Action {
            text: translate.getTranslation("TOGGLE_NYAN_CAT", i18n.language)
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
        Action {
            text: translate.getTranslation("PLAYLIST_MENU", i18n.language)
            onTriggered: {
                playlistDialog.open()
            }
        }
        Action {
            text: translate.getTranslation("ABOUT_QT", i18n.language)
            onTriggered: {
                player.launchAboutQt()
            }
        }
    }

    function skipToNinth(val) {
        var skipto = 0
        if (val != 0) {
            skipto = Math.floor(controlsBar.duration / 9 * val)
        }
        player.playerCommand(Enums.Commands.SeekAbsolute, skipto)
    }

    Action {
        onTriggered: skipToNinth(parseInt(shortcut))
        shortcut: "1"
    }
    Action {
        onTriggered: skipToNinth(parseInt(shortcut))
        shortcut: "2"
    }
    Action {
        onTriggered: skipToNinth(parseInt(shortcut))
        shortcut: "3"
    }
    Action {
        onTriggered: skipToNinth(parseInt(shortcut))
        shortcut: "4"
    }
    Action {
        onTriggered: skipToNinth(parseInt(shortcut))
        shortcut: "5"
    }
    Action {
        onTriggered: skipToNinth(parseInt(shortcut))
        shortcut: "6"
    }
    Action {
        onTriggered: skipToNinth(parseInt(shortcut))
        shortcut: "7"
    }
    Action {
        onTriggered: skipToNinth(parseInt(shortcut))
        shortcut: "8"
    }
    Action {
        onTriggered: skipToNinth(parseInt(shortcut))
        shortcut: "9"
    }
    Action {
        onTriggered: skipToNinth(parseInt(shortcut))
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
