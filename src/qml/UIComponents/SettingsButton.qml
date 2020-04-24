import player 1.0

SmoothButton {
    id: settingsButton
    iconSource: "icons/" + appearance.themeName + "/settings.svg"
    onClicked: {
        switch(appearance.themeName) {
            case "YouTube":
                appearance.themeName = "RoosterTeeth"
                break
            case "RoosterTeeth":
                appearance.themeName = "Niconico"
                break
            case "Niconico":
                appearance.themeName = "YouTube"
                break
            default:
                appearance.themeName = "YouTube"
        }
    }
}
