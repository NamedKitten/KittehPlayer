import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

Item {
    id: controlsBarItem
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right

    property var combinedHeight: progressBar.height + controlsBackground.height
    property bool controlsShowing: true

    Connections {
        target: globalConnections
        onHideUI: function (force) {
            controlsBarItem.controlsShowing = false
        }
        onShowUI: {
            controlsBarItem.controlsShowing = true
        }
    }

    Component.onCompleted: {
        setControlsTheme(appearance.themeName)
    }

    Connections {
        target: appearance
        onThemeNameChanged: setControlsTheme(appearance.themeName)
    }

    function setControlsTheme(themeName) {
        for (var i = 0; i < controlsBar.children.length; ++i) {
            if (controlsBar.children[i].objectName == "buttonLayout") {
                controlsBar.children[i].destroy()
            }
        }

        var component = Qt.createComponent(themeName + "ButtonLayout.qml")
        if (component.status == Component.Error) {
            console.error("Error loading component: " + component.errorString())
        }
        component.createObject(controlsBar, {})
    }

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
                    font.pixelSize: appearance.subtitlesFontSize
                    font.family: appearance.fontName
                    horizontalAlignment: Text.AlignHCenter
                    opacity: 1
                    background: Rectangle {
                        id: subsBackground
                        color: getAppearanceValueForTheme(appearance.themeName,
                                                          "mainBackground")
                        width: subsContainer.childrenRect.width
                        height: subsContainer.childrenRect.height
                    }
                    Connections {
                        target: player
                        onSubtitlesChanged: function (subtitles) {
                            nativeSubs.text = subtitles
                        }
                    }
                }
            }
        }
    }

    VideoProgress {
        id: progressBar
        visible: controlsBarItem.controlsShowing
                 && (appearance.themeName == "RoosterTeeth" ? false : true)
        anchors.bottom: controlsBackground.top
        anchors.left: controlsBackground.left
        anchors.right: controlsBackground.right
        anchors.bottomMargin: 0
        bottomPadding: 0
        z: 20
    }

    Rectangle {
        id: controlsBackground
        height: controlsBar.visible ? controlsBar.height
                                      + (appearance.themeName
                                         == "RoosterTeeth" ? 0 : progressBar.topPadding) : 0
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: getAppearanceValueForTheme(appearance.themeName,
                                          "mainBackground")
        visible: controlsBarItem.controlsShowing
        z: 10
    }

    Item {
        id: controlsBar
        height: controlsBar.visible ? mainWindow.virtualHeight / 20 : 0
        anchors.right: parent.right
        anchors.rightMargin: parent.width / 128
        anchors.left: parent.left
        anchors.leftMargin: parent.width / 128
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        visible: controlsBarItem.controlsShowing
        z: 30
    }
}
