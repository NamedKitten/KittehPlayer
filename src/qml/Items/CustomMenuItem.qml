import QtQuick 2.0
import QtQuick.Controls 2.4
import Qt.labs.settings 1.0

MenuItem {
    id: menuItem
    implicitHeight: 20

    contentItem: Text {
        text: menuItem.text

        font.family: appearance.fontName
        font.bold: menuItem.highlighted
        opacity: 1
        color: menuItem.highlighted ? "#5a50da" : "white"
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        width: parent.width
        height: parent.height
        opacity: 1
        color: menuItem.highlighted ? "#c0c0f0" : "transparent"
    }
}
