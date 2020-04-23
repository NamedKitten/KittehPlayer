import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2

Item {
    id: menuTitleBar
    height: menuBar.height
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    visible: true

    Connections {
        target: globalConnections
        onHideUI: function () {
            if (!menuBar.anythingOpen()) {
                menuTitleBar.visible = false
            }
        }
        onShowUI: {
            menuTitleBar.visible = true
        }
    }

    MainMenu {
        id: menuBar
    }

    Rectangle {
        id: titleBar
        height: menuBar.height
        anchors.right: parent.right
        anchors.left: menuBar.right
        anchors.top: parent.top
        color: getAppearanceValueForTheme(appearance.themeName,
                                          "mainBackground")

        Text {
            id: titleLabel
            objectName: "titleLabel"
            text: translate.getTranslation("TITLE", i18n.language)
            color: "white"
            width: parent.width
            height: parent.height
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4
            anchors.top: parent.top
            font.family: appearance.fontName
            fontSizeMode: Text.VerticalFit
            font.pixelSize: appearance.scaleFactor * (height - anchors.topMargin
                                                      - anchors.bottomMargin - 2)
            font.bold: true
            opacity: 1
            visible: menuTitleBar.visible
                     && ((!appearance.titleOnlyOnFullscreen)
                         || (mainWindow.visibility == Window.FullScreen
                             || mainWindow.visibility == Window.Maximized))
            Connections {
                target: player
                onTitleChanged: function (title) {
                    titleLabel.text = title
                    mainWindow.title = title
                }
            }
        }
    }
}
