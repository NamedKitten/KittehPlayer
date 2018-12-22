import QtQuick 2.0
import QtQuick.Controls 2.4

Menu {
    width: 300
    background: Rectangle {
        implicitWidth: parent.width
        implicitHeight: 10
        color: getAppearanceValueForTheme(appearance.themeName,
                                          "mainBackground")
    }
    delegate: CustomMenuItem {
    }
}
