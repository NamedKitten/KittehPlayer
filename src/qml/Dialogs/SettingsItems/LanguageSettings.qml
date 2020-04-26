import QtQuick 2.0
import QtQuick.Controls 2.3
import "translations.js" as Translations

ComboBox {
    id: languageSelector
    height: 30
    editable: false
    pressed: true
    model: Object.values(Translations.languages)
    delegate: ItemDelegate {
        height: 25
        width: languageSelector.width
        contentItem: Text {
            text: modelData
            color: "#21be2b"
            font: languageSelector.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        highlighted: languageSelector.highlightedIndex === index
    }
    onActivated: {
        console.warn(currentText)
        i18n.language = Object.keys(Translations.languages).find(key => Translations.languages[key] === currentText)
    }
    Component.onCompleted: {
        currentIndex = languageSelector.indexOfValue(Translations.languages[i18n.language])
    }
}
