#include "src/Backends/MPVCommon/MPVCommon.hpp"
#include <qbytearray.h>
#include <qcbormap.h> // IWYU pragma: keep
#include <qcoreapplication.h>
#include <qglobal.h>
#include <qjsonarray.h> // IWYU pragma: keep
#include <qjsonobject.h> // IWYU pragma: keep
#include <qlist.h>
#include <qlocale.h>
#include <qmap.h>
#include <qmetaobject.h>
#include <qobjectdefs.h>
#include <qsettings.h>
#include <spdlog/fmt/fmt.h>
#include <string.h>
#include <exception>
#include <memory>
#include "spdlog/logger.h"
#include "src/backendinterface.hpp"
#include "src/logger.h"
#include "src/utils.hpp"

auto mpvLogger = initLogger("mpv");

static inline QVariant node_to_variant(const mpv_node *node)
{
    if (!node) {
      return QVariant();
    }

    switch (node->format) {
    case MPV_FORMAT_STRING:
        return QVariant(QString::fromUtf8(node->u.string));
    case MPV_FORMAT_FLAG:
        return QVariant(static_cast<bool>(node->u.flag));
    case MPV_FORMAT_INT64:
        return QVariant(static_cast<qlonglong>(node->u.int64));
    case MPV_FORMAT_DOUBLE:
        return QVariant(node->u.double_);
    case MPV_FORMAT_NODE_ARRAY: {
        mpv_node_list *list = node->u.list;
        QVariantList qlist;
        for (int n = 0; n < list->num; n++)
            qlist.append(node_to_variant(&list->values[n]));
        return QVariant(qlist);
    }
    case MPV_FORMAT_NODE_MAP: {
        mpv_node_list *list = node->u.list;
        QVariantMap qmap;
        for (int n = 0; n < list->num; n++) {
            qmap.insert(QString::fromUtf8(list->keys[n]),
                        node_to_variant(&list->values[n]));
        }
        return QVariant(qmap);
    }
    default: // MPV_FORMAT_NONE, unknown values (e.g. future extensions)
        return QVariant();
    }
}


namespace MPVCommon {
QString getStats(BackendInterface *b) {
  QString stats;
  stats =
    "<style> blockquote { text-indent: 0px; margin-left:40px; margin-top: 0px; "
    "margin-bottom: 0px; padding-bottom: 0px; padding-top: 0px; padding-left: "
    "0px; } b span p br { margin-bottom: 0px; margin-top: 0px; padding-top: "
    "0px; padding-botom: 0px; text-indent: 0px; } </style>";
  QString filename = b->getProperty("filename").toString();
  // File Info
  stats += "<b>File:</b>  " + filename;
  stats += "<blockquote>";
  QString title = b->getProperty("media-title").toString();
  if (title != filename) {
    stats += "<b>Title:</b>  " + title + "<br>";
  }
  QString fileFormat = b->getProperty("file-format").toString();
  stats += "<b>Format/Protocol:</b>  " + fileFormat + "<br>";
  QLocale a;
  // a.formattedDataSize(
  double cacheUsed = b->getProperty("cache-used").toDouble();
  // Utils::createTimestamp(
  int demuxerSecs = b->getProperty("demuxer-cache-duration").toInt();
  QVariantMap demuxerState = b->getProperty("demuxer-cache-state").toMap();
  int demuxerCache = demuxerState.value("fw-bytes", QVariant(0)).toInt();

  if (demuxerSecs + demuxerCache + cacheUsed > 0) {
    QString cacheStats;
    cacheStats += "<b>Total Cache:</b>  ";
    cacheStats += a.formattedDataSize(demuxerCache + cacheUsed);
    cacheStats += " (<b>Demuxer:</b>  ";

    cacheStats += a.formattedDataSize(demuxerCache);
    cacheStats += ", ";
    cacheStats += QString::number(demuxerSecs) + "s)  ";
    double cacheSpeed = b->getProperty("cache-speed").toDouble();
    if (cacheSpeed > 0) {
      cacheStats += "<b>Speed:</b>  ";
      cacheStats += a.formattedDataSize(demuxerSecs);
      cacheStats += "/s";
    }
    cacheStats += "<br>";
    stats += cacheStats;
  }
  QString fileSize =
    a.formattedDataSize(b->getProperty("file-size").toInt()).remove("-");
  stats += "<b>Size:</b>  " + fileSize + "<br>";

  stats += "</blockquote>";
  // Video Info
  QVariant videoParams = b->getProperty("video-params");
  if (videoParams.isNull()) {
    videoParams = b->getProperty("video-out-params");
  }
  if (!videoParams.isNull()) {
    stats += "<b>Video:</b>  " + b->getProperty("video-codec").toString();
    stats += "<blockquote>";
    QString avsync = QString::number(b->getProperty("avsync").toDouble(), 'f', 3);
    stats += "<b>A-V:</b>  " + QString(avsync) + "<br>";

    stats += "<b>Dropped Frames:</b>  ";
    int dFDC = b->getProperty("decoder-frame-drop-count").toInt();
    if (dFDC > 0) {
      stats += QString::number(dFDC) + " (decoder) ";
    }
    int fDC = b->getProperty("frame-drop-count").toInt();
    if (fDC > 0) {
      stats += QString::number(fDC) + " (output)";
    }
    stats += "<br>";

    int dFPS = b->getProperty("display-fps").toInt();
    int eDFPS = b->getProperty("estimated-display-fps").toInt();
    if ((dFPS + eDFPS) > 0) {
      stats += "<b>Display FPS:</b>  ";

      if (dFPS > 0) {
        stats += QString::number(dFPS);
        stats += " (specified)  ";
      }
      if (eDFPS > 0) {
        stats += QString::number(eDFPS);
        stats += " (estimated)";
      }
      stats += "<br>";
    }

    int cFPS = b->getProperty("container-fps").toInt();
    int eVFPS = b->getProperty("estimated-vf-fps").toInt();
    if ((cFPS + eVFPS) > 0) {
      stats += "<b>FPS:</b>  ";

      if (cFPS > 0) {
        stats += QString::number(cFPS);
        stats += " (specified)  ";
      }
      if (eVFPS > 0) {
        stats += QString::number(eVFPS);
        stats += " (estimated)";
      }
      stats += "<br>";
    }
    QVariantMap vPM = videoParams.toMap();
    stats += "<b>Native Resolution:</b>  ";
    stats += vPM["w"].toString() + " x " + vPM["h"].toString();
    stats += "<br>";

    stats += "<b>Window Scale:</b>  ";
    stats += vPM["window-scale"].toString();
    stats += "<br>";

    stats += "<b>Aspect Ratio:</b>  ";
    stats += vPM["aspect"].toString();
    stats += "<br>";

    stats += "<b>Pixel Format:</b>  ";
    stats += vPM["pixelformat"].toString();
    stats += "<br>";

    stats += "<b>Primaries:</b>  ";
    stats += vPM["primaries"].toString();
    stats += "  <b>Colormatrix:</b>  ";
    stats += vPM["colormatrix"].toString();
    stats += "<br>";

    stats += "<b>Levels:</b>  ";
    stats += vPM["colorlevels"].toString();
    double sigPeak = vPM.value("sig-peak", QVariant(0.0)).toInt();
    if (sigPeak > 0) {
      stats += " (HDR Peak: " + QString::number(sigPeak) + ")";
    }
    stats += "<br>";

    stats += "<b>Gamma:</b>  ";
    stats += vPM["gamma"].toString();
    stats += "<br>";

    int pVB = b->getProperty("packet-video-bitrate").toInt();
    if (pVB > 0) {
      stats += "<b>Bitrate:</b>  ";
      stats += a.formattedDataSize(pVB) + "/s";
      stats += "<br>";
    }

    stats += "</blockquote>";
  }
  QVariant audioParams = b->getProperty("audio-params");
  if (audioParams.isNull()) {
    audioParams = b->getProperty("audio-out-params");
  }
  if (!audioParams.isNull()) {
    stats += "<b>Audio:</b>  " + b->getProperty("audio-codec").toString();
    stats += "<blockquote>";
    QVariantMap aPM = audioParams.toMap();

    stats += "<b>Format:</b>  ";
    stats += aPM["format"].toString();
    stats += "<br>";

    stats += "<b>Sample Rate:</b>  ";
    stats += aPM["samplerate"].toString() + " Hz";
    stats += "<br>";

    stats += "<b>Channels:</b>  ";
    stats += aPM["chanel-count"].toString();
    stats += "<br>";

    int pAB = b->getProperty("packet-audio-bitrate").toInt();
    if (pAB > 0) {
      stats += "<b>Bitrate:</b>  ";
      stats += a.formattedDataSize(pAB) + "/s";
      stats += "<br>";
    }

    stats += "</blockquote>";
  }

  return stats;
}

QVariant playerCommand(BackendInterface *b, const Enums::Commands& cmd, const QVariant& args)
{
  switch (cmd) {
    case Enums::Commands::TogglePlayPause: {
      b->command(QVariantList() << "cycle"
                             << "pause");
      break;
    }
    case Enums::Commands::ToggleMute: {
      b->command(QVariantList() << "cycle"
                             << "mute");
      break;
    }
    case Enums::Commands::SetAudioDevice: {
      b->setProperty("audio-device", args.toString());
      break;
    }
    case Enums::Commands::SetVolume: {
      b->command(QVariantList() << "set"
                             << "volume" << args);
      break;
    }

    case Enums::Commands::AddVolume: {

      b->command(QVariantList() << "add"
                             << "volume" << args);
      break;
    }

    case Enums::Commands::AddSpeed: {

      QString speedString =
        QString::number(b->getProperty("speed").toDouble() + args.toDouble());
      QVariant newSpeed =
        QVariant(speedString.left(speedString.lastIndexOf('.') + 2));

      b->playerCommand(Enums::Commands::SetSpeed, newSpeed);
      break;
    }

    case Enums::Commands::SubtractSpeed: {

      QString speedString =
        QString::number(b->getProperty("speed").toDouble() - args.toDouble());
      QVariant newSpeed =
        QVariant(speedString.left(speedString.lastIndexOf('.') + 2));
      b->playerCommand(Enums::Commands::SetSpeed, newSpeed);
      break;
    }

    case Enums::Commands::ChangeSpeed: {

      b->playerCommand(
        Enums::Commands::SetSpeed,
        QVariant(b->getProperty("speed").toDouble() * args.toDouble()));
      break;
    }

    case Enums::Commands::SetSpeed: {

      b->command(QVariantList() << "set"
                             << "speed" << args.toString());
      break;
    }
    case Enums::Commands::ToggleStats: {

      b->command(QVariantList() << "script-binding"
                             << "stats/display-stats-toggle");
      break;
    }
    case Enums::Commands::NextAudioTrack: {

      b->command(QVariantList() << "cycle"
                             << "audio");
      break;
    }
    case Enums::Commands::NextSubtitleTrack: {

      b->command(QVariantList() << "cycle"
                             << "sub");

      break;
    }
    case Enums::Commands::NextVideoTrack: {
      b->command(QVariantList() << "cycle"
                             << "video");
      break;
    }
    case Enums::Commands::PreviousPlaylistItem: {

      b->command(QVariantList() << "playlist-prev");

      break;
    }
    case Enums::Commands::NextPlaylistItem: {

      b->command(QVariantList() << "playlist-next"
                             << "force");
      break;
    }
    case Enums::Commands::LoadFile: {
      b->command(QVariantList() << "loadfile" << args);

      break;
    }
    case Enums::Commands::AppendFile: {

      b->command(QVariantList() << "loadfile" << args << "append-play");
      break;
    }
    case Enums::Commands::Seek: {

      b->command(QVariantList() << "seek" << args);

      break;
    }
    case Enums::Commands::SeekAbsolute: {

      b->command(QVariantList() << "seek" << args << "absolute");

      break;
    }
    case Enums::Commands::ForwardFrame: {

      b->command(QVariantList() << "frame-step");

      break;
    }
    case Enums::Commands::BackwardFrame: {

      b->command(QVariantList() << "frame-back-step");

      break;
    }

    case Enums::Commands::SetTrack: {

      b->command(QVariantList() << "set" << args.toList()[0] << args.toList()[1]);

      break;
    }

    case Enums::Commands::SetPlaylistPos: {

      b->command(QVariantList() << "set"
                             << "playlist-pos" << args);

      break;
    }

    case Enums::Commands::ForcePause: {

      b->command(QVariantList() << "set"
                             << "pause"
                             << "yes");

      break;
    }

    default: {
      //qDebug() << "Command not found: " << cmd;
      break;
    }
  }
  return QVariant("NoOutput");
}

void updateDurationString(BackendInterface *b, int numTime, QMetaMethod metaMethod)
{
  QVariant speed = b->getProperty("speed");
  QSettings settings;
  if (metaMethod.name() == "positionChanged") {
    if (speed != b->lastSpeed) {
      b->lastSpeed = speed.toDouble();
    } else {
      if (numTime == b->lastTime) {
        return;
      }
    }
    b->lastTime = numTime;
    b->lastPositionString = Utils::createTimestamp(b->lastTime);
  } else if (metaMethod.name() == "durationChanged") {
    b->totalDurationString = Utils::createTimestamp(numTime);
  }
  QString durationString;
  durationString += b->lastPositionString;
  durationString += " / ";
  durationString += b->totalDurationString;
  if (b->lastSpeed != 1) {
    if (settings.value("Appearance/themeName", "").toString() !=
        "RoosterTeeth") {
      durationString += " (" + speed.toString() + "x)";
    }
  }
  emit b->durationStringChanged(durationString);
}

void
handle_mpv_event(BackendInterface *b, mpv_event* event)
{
  switch (event->event_id) {
    case MPV_EVENT_PROPERTY_CHANGE: {
      mpv_event_property* prop = (mpv_event_property*)event->data;
      if (strcmp(prop->name, "time-pos") == 0) {
        if (prop->format == MPV_FORMAT_DOUBLE) {
          double time = *(double*)prop->data;
          emit b->positionChanged(time);
        }
      } else if (strcmp(prop->name, "duration") == 0) {
        if (prop->format == MPV_FORMAT_DOUBLE) {
          double time = *(double*)prop->data;
          emit b->durationChanged(time);
        }
      } else if (strcmp(prop->name, "mute") == 0 ||
                 strcmp(prop->name, "volume") == 0) {
        double volume = b->getProperty("volume").toDouble();
        bool mute = b->getProperty("mute").toBool();
        if (mute || volume == 0) {
          emit b->volumeStatusChanged(Enums::VolumeStatus::Muted);
        } else {
          if (volume < 25) {
            emit b->volumeStatusChanged(Enums::VolumeStatus::Low);
          } else {
            emit b->volumeStatusChanged(Enums::VolumeStatus::Normal);
          }
        }
        // emit volumeChanged(volume);
      } else if (strcmp(prop->name, "media-title") == 0) {
        if (prop->format == MPV_FORMAT_STRING) {
          char* title = *(char**)prop->data;
          emit b->titleChanged(QString(title));
        }
      } else if (strcmp(prop->name, "sub-text") == 0) {
        if (prop->format == MPV_FORMAT_STRING) {
          char* subs = *(char**)prop->data;
          emit b->subtitlesChanged(QString(subs));
        }
      } else if (strcmp(prop->name, "demuxer-cache-duration") == 0) {
        if (prop->format == MPV_FORMAT_DOUBLE) {
          double duration = *(double*)prop->data;
          emit b->cachedDurationChanged(duration);
        }
      } else if (strcmp(prop->name, "playlist-pos") == 0) {
        if (prop->format == MPV_FORMAT_DOUBLE) {
          double pos = *(double*)prop->data;
          emit b->playlistPositionChanged(pos);
        }
      } else if (strcmp(prop->name, "pause") == 0) {
        mpv_node* nod = (mpv_node*)prop->data;
        if (node_to_variant(nod).toBool()) {
          emit b->playStatusChanged(Enums::PlayStatus::Paused);
          // Utils::SetScreensaver(window()->winId(), true);
        } else {
          emit b->playStatusChanged(Enums::PlayStatus::Playing);
          // Utils::SetScreensaver(window()->winId(), false);
        }
      } else if (strcmp(prop->name, "track-list") == 0) {
        mpv_node* nod = (mpv_node*)prop->data;
        emit b->tracksChanged(node_to_variant(nod).toList());
      } else if (strcmp(prop->name, "audio-device-list") == 0) {
        mpv_node* nod = (mpv_node*)prop->data;
        emit b->audioDevicesChanged(b->getAudioDevices(node_to_variant(nod)));
      } else if (strcmp(prop->name, "playlist") == 0) {
        mpv_node* nod = (mpv_node*)prop->data;
        emit b->playlistChanged(node_to_variant(nod).toList());
      } else if (strcmp(prop->name, "chapter-list") == 0) {
        mpv_node* nod = (mpv_node*)prop->data;
        emit b->chaptersChanged(node_to_variant(nod).toList());
      } else if (strcmp(prop->name, "speed") == 0) {
        double speed = *(double*)prop->data;
        emit b->speedChanged(speed);
      }
      break;
    }

    case MPV_EVENT_LOG_MESSAGE: {
        struct mpv_event_log_message* msg =
          (struct mpv_event_log_message*)event->data;
        QString logMsg = "[" + QString(msg->prefix) + "] " + QString(msg->text);
        QString msgLevel = QString(msg->level);
        if (msgLevel.startsWith("d") || msgLevel.startsWith("t")) {
          mpvLogger->info("{}", logMsg.toStdString());
        } else if (msgLevel.startsWith("v") || msgLevel.startsWith("i")) {
          mpvLogger->info("{}", logMsg.toStdString());
        } else {
          mpvLogger->debug("{}", logMsg.toStdString());
        }

      break;
    }
    case MPV_EVENT_SHUTDOWN: {
      qApp->exit();
      break;
    }
    default: {
      break;
    }
  }
}

QVariantMap getAudioDevices(const QVariant& drivers)
{
  QVariantMap newDrivers;
  if (drivers.isNull()) {
    return newDrivers;
  }

  QSequentialIterable iterable = drivers.value<QSequentialIterable>();
  foreach (const QVariant& v, iterable) {
    QVariantMap item = v.toMap();
    newDrivers[item["description"].toString()] = item;
  }
  return newDrivers;
}

}