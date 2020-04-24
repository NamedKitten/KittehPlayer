import player 1.0

Process {
    id: titleProcess
    property string name: ""
    onReadyRead: function () {
        titleGetter.titleFound(name, getOutput())
    }
}
