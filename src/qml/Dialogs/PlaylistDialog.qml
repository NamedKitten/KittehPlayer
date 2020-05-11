import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import QtQuick.Window 2.2
import player 1.0

Dialog {
  id: playlistDialog
  title: "Playlist"
  height: Math.max(480, childrenRect.height * playlistListView.count)
  width: 720
  modality: Qt.NonModal
  property int thumbnailJobsRunning: 0
  property variant thumbnailJobs: []
  property int titleJobsRunning: 0
  property variant titleJobs: []

  function addThumbnailToCache(name, output) {
    output = output.replace("maxresdefault", "sddefault").split('\n')[0]
    thumbnailCache.addURL(name, output)
    thumbnailJobs.shift()
    thumbnailJobsRunning -= 1
  }

  ThumbnailCache {
    id: thumbnailCache
  }

  Rectangle {
    visible: false
    id: titleGetter
    signal titleFound(string name, string title)
  }

  Timer {
    interval: 500
    repeat: true
    triggeredOnStart: true
    running: true
    onTriggered: {
      if (thumbnailJobsRunning < 2) {
        if (thumbnailJobs.length > 0) {
          if (thumbnailJobs[0].startsWith(
                "https://www.youtube.com/playlist?list=")) {
            thumbnailJobs.shift()
            return
          }
          var component = Qt.createComponent("ThumbnailProcess.qml")
          var thumbnailerProcess = component.createObject(playlistDialog, {
                                                            "name": thumbnailJobs[0]
                                                          })
          if (String(thumbnailJobs[0]).indexOf("://") !== -1) {

            thumbnailerProcess.start("youtube-dl",
                                     ["--get-thumbnail", thumbnailJobs[0]])
          } else {
            thumbnailerProcess.start(
                  "ffmpegthumbnailer",
                  ["-i", thumbnailJobs[0], "-o", "/tmp/" + Qt.md5(
                     thumbnailJobs[0]) + ".png"])
          }

          thumbnailJobsRunning += 1
        }
      }
    }
  }

  Timer {
    interval: 100
    repeat: true
    triggeredOnStart: true
    running: true
    onTriggered: {
      if (titleJobsRunning < 5) {
        if (titleJobs.length > 0) {
          if (titleJobs[0].startsWith("https://www.youtube.com/playlist?list=")) {
            titleJobs.shift()
            return
          }
          var component = Qt.createComponent("TitleProcess.qml")
          var titleProcess = component.createObject(playlistDialog, {
                                                      "name": titleJobs[0]
                                                    })
          titleProcess.start("youtube-dl", ["--get-title", titleJobs[0]])
          titleJobs.shift()
          titleJobsRunning += 1
        }
      }
    }
  }

  Connections {
    target: player
    onPlaylistChanged: function (playlist) {
      playlistModel.clear()
      thumbnailJobs = []
      titleJobs = []
      titleJobsRunning = 0
      thumbnailJobsRunning = 0
      for (var thing in playlist) {
        var item = playlist[thing]
        playlistModel.append({
                               "playlistItemTitle": item["title"],
                               "playlistItemFilename": item["filename"],
                               "current": item["current"],
                               "playlistPos": thing
                             })
      }
    }
  }

  Component {
    id: playlistDelegate
    Item {
      id: playlistItem
      property string itemURL: ""
      property string itemTitle: ""
      width: playlistDialog.width
      height: childrenRect.height
      function getText(title, filename) {
        var itemText = ""
        if (title.length > 0) {
          itemText += '<b>Title:</b> ' + title + "<br>"
        }
        if (filename.length > 0) {
          itemText += '<b>Filename:</b> ' + filename
        }
        return itemText
      }
      Connections {
        target: thumbnailCache
        onThumbnailReady: function (name, url, path) {
          console.error(name,url,path,playlistItem.itemURL)
          if (name == playlistItem.itemURL) {
            thumbnail.source = path
          }
        }
      }

      Connections {
        target: titleGetter
        onTitleFound: function (name, title) {
          if (name == playlistItem.itemURL) {
            titleJobsRunning -= 1
            playlistItem.itemTitle = title
          }
        }
      }

      Image {
        id: thumbnail
        source: ""
        height: source.toString().length > 1 ? 144 : 0
        width: source.toString().length > 1 ? 256 : 0
      }

      Button {
        width: parent.width - 20
        id: playlistItemButton
        font.pixelSize: 12
        padding: 0
        anchors.left: thumbnail.right
        bottomPadding: 0
        contentItem: Text {
          id: playlistItemText
          font: parent.font
          color: "white"
          text: playlistItem.getText(itemTitle, itemURL)
          height: parent.height
          horizontalAlignment: Text.AlignLeft
          verticalAlignment: Text.AlignVCenter
          elide: Text.ElideRight
          wrapMode: Text.Wrap
        }

        onClicked: {
          player.playerCommand(Enums.Commands.SetPlaylistPos, playlistPos)
        }
        background: Rectangle {
          color: current ? "orange" : "transparent"
        }
      }

      Component.onCompleted: {
        if (typeof playlistItemTitle !== "undefined") {
          playlistItem.itemTitle = playlistItemTitle
        } else {
          playlistDialog.titleJobs.push(playlistItemFilename)
        }
        if (typeof playlistItemFilename !== "undefined") {
          playlistItem.itemURL = playlistItemFilename
        } else {
          playlistItem.itemURL = ""
        }
        playlistDialog.thumbnailJobs.push(playlistItemFilename)
      }
    }
  }

  ListView {
    id: playlistListView
    anchors.fill: parent
    model: ListModel {
      id: playlistModel
    }
    delegate: playlistDelegate
    highlight: Item {}
    snapMode: ListView.SnapToItem
    flickableDirection: Flickable.VerticalFlick
    boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: ScrollBar {
      active: playlistListView.count > 1 ? true : true
    }
    focus: true
  }
  Component.onCompleted: {
    playlistDialog.open()
  }
}
