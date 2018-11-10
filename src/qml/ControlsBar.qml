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

            function setCachedDuration(val) {
                cachedLength.width = ((progressBar.width / progressBar.to)
                                      * val) - progressLength.width
            }

            onMoved: {
                player.seekAbsolute(progressBar.value)
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
                    anchors.leftMargin: 2
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
                console.log("Settings Menu Not Yet Implemented.")
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
