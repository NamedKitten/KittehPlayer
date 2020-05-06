import player 1.0

Process {
  id: thumbnailerProcess
  property string name: ""
  onFinished: function () {
    if (String(name).indexOf("://") !== -1) {
      playlistDialog.addThumbnailToCache(name, getOutput())
    } else {
      playlistDialog.addThumbnailToCache(name, "/tmp/" + Qt.md5(name) + ".png")
    }
  }
}
