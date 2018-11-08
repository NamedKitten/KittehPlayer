
#include <clocale>
#include <stdbool.h>
#include <stdexcept>

#include "MpvPlayerBackend.h"

#include "utils.hpp"
#include <QApplication>
#include <QOpenGLContext>
#include <QOpenGLFramebufferObject>
#include <QQuickWindow>
#include <math.h>

namespace {

void
wakeup(void* ctx)
{
  QMetaObject::invokeMethod(
    (MpvPlayerBackend*)ctx, "on_mpv_events", Qt::QueuedConnection);
}

void
on_mpv_redraw(void* ctx)
{
  MpvPlayerBackend::on_update(ctx);
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
        { MPV_RENDER_PARAM_INVALID, nullptr }
      };
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
      // Specify the default framebuffer (0) as target. This will
      // render onto the entire screen. If you want to show the video
      // in a smaller rectangle or apply fancy transformations, you'll
      // need to render into a separate FBO and draw it manually.
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
  mpv_observe_property(mpv, 0, "playback-abort", MPV_FORMAT_NONE);
  mpv_observe_property(mpv, 0, "chapter-list", MPV_FORMAT_NODE);
  mpv_observe_property(mpv, 0, "track-list", MPV_FORMAT_NODE);
  mpv_observe_property(mpv, 0, "playlist-pos", MPV_FORMAT_DOUBLE);
  mpv_observe_property(mpv, 0, "volume", MPV_FORMAT_DOUBLE);
  mpv_observe_property(mpv, 0, "muted", MPV_FORMAT_NONE);
  mpv_observe_property(mpv, 0, "duration", MPV_FORMAT_DOUBLE);
  mpv_observe_property(mpv, 0, "media-title", MPV_FORMAT_STRING);
  mpv_observe_property(mpv, 0, "sub-text", MPV_FORMAT_STRING);
  mpv_observe_property(mpv, 0, "time-pos", MPV_FORMAT_DOUBLE);
  mpv_observe_property(mpv, 0, "demuxer-cache-duration", MPV_FORMAT_DOUBLE);
  mpv_observe_property(mpv, 0, "pause", MPV_FORMAT_NONE);
  mpv_set_wakeup_callback(mpv, wakeup, this);

  if (mpv_initialize(mpv) < 0)
    throw std::runtime_error("could not initialize mpv context");

  connect(this,
          &MpvPlayerBackend::onUpdate,
          this,
          &MpvPlayerBackend::doUpdate,
          Qt::QueuedConnection);
}

MpvPlayerBackend::~MpvPlayerBackend()
{
  SetDPMS(true);
  mpv_render_context_free(mpv_gl);
  mpv_terminate_destroy(mpv);
}

void
MpvPlayerBackend::on_update(void* ctx)
{
  MpvPlayerBackend* self = (MpvPlayerBackend*)ctx;
  emit self->onUpdate();
}

// connected to onUpdate(); signal makes sure it runs on the GUI thread
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
  mpv::qt::command_variant(mpv, params);
}

void
MpvPlayerBackend::setProperty(const QString& name, const QVariant& value)
{
  mpv::qt::set_property_variant(mpv, name, value);
}

void
MpvPlayerBackend::setOption(const QString& name, const QVariant& value)
{
  mpv::qt::set_option_variant(mpv, name, value);
}

void
MpvPlayerBackend::launchAboutQt()
{
  QApplication* qapp =
    qobject_cast<QApplication*>(QCoreApplication::instance());
  qapp->aboutQt();
}

void
MpvPlayerBackend::togglePlayPause()
{
  command(QVariantList() << "cycle"
                         << "pause");
}

void
MpvPlayerBackend::toggleMute()
{
  command(QVariantList() << "cycle"
                         << "mute");
}

void
MpvPlayerBackend::nextAudioTrack()
{
  command(QVariantList() << "cycle"
                         << "audio");
}
void
MpvPlayerBackend::nextSubtitleTrack()
{
  command(QVariantList() << "cycle"
                         << "sub");
}

void
MpvPlayerBackend::nextVideoTrack()
{
  command(QVariantList() << "cycle"
                         << "video");
}

void
MpvPlayerBackend::prevPlaylistItem()
{
  command(QVariantList() << "playlist-prev");
}

void
MpvPlayerBackend::nextPlaylistItem()
{
  command(QVariantList() << "playlist-next"
                         << "force");
}

void
MpvPlayerBackend::loadFile(const QVariant& filename)
{
  command(QVariantList() << "loadfile" << filename);
}

void
MpvPlayerBackend::setVolume(const QVariant& volume)
{
  command(QVariantList() << "set"
                         << "volume" << volume);
}

void
MpvPlayerBackend::addVolume(const QVariant& volume)
{
  command(QVariantList() << "add"
                         << "volume" << volume);
}

void
MpvPlayerBackend::seek(const QVariant& seekTime)
{
  command(QVariantList() << "seek" << seekTime);
}

QVariant
MpvPlayerBackend::getTracks() const
{
  return mpv::qt::get_property_variant(mpv, "track-list");
}

void
MpvPlayerBackend::setTrack(const QVariant& track, const QVariant& id)
{
  command(QVariantList() << "set" << track << id);
}

QVariant
MpvPlayerBackend::getTrack(const QString& track)
{
  return mpv::qt::get_property_variant(mpv, track);
}

QVariant
MpvPlayerBackend::createTimestamp(const QVariant& seconds) const
{
  int d = seconds.toInt();
  double h = floor(d / 3600);
  double m = floor(d % 3600 / 60);
  double s = floor(d % 3600 % 60);

  QString hour = h > 0 ? QString::number(h) + ":" : "";
  QString minute = h < 1 ? QString::number(m) + ":"
                         : (m < 10 ? "0" + QString::number(m) + ":"
                                   : QString::number(m) + ":");
  QString second = s < 10 ? "0" + QString::number(s) : QString::number(s);
  return hour + minute + second;
}

void
MpvPlayerBackend::toggleOnTop()
{
  onTop = !onTop;
  AlwaysOnTop(window()->winId(), onTop);
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
MpvPlayerBackend::updateDurationStringText()
{
  findChild<QObject*>("timeLabel")
    ->setProperty("text",
                  QString("%1  / %2 (%3x)")
                    .arg(createTimestamp(getProperty("time-pos")).toString(),
                         createTimestamp(getProperty("duration")).toString(),
                         getProperty("speed").toString()));
}

void
MpvPlayerBackend::updatePrev(const QVariant& val)
{
  if (val.toDouble() != 0) {
    findChild<QObject*>("playlistPrevButton")->setProperty("visible", true);
  } else {
    findChild<QObject*>("playlistPrevButton")->setProperty("visible", false);
  }
}

void
MpvPlayerBackend::updateVolume(const QVariant& val)
{
  if (getProperty("mute").toBool() || (val.toDouble() == 0)) {
    findChild<QObject*>("volumeButton")
      ->setProperty("iconSource", "qrc:/player/icons/volume-mute.svg");
  } else {
    if (val.toDouble() < 25) {
      findChild<QObject*>("volumeButton")
        ->setProperty("iconSource", "qrc:/player/icons/volume-down.svg");
    } else {
      findChild<QObject*>("volumeButton")
        ->setProperty("iconSource", "qrc:/player/icons/volume-up.svg");
    }
  }
}

void
MpvPlayerBackend::updatePlayPause(const QVariant& val)
{
  if (val.toBool()) {
    findChild<QObject*>("playPauseButton")
      ->setProperty("iconSource", "qrc:/player/icons/play.svg");
  } else {
    findChild<QObject*>("playPauseButton")
      ->setProperty("iconSource", "qrc:/player/icons/pause.svg");
  }
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
          updateDurationStringText();
          findChild<QObject*>("progressBar")->setProperty("value", time);
        }
      } else if (strcmp(prop->name, "duration") == 0) {
        if (prop->format == MPV_FORMAT_DOUBLE) {
          double time = *(double*)prop->data;
          findChild<QObject*>("progressBar")->setProperty("to", time);
        }
      } else if (strcmp(prop->name, "volume") == 0) {
        if (prop->format == MPV_FORMAT_DOUBLE) {
          double volume = *(double*)prop->data;
          updateVolume(QVariant(volume));
        }
      } else if (strcmp(prop->name, "muted") == 0) {
        updateVolume(getProperty("volume"));
      } else if (strcmp(prop->name, "media-title") == 0) {
        if (prop->format == MPV_FORMAT_STRING) {
          char* title = *(char**)prop->data;
          findChild<QObject*>("titleLabel")->setProperty("text", title);
        }
      } else if (strcmp(prop->name, "sub-text") == 0) {
        if (prop->format == MPV_FORMAT_STRING) {
          char* subs = *(char**)prop->data;
          findChild<QObject*>("nativeSubs")->setProperty("text", subs);
        }
      } else if (strcmp(prop->name, "demuxer-cache-duration") == 0) {
        if (prop->format == MPV_FORMAT_DOUBLE) {
          double duration = *(double*)prop->data;
          QMetaObject::invokeMethod(
            this, "setCachedDuration", Q_ARG(QVariant, duration));
        }
      } else if (strcmp(prop->name, "playlist-pos") == 0) {
        if (prop->format == MPV_FORMAT_DOUBLE) {
          double pos = *(double*)prop->data;
          updatePrev(QVariant(pos));
        }
      } else if (strcmp(prop->name, "pause") == 0) {
        updatePlayPause(getProperty("pause"));
      } else if (strcmp(prop->name, "tracks-menu") == 0) {
        QMetaObject::invokeMethod(this, "tracksUpdate");
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
  window()->setPersistentOpenGLContext(true);
  window()->setPersistentSceneGraph(true);
  return new MpvRenderer(const_cast<MpvPlayerBackend*>(this));
}
