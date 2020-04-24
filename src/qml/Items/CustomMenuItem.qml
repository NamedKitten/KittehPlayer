import QtQuick 2.0
import QtQuick.Controls 2.3

MenuItem {
    id: menuItem
    implicitHeight: 20

    contentItem: Text {
        text: menuItem.text
        opacity: 1
        color: menuItem.highlighted ? "#5a50da" : "white"
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        font {
            family: appearance.fontName
            bold: menuItem.highlighted
        }
    }

    background: Rectangle {
        anchors.fill: parent
        opacity: 1
        color: menuItem.highlighted ? "#c0c0f0" : "transparent"
    }
}
