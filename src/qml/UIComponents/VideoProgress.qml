import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

Slider {
    id: progressBar
    objectName: "progressBar"
    property string currentMediaURL: ""
    property bool playing: false
    to: 1
    value: 0.0
    Connections {
        target: player
        onPlayStatusChanged: function (status) {
            if (status == Enums.PlayStatus.Playing) {
                progressBar.playing = true
            } else if (status == status == Enums.PlayStatus.Paused) {
                progressBar.playing = false
            }
        }
        onPositionChanged: function (position) {
            if (!pressed) {
                progressBar.value = position
            }
        }
        onDurationChanged: function (duration) {
            progressBar.to = duration
        }
        onCachedDurationChanged: function (duration) {
            cachedLength.duration = duration
        }
    }
    onMoved: {
        player.playerCommand(Enums.Commands.SeekAbsolute, value)
    }

    function getProgressBarHeight(nyan, isMouse) {
        var x = fun.nyanCat ? mainWindow.virtualHeight / 64 : mainWindow.virtualHeight / 380
        if (appearance.themeName == "Niconico" && !fun.nyanCat) {
            return x * 2
        } else if (isMouse & !fun.nyanCat) {
            return x * 2
        } else {
            return x
        }
    }
    function getHandleVisibility(themeName, isMouse) {
        if (appearance.themeName == "Niconico" && isMouse) {
            return true
        } else if (appearance.themeName == "Niconico") {
            return false
        } else {
            return true
        }
    }
    MouseArea {
        id: mouseAreaProgressBar
        width: progressBar.width
        height: parent.height
        anchors.fill: parent

        hoverEnabled: true
        propagateComposedEvents: false
        acceptedButtons: Qt.NoButton
        z: 100
        property string currentTime: ""

        onEntered: previewRect.visible = true
        onExited: previewRect.visible = false

        onPositionChanged: {
            var a = (progressBar.to / progressBar.availableWidth)
                    * (mouseAreaProgressBar.mapToItem(
                           progressBar, mouseAreaProgressBar.mouseX, 0).x - 2)
            var shouldSeek = false
            if (!appearance.updatePreviewWhilstPlaying) {
                if (!progressBar.playing) {
                    shouldSeek = true
                }
            } else {
                shouldSeek = true
            }
            if (shouldSeek) {
                /*progressBarTimePreview.playerCommand(
                            Enums.Commands.SeekAbsolute, a)*/
            } else {
                hoverProgressLabel.text = utils.createTimestamp(a)
            }
            previewRect.x = mouseAreaProgressBar.mapToItem(
                        controlsOverlay, mouseAreaProgressBar.mouseX,
                        0).x - previewRect.width / 2
            previewRect.y = progressBackground.y - previewRect.height - controlsBar.height * 2
        }
    }

    background: Rectangle {
        id: progressBackground
        x: progressBar.leftPadding
        y: progressBar.topPadding + progressBar.availableHeight / 2 - height / 2
        width: progressBar.availableWidth
        height: progressBar.getProgressBarHeight(
                    fun.nyanCat, mouseAreaProgressBar.containsMouse)
        color: getAppearanceValueForTheme(appearance.themeName,
                                          "progressBackgroundColor")

        ProgressBar {
            id: cachedLength
            background: Item {
            }
            contentItem: Item {
                Rectangle {
                    width: cachedLength.visualPosition * parent.width
                    height: parent.height
                    color: getAppearanceValueForTheme(appearance.themeName,
                                                      "progressCachedColor")
                }
            }
            z: 40
            to: progressBar.to
            property int duration
            value: progressBar.value + duration
            anchors.fill: parent
        }

        Item {
            anchors.fill: parent
            id: chapterMarkers
            Connections {
                target: player
                onChaptersChanged: function (chapters) {
                    for (var i = 0, len = chapters.length; i < len; i++) {
                        var component = Qt.createComponent("ChapterMarker.qml")
                        var marker = component.createObject(chapterMarkers, {
                                                                time: chapters[i]["time"]
                                                            })
                    }
                }
            }
        }

        Rectangle {
            id: progressLength
            z: 50
            anchors.left: progressBackground.left
            width: progressBar.visualPosition * parent.width
            height: parent.height
            color: getAppearanceValueForTheme(appearance.themeName,
                                              "progressSliderColor")
            Image {
                visible: fun.nyanCat
                id: rainbow
                anchors.fill: parent
                height: parent.height
                width: parent.width
                source: "qrc:/icons/rainbow.png"
                fillMode: Image.TileHorizontally
            }
        }
    }

    handle: Rectangle {
        z: 70
        id: handleRect
        x: progressBar.leftPadding + progressBar.visualPosition
           * (progressBar.availableWidth - width)
        y: progressBar.topPadding + progressBar.availableHeight / 2 - height / 2
        implicitHeight: radius
        implicitWidth: radius
        radius: mainWindow.virtualHeight / 59
        color: appearance.themeName
               == "RoosterTeeth" ? "white" : fun.nyanCat ? "transparent" : getAppearanceValueForTheme(
                                                               appearance.themeName,
                                                               "progressSliderColor")
        visible: getHandleVisibility(appearance.themeName,
                                     mouseAreaProgressBar.containsMouse)
        AnimatedImage {
            z: 80
            visible: fun.nyanCat
            paused: progressBar.pressed
            height: mainWindow.virtualHeight / 28
            id: nyanimation
            anchors.centerIn: parent
            source: "qrc:/icons/nyancat.gif"
            fillMode: Image.PreserveAspectFit
        }
    }
}
