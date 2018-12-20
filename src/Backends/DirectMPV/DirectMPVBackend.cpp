#include <clocale>
#include <stdbool.h>
#include <stdexcept>

#include "src/Backends/DirectMPV/DirectMPVBackend.hpp"

#include "src/utils.hpp"
#include <QApplication>
#include <QMainWindow>
#include <QOpenGLContext>
#include <QOpenGLFramebufferObject>
#include <QQuickWindow>

#include <QSequentialIterable>
#include <math.h>

void
wakeup(void* ctx)
{
  QCoreApplication::postEvent((DirectMPVBackend*)ctx,
                              new QEvent(QEvent::User));
}

static void*
get_proc_address(void* ctx, const char* name)
{
  (void)ctx;
  QOpenGLContext* glctx = QOpenGLContext::currentContext();
  if (!glctx)
    return NULL;
  return (void*)glctx->getProcAddress(QByteArray(name));
}

MpvRenderer::MpvRenderer(mpv_handle* a_mpv, mpv_opengl_cb_context* a_mpv_gl)
  : mpv(a_mpv)
  , mpv_gl(a_mpv_gl)
  , window(0)
  , size()
{
  int r = mpv_opengl_cb_init_gl(mpv_gl, NULL, get_proc_address, NULL);
  if (r < 0)
    qDebug() << "could not initialize OpenGL";
}

MpvRenderer::~MpvRenderer()
{
  // Until this call is done, we need to make sure the player remains
  // alive. This is done implicitly with the mpv::qt::Handle instance
  // in this class.
  exit(0);
}

void
MpvRenderer::paint()
{
  window->resetOpenGLState();

  // This uses 0 as framebuffer, which indicates that mpv will render directly
  // to the frontbuffer. Note that mpv will always switch framebuffers
  // explicitly. Some QWindow setups (such as using QQuickWidget) actually
  // want you to render into a FBO in the beforeRendering() signal, and this
  // code won't work there.
  // The negation is used for rendering with OpenGL's flipped coordinates.
  mpv_opengl_cb_draw(mpv_gl, 0, size.width(), -size.height());

  window->resetOpenGLState();
}

DirectMPVBackend::DirectMPVBackend(QQuickItem* parent)
  : QQuickItem(parent)
  , mpv_gl(0)
  , renderer(0)
{
  mpv = mpv_create();
  if (!mpv)
    throw std::runtime_error("could not create mpv context");

  mpv_set_option_string(mpv, "terminal", "no");
  mpv_set_option_string(mpv, "msg-level", "all=v");

  // Fix?
  mpv_set_option_string(mpv, "ytdl", "yes");

  mpv_set_option_string(mpv, "slang", "en");

  mpv_set_option_string(mpv, "config", "yes");
  // mpv_set_option_string(mpv, "sub-visibility", "no");
  mpv_observe_property(mpv, 0, "tracks-menu", MPV_FORMAT_NONE);
  mpv_observe_property(mpv, 0, "playback-abort", MPV_FORMAT_NONE);
  mpv_observe_property(mpv, 0, "chapter-list", MPV_FORMAT_NODE);
  mpv_observe_property(mpv, 0, "track-list", MPV_FORMAT_NODE);
  mpv_observe_property(mpv, 0, "chapter-list", MPV_FORMAT_NODE);
  mpv_observe_property(mpv, 0, "audio-device-list", MPV_FORMAT_NONE);
  mpv_observe_property(mpv, 0, "playlist-pos", MPV_FORMAT_DOUBLE);
  mpv_observe_property(mpv, 0, "volume", MPV_FORMAT_NONE);
  mpv_observe_property(mpv, 0, "mute", MPV_FORMAT_NONE);
  mpv_observe_property(mpv, 0, "duration", MPV_FORMAT_DOUBLE);
  mpv_observe_property(mpv, 0, "media-title", MPV_FORMAT_STRING);
  mpv_observe_property(mpv, 0, "sub-text", MPV_FORMAT_STRING);
  mpv_observe_property(mpv, 0, "time-pos", MPV_FORMAT_DOUBLE);
  mpv_observe_property(mpv, 0, "demuxer-cache-duration", MPV_FORMAT_DOUBLE);
  mpv_observe_property(mpv, 0, "pause", MPV_FORMAT_NODE);
  mpv_observe_property(mpv, 0, "playlist", MPV_FORMAT_NODE);
  mpv_observe_property(mpv, 0, "speed", MPV_FORMAT_DOUBLE);
  mpv_set_wakeup_callback(mpv, wakeup, this);

  if (mpv_initialize(mpv) < 0)
    throw std::runtime_error("could not initialize mpv context");

  // Make use of the MPV_SUB_API_OPENGL_CB API.
  mpv::qt::set_option_variant(mpv, "vo", "opengl-cb");

  // Setup the callback that will make QtQuick update and redraw if there
  // is a new video frame. Use a queued connection: this makes sure the
  // doUpdate() function is run on the GUI thread.
  mpv_gl = (mpv_opengl_cb_context*)mpv_get_sub_api(mpv, MPV_SUB_API_OPENGL_CB);
  if (!mpv_gl)
    throw std::runtime_error("OpenGL not compiled in");
  mpv_opengl_cb_set_update_callback(
    mpv_gl, DirectMPVBackend::on_update, (void*)this);

  connect(this,
          &DirectMPVBackend::onUpdate,
          this,
          &DirectMPVBackend::doUpdate,
          Qt::QueuedConnection);
  connect(this,
          &DirectMPVBackend::positionChanged,
          &DirectMPVBackend::updateDurationString);
  connect(this,
          &DirectMPVBackend::durationChanged,
          &DirectMPVBackend::updateDurationString);

  connect(this,
          &QQuickItem::windowChanged,
          this,
          &DirectMPVBackend::handleWindowChanged);
}

DirectMPVBackend::~DirectMPVBackend()
{
  printf("Shutting down...\n");
  qApp->quit();
  printf("MPV terminated.\n");
}

void
DirectMPVBackend::sync()
{

  if (!renderer) {
    window()->setIcon(QIcon(":/icon.png"));
    renderer = new MpvRenderer(mpv, mpv_gl);
    connect(window(),
            &QQuickWindow::beforeRendering,
            renderer,
            &MpvRenderer::paint,
            Qt::DirectConnection);
    QMetaObject::invokeMethod(this, "startPlayer");
  }
  renderer->window = window();
  renderer->size = window()->size() * window()->devicePixelRatio();
}

void
DirectMPVBackend::swapped()
{
  mpv_opengl_cb_report_flip(mpv_gl, 0);
}

void
DirectMPVBackend::cleanup()
{
  if (renderer) {
    delete renderer;
    renderer = 0;
  }
}

void
DirectMPVBackend::on_update(void* ctx)
{
  DirectMPVBackend* self = (DirectMPVBackend*)ctx;
  emit self->onUpdate();
}

void
DirectMPVBackend::doUpdate()
{
  window()->update();
  update();
}

QVariant
DirectMPVBackend::getProperty(const QString& name) const
{
  return mpv::qt::get_property_variant(mpv, name);
}

void
DirectMPVBackend::command(const QVariant& params)
{
  mpv::qt::command_variant(mpv, params);
}

void
DirectMPVBackend::setProperty(const QString& name, const QVariant& value)
{
  mpv::qt::set_property_variant(mpv, name, value);
}

void
DirectMPVBackend::setOption(const QString& name, const QVariant& value)
{
  mpv::qt::set_option_variant(mpv, name, value);
}

void
DirectMPVBackend::launchAboutQt()
{
  QApplication* qapp =
    qobject_cast<QApplication*>(QCoreApplication::instance());
  qapp->aboutQt();
}

QVariant
DirectMPVBackend::playerCommand(const Enums::Commands& cmd)
{
  return playerCommand(cmd, QVariant("NoArgProvided"));
}

QVariant
DirectMPVBackend::playerCommand(const Enums::Commands& cmd,
                                      const QVariant& args)
{
  switch (cmd) {
    case Enums::Commands::TogglePlayPause: {
      command(QVariantList() << "cycle"
                             << "pause");
      break;
    }
    case Enums::Commands::ToggleMute: {
      command(QVariantList() << "cycle"
                             << "mute");
      break;
    }
    case Enums::Commands::SetAudioDevice: {
      setProperty("audio-device", args.toString());
      break;
    }

    case Enums::Commands::SetVolume: {
      command(QVariantList() << "set"
                             << "volume" << args);
      break;
    }

    case Enums::Commands::AddVolume: {

      command(QVariantList() << "add"
                             << "volume" << args);
      break;
    }

    case Enums::Commands::AddSpeed: {

      QString speedString =
        QString::number(getProperty("speed").toDouble() + args.toDouble());
      QVariant newSpeed =
        QVariant(speedString.left(speedString.lastIndexOf('.') + 2));

      playerCommand(Enums::Commands::SetSpeed, newSpeed);
      break;
    }

    case Enums::Commands::SubtractSpeed: {

      QString speedString =
        QString::number(getProperty("speed").toDouble() - args.toDouble());
      QVariant newSpeed =
        QVariant(speedString.left(speedString.lastIndexOf('.') + 2));
      playerCommand(Enums::Commands::SetSpeed, newSpeed);
      break;
    }

    case Enums::Commands::ChangeSpeed: {

      playerCommand(
        Enums::Commands::SetSpeed,
        QVariant(getProperty("speed").toDouble() * args.toDouble()));
      break;
    }

    case Enums::Commands::SetSpeed: {

      command(QVariantList() << "set"
                             << "speed" << args.toString());
      break;
    }
    case Enums::Commands::ToggleStats: {

      command(QVariantList() << "script-binding"
                             << "stats/display-stats-toggle");
      break;
    }
    case Enums::Commands::NextAudioTrack: {

      command(QVariantList() << "cycle"
                             << "audio");
      break;
    }
    case Enums::Commands::NextSubtitleTrack: {

      command(QVariantList() << "cycle"
                             << "sub");

      break;
    }
    case Enums::Commands::NextVideoTrack: {
      command(QVariantList() << "cycle"
                             << "video");
      break;
    }
    case Enums::Commands::PreviousPlaylistItem: {

      command(QVariantList() << "playlist-prev");

      break;
    }
    case Enums::Commands::NextPlaylistItem: {

      command(QVariantList() << "playlist-next"
                             << "force");
      break;
    }
    case Enums::Commands::LoadFile: {
      command(QVariantList() << "loadfile" << args);

      break;
    }
    case Enums::Commands::AppendFile: {

      command(QVariantList() << "loadfile" << args << "append-play");
      break;
    }
    case Enums::Commands::Seek: {

      command(QVariantList() << "seek" << args);

      break;
    }
    case Enums::Commands::SeekAbsolute: {

      command(QVariantList() << "seek" << args << "absolute");

      break;
    }
    case Enums::Commands::ForwardFrame: {

      command(QVariantList() << "frame-step");

      break;
    }
    case Enums::Commands::BackwardFrame: {

      command(QVariantList() << "frame-back-step");

      break;
    }

    case Enums::Commands::SetTrack: {

      command(QVariantList() << "set" << args.toList()[0] << args.toList()[1]);

      break;
    }

    case Enums::Commands::SetPlaylistPos: {

      command(QVariantList() << "set"
                             << "playlist-pos" << args);

      break;
    }

    default: {
      qDebug() << "Command not found: " << cmd;
      break;
    }
  }
  return QVariant("NoOutput");
}

void
DirectMPVBackend::handleWindowChanged(QQuickWindow* win)
{
  if (!win)
    return;
  connect(win,
          &QQuickWindow::beforeSynchronizing,
          this,
          &DirectMPVBackend::sync,
          Qt::DirectConnection);
  connect(win,
          &QQuickWindow::sceneGraphInvalidated,
          this,
          &DirectMPVBackend::cleanup,
          Qt::DirectConnection);
  connect(win,
          &QQuickWindow::frameSwapped,
          this,
          &DirectMPVBackend::swapped,
          Qt::DirectConnection);
  win->setClearBeforeRendering(false);
}

void
DirectMPVBackend::toggleOnTop()
{
  onTop = !onTop;
  Utils::AlwaysOnTop(window()->winId(), onTop);
}

bool
DirectMPVBackend::event(QEvent* event)
{
  if (event->type() == QEvent::User) {
    on_mpv_events();
  }
  return QObject::event(event);
}

void
DirectMPVBackend::on_mpv_events()
{
  while (mpv) {
    mpv_event* event = mpv_wait_event(mpv, 0);
    if (event->event_id == MPV_EVENT_NONE) {
      break;
    }
    handle_mpv_event(event);
  }
}

void
DirectMPVBackend::updateDurationString(int numTime)
{
  QVariant speed = getProperty("speed");
  QMetaMethod metaMethod = sender()->metaObject()->method(senderSignalIndex());
  if (metaMethod.name() == "positionChanged") {
    if (speed != lastSpeed) {
      lastSpeed = speed.toDouble();
    } else {
      if (numTime == lastTime) {
        return;
      }
    }
    lastTime = numTime;
    lastPositionString = Utils::createTimestamp(lastTime);
  } else if (metaMethod.name() == "durationChanged") {
    totalDurationString = Utils::createTimestamp(numTime);
  }
  QString durationString;
  durationString += lastPositionString;
  durationString += " / ";
  durationString += totalDurationString;
  if (lastSpeed != 1) {
    if (settings.value("Appearance/themeName", "").toString() !=
        "RoosterTeeth") {
      durationString += " (" + speed.toString() + "x)";
    }
  }
  emit durationStringChanged(durationString);
}

void
DirectMPVBackend::updateAppImage()
{
  Utils::updateAppImage();
}

QVariantMap
DirectMPVBackend::getAudioDevices() const
{
  QVariant drivers = getProperty("audio-device-list");
  QVariant currentDevice = getProperty("audio-device");

  QVariantMap newDrivers;

  QSequentialIterable iterable = drivers.value<QSequentialIterable>();
  foreach (const QVariant& v, iterable) {
    QVariantMap item = v.toMap();
    item["selected"] = currentDevice == item["name"];
    newDrivers[item["description"].toString()] = item;
  }
  QMap<QString, QVariant> pulseItem;
  pulseItem["name"] = "pulse";
  pulseItem["description"] = "Default (pulseaudio)";
  pulseItem["selected"] = currentDevice == "pulse";
  newDrivers[pulseItem["description"].toString()] = pulseItem;
  return newDrivers;
}

void
DirectMPVBackend::handle_mpv_event(mpv_event* event)
{
  switch (event->event_id) {
    case MPV_EVENT_PROPERTY_CHANGE: {
      mpv_event_property* prop = (mpv_event_property*)event->data;
      if (strcmp(prop->name, "time-pos") == 0) {
        if (prop->format == MPV_FORMAT_DOUBLE) {
          double time = *(double*)prop->data;
          emit positionChanged(time);
        }
      } else if (strcmp(prop->name, "duration") == 0) {
        if (prop->format == MPV_FORMAT_DOUBLE) {
          double time = *(double*)prop->data;
          emit durationChanged(time);
        }
      } else if (strcmp(prop->name, "mute") == 0 ||
                 strcmp(prop->name, "volume") == 0) {
        double volume = getProperty("volume").toDouble();
        bool mute = getProperty("mute").toBool();
        if (mute || volume == 0) {
          emit volumeStatusChanged(Enums::VolumeStatus::Muted);
        } else {
          if (volume < 25) {
            emit volumeStatusChanged(Enums::VolumeStatus::Low);
          } else {
            emit volumeStatusChanged(Enums::VolumeStatus::Normal);
          }
        }
        // emit volumeChanged(volume);
      } else if (strcmp(prop->name, "media-title") == 0) {
        if (prop->format == MPV_FORMAT_STRING) {
          char* title = *(char**)prop->data;
          emit titleChanged(QString(title));
        }
      } else if (strcmp(prop->name, "sub-text") == 0) {
        if (prop->format == MPV_FORMAT_STRING) {
          char* subs = *(char**)prop->data;
          emit subtitlesChanged(QString(subs));
        }
      } else if (strcmp(prop->name, "demuxer-cache-duration") == 0) {
        if (prop->format == MPV_FORMAT_DOUBLE) {
          double duration = *(double*)prop->data;
          emit cachedDurationChanged(duration);
        }
      } else if (strcmp(prop->name, "playlist-pos") == 0) {
        if (prop->format == MPV_FORMAT_DOUBLE) {
          double pos = *(double*)prop->data;
          emit playlistPositionChanged(pos);
        }
      } else if (strcmp(prop->name, "pause") == 0) {
        mpv_node* nod = (mpv_node*)prop->data;
        if (mpv::qt::node_to_variant(nod).toBool()) {
          emit playStatusChanged(Enums::PlayStatus::Paused);
          Utils::SetScreensaver(window()->winId(), true);

        } else {
          emit playStatusChanged(Enums::PlayStatus::Playing);
          Utils::SetScreensaver(window()->winId(), true);
        }
      } else if (strcmp(prop->name, "track-list") == 0) {
        mpv_node* nod = (mpv_node*)prop->data;
        emit tracksChanged(mpv::qt::node_to_variant(nod).toList());
      } else if (strcmp(prop->name, "audio-device-list") == 0) {
        emit audioDevicesChanged(getAudioDevices());
      } else if (strcmp(prop->name, "playlist") == 0) {
        mpv_node* nod = (mpv_node*)prop->data;
        emit playlistChanged(mpv::qt::node_to_variant(nod).toList());
      } else if (strcmp(prop->name, "chapter-list") == 0) {
        mpv_node* nod = (mpv_node*)prop->data;
        emit chaptersChanged(mpv::qt::node_to_variant(nod).toList());
      } else if (strcmp(prop->name, "speed") == 0) {
        double speed = *(double*)prop->data;
        emit speedChanged(speed);
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
