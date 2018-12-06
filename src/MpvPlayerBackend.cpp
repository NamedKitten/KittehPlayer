#include "MpvPlayerBackend.h"
#include <clocale>
#include <stdbool.h>
#include <stdexcept>

#include "utils.hpp"
#include <QApplication>
#include <QElapsedTimer>
#include <QOpenGLContext>
#include <QOpenGLFramebufferObject>
#include <QQuickWindow>
#include <QSequentialIterable>
#include <math.h>

#ifdef __linux__
#include <QX11Info>
#include <QtX11Extras/QX11Info>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <qpa/qplatformnativeinterface.h>
#endif

namespace {

void
wakeup(void* ctx)
{
  QCoreApplication::postEvent((MpvPlayerBackend*)ctx, new QEvent(QEvent::User));
}

void
on_mpv_redraw(void* ctx)
{
  QMetaObject::invokeMethod(
    reinterpret_cast<MpvPlayerBackend*>(ctx), "update", Qt::QueuedConnection);
}

static void*
get_proc_address_mpv(void* ctx, const char* name)
{
  Q_UNUSED(ctx)

  QOpenGLContext* glctx = QOpenGLContext::currentContext();
  if (!glctx)
    return nullptr;

  return reinterpret_cast<void*>(glctx->getProcAddress(QByteArray(name)));
}

} // namespace

class MpvRenderer : public QQuickFramebufferObject::Renderer
{
  MpvPlayerBackend* obj;

public:
  MpvRenderer(MpvPlayerBackend* new_obj)
    : obj{ new_obj }
  {}

  virtual ~MpvRenderer() {}

  // This function is called when a new FBO is needed.
  // This happens on the initial frame.
  QOpenGLFramebufferObject* createFramebufferObject(const QSize& size)
  {
    // init mpv_gl:
    if (!obj->mpv_gl) {
      mpv_opengl_init_params gl_init_params{ get_proc_address_mpv,
                                             nullptr,
                                             nullptr };
      mpv_render_param params[]{
        { MPV_RENDER_PARAM_API_TYPE,
          const_cast<char*>(MPV_RENDER_API_TYPE_OPENGL) },
        { MPV_RENDER_PARAM_OPENGL_INIT_PARAMS, &gl_init_params },
        { MPV_RENDER_PARAM_INVALID, nullptr },
        { MPV_RENDER_PARAM_INVALID, nullptr }
      };
#if __linux__
      if (QGuiApplication::platformName().contains("xcb")) {
        params[2].type = MPV_RENDER_PARAM_X11_DISPLAY;
        params[2].data = QX11Info::display();
        qDebug() << "On Xorg.";
      } else if (QGuiApplication::platformName().contains("wayland")) {
        QPlatformNativeInterface* native =
          QGuiApplication::platformNativeInterface();
        params[2].type = MPV_RENDER_PARAM_WL_DISPLAY;
        params[2].data = native->nativeResourceForWindow("display", nullptr);
        qDebug() << "On wayland.";
      }
#endif

      if (mpv_render_context_create(&obj->mpv_gl, obj->mpv, params) < 0)
        throw std::runtime_error("failed to initialize mpv GL context");
      mpv_render_context_set_update_callback(obj->mpv_gl, on_mpv_redraw, obj);
      QMetaObject::invokeMethod(obj, "startPlayer");
    }

    return QQuickFramebufferObject::Renderer::createFramebufferObject(size);
  }

  void render()
  {
    obj->window()->resetOpenGLState();

    QOpenGLFramebufferObject* fbo = framebufferObject();
    mpv_opengl_fbo mpfbo{ .fbo = static_cast<int>(fbo->handle()),
                          .w = fbo->width(),
                          .h = fbo->height(),
                          .internal_format = 0 };
    int flip_y{ 0 };
    mpv_render_param params[] = {
      { MPV_RENDER_PARAM_OPENGL_FBO, &mpfbo },

      // Flip rendering (needed due to flipped GL coordinate system).
      { MPV_RENDER_PARAM_FLIP_Y, &flip_y },
      { MPV_RENDER_PARAM_INVALID, nullptr }
    };

    // See render_gl.h on what OpenGL environment mpv expects, and
    // other API details.
    mpv_render_context_render(obj->mpv_gl, params);
    obj->window()->resetOpenGLState();
  }
};

MpvPlayerBackend::MpvPlayerBackend(QQuickItem* parent)
  : QQuickFramebufferObject(parent)
  , mpv{ mpv_create() }
  , mpv_gl(nullptr)
{
  if (!mpv)
    throw std::runtime_error("could not create mpv context");

  mpv_set_option_string(mpv, "terminal", "yes");
  mpv_set_option_string(mpv, "msg-level", "all=v");

  // Fix?
  mpv_set_option_string(mpv, "ytdl", "yes");
  mpv_set_option_string(mpv, "vo", "libmpv");
  // mpp_set_option_string(mpv, "no-sub-ass", "yes)

  mpv_set_option_string(mpv, "slang", "en");

  mpv_set_option_string(mpv, "config", "yes");
  // mpv_set_option_string(mpv, "sub-visibility", "no");
  mpv_observe_property(mpv, 0, "tracks-menu", MPV_FORMAT_NONE);
  mpv_observe_property(mpv, 0, "chapter-list", MPV_FORMAT_NODE);
  mpv_observe_property(mpv, 0, "playback-abort", MPV_FORMAT_NONE);
  mpv_observe_property(mpv, 0, "chapter-list", MPV_FORMAT_NODE);
  mpv_observe_property(mpv, 0, "track-list", MPV_FORMAT_NODE);
  mpv_observe_property(mpv, 0, "audio-device-list", MPV_FORMAT_NODE);
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

  connect(this,
          &MpvPlayerBackend::onUpdate,
          this,
          &MpvPlayerBackend::doUpdate,
          Qt::QueuedConnection);
  connect(this,
          &MpvPlayerBackend::positionChanged,
          this,
          &MpvPlayerBackend::updateDurationString,
          Qt::QueuedConnection);
  connect(this,
          &MpvPlayerBackend::durationChanged,
          this,
          &MpvPlayerBackend::updateDurationString,
          Qt::QueuedConnection);
}

MpvPlayerBackend::~MpvPlayerBackend()
{
  printf("Shutting down...\n");
  Utils::SetDPMS(true);
  command("quit-watch-later");
  mpv_render_context_free(mpv_gl);
  mpv_terminate_destroy(mpv);
  printf("MPV terminated.\n");
}

void
MpvPlayerBackend::on_update(void* ctx)
{
  MpvPlayerBackend* self = (MpvPlayerBackend*)ctx;
  emit self->onUpdate();
}

void
MpvPlayerBackend::doUpdate()
{
  update();
}

QVariant
MpvPlayerBackend::getProperty(const QString& name) const
{
  return mpv::qt::get_property_variant(mpv, name);
}

void
MpvPlayerBackend::command(const QVariant& params)
{
  mpv::qt::node_builder node(params);
  mpv_command_node(mpv, node.node(), nullptr);
}

void
MpvPlayerBackend::setProperty(const QString& name, const QVariant& value)
{
  mpv::qt::node_builder node(value);
  qDebug() << "Setting property" << name << "to" << value;
  mpv_set_property(mpv, name.toUtf8().data(), MPV_FORMAT_NODE, node.node());
}

void
MpvPlayerBackend::setOption(const QString& name, const QVariant& value)
{
  mpv::qt::set_option_variant(mpv, name, value);
}

QVariant
MpvPlayerBackend::playerCommand(const Enums::Commands& cmd)
{
  return playerCommand(cmd, QVariant("NoArgProvided"));
}

QVariant
MpvPlayerBackend::playerCommand(const Enums::Commands& cmd,
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
MpvPlayerBackend::toggleOnTop()
{
  onTop = !onTop;
  Utils::AlwaysOnTop(window()->winId(), onTop);
}

bool
MpvPlayerBackend::event(QEvent* event)
{
  if (event->type() == QEvent::User) {
    on_mpv_events();
  }
  return QObject::event(event);
}

void
MpvPlayerBackend::on_mpv_events()
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
MpvPlayerBackend::updateDurationString(int numTime)
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

QVariantMap
MpvPlayerBackend::getAudioDevices(const QVariant& drivers) const
{
  QVariantMap newDrivers;

  QSequentialIterable iterable = drivers.value<QSequentialIterable>();
  foreach (const QVariant& v, iterable) {
    QVariantMap item = v.toMap();
    newDrivers[item["description"].toString()] = item;
  }
  return newDrivers;
}

void
MpvPlayerBackend::handle_mpv_event(mpv_event* event)
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
          // Utils::SetScreensaver(window()->winId(), true);
        } else {
          emit playStatusChanged(Enums::PlayStatus::Playing);
          // Utils::SetScreensaver(window()->winId(), false);
        }
      } else if (strcmp(prop->name, "track-list") == 0) {
        mpv_node* nod = (mpv_node*)prop->data;
        emit tracksChanged(mpv::qt::node_to_variant(nod).toList());
      } else if (strcmp(prop->name, "audio-device-list") == 0) {
        mpv_node* nod = (mpv_node*)prop->data;
        emit audioDevicesChanged(
          getAudioDevices(mpv::qt::node_to_variant(nod)));
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

QQuickFramebufferObject::Renderer*
MpvPlayerBackend::createRenderer() const
{
  window()->setIcon(QIcon(":/icon.png"));
  window()->setPersistentOpenGLContext(true);
  window()->setPersistentSceneGraph(true);
  return new MpvRenderer(const_cast<MpvPlayerBackend*>(this));
}
