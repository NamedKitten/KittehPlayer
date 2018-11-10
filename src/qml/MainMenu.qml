import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

MenuBar {
    id: menuBar
    //width: parent.width
    height: Math.max(24, Screen.height / 32)
    property bool anythingOpen: fileMenuBarItem.opened
                                || playbackMenuBarItem.opened
                                || viewMenuBarItem.opened
                                || audioMenuBarItem.opened
                                || videoMenuBarItem.opened
                                || subsMenuBarItem.opened
                                || aboutMenuBarItem.opened

    objectName: "menuBar"

    function updateTracks() {
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
            text: translate.getTranslation("SPEED_DECREASE_POINT_ONE",
                                           i18n.language)
            onTriggered: {
                player.subtractSpeed(0.1)
            }
            shortcut: keybinds.decreaseSpeedByPointOne
        }
        Action {
            text: translate.getTranslation("SPEED_INCREASE_POINT_ONE",
                                           i18n.language)
            onTriggered: {
                player.addSpeed(0.1)
            }
            shortcut: keybinds.increaseSpeedByPointOne
        }
        Action {
            text: translate.getTranslation("HALVE_SPEED", i18n.language)
            onTriggered: {
                player.changeSpeed(0.5)
            }
            shortcut: keybinds.halveSpeed
        }
        Action {
            text: translate.getTranslation("DOUBLE_SPEED", i18n.language)
            onTriggered: {
                player.changeSpeed(2)
            }
            shortcut: keybinds.doubleSpeed
        }
        Action {
            text: translate.getTranslation("FORWARD_FRAME", i18n.language)
            onTriggered: {
                player.command(["frame-step"])
            }
            shortcut: keybinds.forwardFrame
        }
        Action {
            text: translate.getTranslation("BACKWARD_FRAME", i18n.language)
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
            text: translate.getTranslation("CYCLE_AUDIO_TRACK", i18n.language)
            onTriggered: {
                player.nextAudioTrack()
            }
            shortcut: keybinds.cycleAudio
        }
        Action {
            text: translate.getTranslation("INCREASE_VOLUME", i18n.language)
            onTriggered: {
                player.addVolume("2")
            }
            shortcut: keybinds.increaseVolume
        }
        Action {
            text: translate.getTranslation("DECREASE_VOLUME", i18n.language)
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
            title: translate.getTranslation("AUDIO_DEVICES", i18n.language)
            id: audioDeviceMenu
            objectName: "audioDeviceMenu"

            function update() {
                var audioDevices = player.getaudioDevices()

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
                player.nextSubtitleTrack()
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
                player.toggleStats()
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
