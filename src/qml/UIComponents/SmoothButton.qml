import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import Qt.labs.settings 1.0

import QtQuick 2.0

Control {
    id: root
    property alias iconSource: icon.source
    property alias iconColor: icon.color
    property alias iconHeight: icon.iconHeight
    property alias iconWidth: icon.iconWidth

    background: Item {}
    property bool iconRight: false

    focusPolicy: Qt.NoFocus

    signal clicked
    //onClicked: print('buttonClick')
    leftPadding: appearance.themeName
                 == "YouTube" ? iconWidth / 12 : appearance.themeName
                                == "RoosterTeeth" ? iconWidth / 12 : iconWidth / 2.5
    rightPadding: root.leftPadding

    contentItem: ButtonImage {
        id: icon
        source: "cup.svg"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        propagateComposedEvents: true
        onClicked: root.clicked()
    }
}
