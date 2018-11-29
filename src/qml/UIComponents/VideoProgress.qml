import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

Slider {
    id: progressBar
    objectName: "progressBar"
    to: 1
    value: 0.0
    Connections {
        target: player
        enabled: true
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
        var x = Math.max(Screen.height / 256, fun.nyanCat ? 12 : 2)
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
        width: parent.width
        height: parent.height
        anchors.fill: parent
        y: parent.y
        x: parent.x
        hoverEnabled: true
        propagateComposedEvents: false
        acceptedButtons: Qt.NoButton
        z: 1

        onPositionChanged: {
            var a = (progressBar.to / progressBar.width) * mouseAreaProgressBar.mouseX
            hoverProgressLabel.text = utils.createTimestamp(a)
        }
    }

    background: Rectangle {
        id: progressBackground
        x: progressBar.leftPadding
        y: progressBar.topPadding + progressBar.availableHeight / 2 - height / 2
        width: progressBar.availableWidth
        height: progressBar.getProgressBarHeight(
                    fun.nyanCat, mouseAreaProgressBar.containsMouse)
        color: appearance.progressBackgroundColor

        Rectangle {
            x: (mouseAreaProgressBar.mouseX - width / 2) + progressBar.leftPadding
            y: progressBackground.y - 20 - height
            visible: mouseAreaProgressBar.containsMouse
            color: appearance.mainBackground
            height: 20
            width: 50
            z: 80
            Text {
                id: hoverProgressLabel
                text: "0:00"
                color: "white"
                padding: 2
                font.family: appearance.fontName
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                renderType: Text.NativeRendering
            }
        }

        ProgressBar {
            id: cachedLength
            background: Item {
            }
            contentItem: Item {
                Rectangle {
                    width: cachedLength.visualPosition * parent.width
                    height: parent.height
                    color: appearance.progressCachedColor
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
                enabled: true
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
            color: appearance.progressSliderColor
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
        radius: 12 + (progressBackground.height / 2)
        color: fun.nyanCat ? "transparent" : appearance.progressSliderColor
        visible: getHandleVisibility(appearance.themeName,
                                     mouseAreaProgressBar.containsMouse)
        AnimatedImage {
            z: 80
            visible: fun.nyanCat
            paused: progressBar.pressed
            height: 30
            id: nyanimation
            anchors.centerIn: parent
            source: "qrc:/icons/nyancat.gif"
            fillMode: Image.PreserveAspectFit
        }
    }
}
