import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

Item {
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right

    property var background: controlsBackground
    property var progress: progressBar
    property var controls: controlsBar
    property var duration: progressBar.to

    Item {
        id: subtitlesBar
        visible: !appearance.useMpvSubs
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

            Item {
                id: subsContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.rightMargin: 0
                Layout.leftMargin: 0
                Layout.maximumWidth: nativeSubtitles.width
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
                        color: appearance.mainBackground
                        width: subsContainer.childrenRect.width
                        height: subsContainer.childrenRect.height
                    }
                    Component.onCompleted: {
                        player.subtitlesChanged.connect(function(subtitles) {
                            text = subtitles
                        })
                    }
                }
            }
        }
    }

    Rectangle {
        id: controlsBackground
        height: controlsBar.visible ? controlsBar.height + (fun.nyanCat ? progressBackground.height * 0.3: progressBackground.height * 2) : 0
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: appearance.mainBackground
    }

    Item {
        id: controlsBar
        height: controlsBar.visible ? Screen.height / 24 : 0
        anchors.right: parent.right
        anchors.rightMargin: parent.width / 128
        anchors.left: parent.left
        anchors.leftMargin: parent.width / 128
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        visible: true

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
            Component.onCompleted: {
                player.positionChanged.connect(function(position) {
                    if (! pressed) {progressBar.value = position}
                })
                player.durationChanged.connect(function(duration) {
                    progressBar.to = duration
                })
                player.cachedDurationChanged.connect(function(duration) {
                    cachedLength.value = progressBar.value + duration
                })
            }
            onMoved: {
                player.playerCommand(Enums.Commands.SeekAbsolute, value)
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
                color: appearance.progressBackgroundColor
                ProgressBar {
                    id: cachedLength
                    background: Item {}
                    contentItem: Item {
                        Rectangle {
                            width: cachedLength.visualPosition * parent.width
                            height: parent.height
                            color: appearance.progressCachedColor
                        }
                    }
                    z: 40
                    to: progressBar.to
                    anchors.fill: parent
                }
                ProgressBar {
                    z: 50
                    id: progressLength
                    width: parent.width
                    height: parent.height
                    to: progressBar.to
                    value: progressBar.value
                    opacity: 1
                    anchors.leftMargin: 0
                    background: Item {}
                    contentItem: Item {
                        Rectangle {
                            width: progressLength.visualPosition * parent.width + progressBar.handle.width / 2
                            height: parent.height
                            color: appearance.progressSliderColor
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
                radius: 12 + (progressBackground.height / 2)
                color: fun.nyanCat ? "transparent" : appearance.progressSliderColor
                AnimatedImage {
                    z: 80
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

RowLayout {
    id: layout
    anchors.fill: parent
    spacing: 2
    

        Button {
            id: playlistPrevButton
            objectName: "playlistPrevButton"
            icon.source: "icons/prev.svg"
            icon.color: appearance.buttonColor
            display: AbstractButton.IconOnly
            visible: false
            width: visible ? playPauseButton.width : 0
            onClicked: {
                player.playerCommand(Enums.Commands.PreviousPlaylistItem)
            }
            background: Item {}
            Component.onCompleted: {
                player.playlistPositionChanged.connect(function(position) {
                    if (position != 0 ) {
                        visible = true
                    } else {
                        visible = false
                    }
                })
            }
        }

        Button {
            id: playPauseButton
            icon.source: "icons/pause.svg"
            icon.color: appearance.buttonColor
            display: AbstractButton.IconOnly
            onClicked: {
                player.playerCommand(Enums.Commands.TogglePlayPause)
            }
            background: Item {}
            Component.onCompleted: {
                player.playStatusChanged.connect(function(status) {
                    if (status == Enums.PlayStatus.Playing) {
                        icon.source = "qrc:/player/icons/pause.svg"
                    } else if (status == Enums.PlayStatus.Paused) {
                        icon.source = "qrc:/player/icons/play.svg"
                    }
                })
            }
        }

        Button {
            id: playlistNextButton
            //icon.name: "next"
            icon.source: "icons/next.svg"
            icon.color: appearance.buttonColor
            display: AbstractButton.IconOnly
            onClicked: {
                player.playerCommand(Enums.Commands.NextPlaylistItem)
            }
            background: Item {}
        }

        Button {
            id: volumeButton
            objectName: "volumeButton"
            icon.source: "icons/volume-up.svg"
            icon.color: appearance.buttonColor
            display: AbstractButton.IconOnly
            onClicked: {
                player.playerCommand(Enums.Commands.ToggleMute)
            }
            background: Item {}
            Component.onCompleted: {
                player.volumeStatusChanged.connect(function(status) {
                    if (status == Enums.VolumeStatus.Muted) {
                        volumeButton.icon.source = "qrc:/player/icons/volume-mute.svg"
                    } else if (status == Enums.VolumeStatus.Low) {
                        volumeButton.icon.source = "qrc:/player/icons/volume-down.svg"
                    } else if (status == Enums.VolumeStatus.Normal) {
                        volumeButton.icon.source = "qrc:/player/icons/volume-up.svg"
                    }
                })
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
            onMoved: {
                player.playerCommand(Enums.Commands.SetVolume, Math.round(volumeBar.value).toString())
            }
            Component.onCompleted: {
                player.volumeChanged.connect(function(volume) {
                    volumeBar.value = volume
                })
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
            padding: 2
            font.family: appearance.fontName
            font.pixelSize: 14
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
            Component.onCompleted: {
                player.durationStringChanged.connect(function(durationString) {
                    text = durationString
                })
            }
        }

        Item {
            Layout.fillWidth: true
        }

        Button {
            id: settingsButton
            //icon.name: "settings"
            icon.source: "icons/settings.svg"
            icon.color: appearance.buttonColor
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            display: AbstractButton.IconOnly
            onClicked: {
                console.log("Settings Menu Not Yet Implemented.")
            }
            background: Item {}
        }

        Button {
            id: fullscreenButton
            //icon.name: "fullscreen"
            icon.source: "icons/fullscreen.svg"
            icon.color: appearance.buttonColor
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight

            display: AbstractButton.IconOnly
            onClicked: {
                toggleFullscreen()
            }

            background: Item {}
        }
}
    }
}
