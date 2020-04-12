#ifndef MPVBackend_H
#define MPVBackend_H

#include <mpv/client.h>
#include <mpv/opengl_cb.h>
#include <mpv/qthelper.hpp>
#include <mpv/render_gl.h>

#include <QObject>
#include <QOpenGLContext>
#include <QQuickFramebufferObject>
#include <QSettings>

#include "src/backendinterface.hpp"
#include "src/enums.hpp"
#include "src/utils.hpp"

extern bool usedirect;

class MpvRenderer;

class MPVBackend
  : public QQuickFramebufferObject
  , public BackendInterface
{
  Q_INTERFACES(BackendInterface)

  Q_OBJECT
  Q_PROPERTY(bool logging READ logging WRITE setLogging)

  mpv_handle* mpv;
  mpv_render_context* mpv_gl;
  mpv_opengl_cb_context* mpv_gl_cb;

  QSettings settings;
  bool onTop = false;
  bool m_logging = true;

  int lastTime = 0;
  double lastSpeed = 0;
  QString totalDurationString;
  QString lastPositionString;

  friend class MpvRenderer;

public:
  static void on_update(void* ctx);

  MPVBackend(QQuickItem* parent = 0);
  virtual ~MPVBackend();
  virtual Renderer* createRenderer() const;

  void setLogging(bool a)
  {
    if (a != m_logging) {
      m_logging = a;
    }
  }
  bool logging() const { return m_logging; }

public slots:
  QVariant playerCommand(const Enums::Commands& command, const QVariant& args);
  QVariant playerCommand(const Enums::Commands& command);
  void toggleOnTop();
  QString getStats();
  // Optional but handy for MPV or custom backend settings.
  void command(const QVariant& params);
  void setProperty(const QString& name, const QVariant& value);
  void setOption(const QString& name, const QVariant& value);
  QVariant getProperty(const QString& name) const;
  // Just used for adding missing audio devices to list.
  QVariantMap getAudioDevices(const QVariant& drivers) const;
  bool event(QEvent* event);

signals:
  void onUpdate();
  void mpv_events();
  void onMpvEvent(mpv_event* event);
  // All below required for Player API
  void playStatusChanged(const Enums::PlayStatus& status);
  void volumeStatusChanged(const Enums::VolumeStatus& status);
  void volumeChanged(const int& volume);
  void durationChanged(const double& duration);
  void positionChanged(const double& position);
  void cachedDurationChanged(const double& duration);
  void playlistPositionChanged(const double& position);
  void titleChanged(const QString& title);
  void subtitlesChanged(const QString& subtitles);
  void durationStringChanged(const QString& string);
  void tracksChanged(const QVariantList& tracks);
  void audioDevicesChanged(const QVariantMap& devices);
  void playlistChanged(const QVariantList& devices);
  void chaptersChanged(const QVariantList& devices);
  void speedChanged(const double& speed);

private slots:
  void doUpdate();
  void on_mpv_events();
  void updateDurationString(int numTime);

private:
  void handle_mpv_event(mpv_event* event);
};

#endif
