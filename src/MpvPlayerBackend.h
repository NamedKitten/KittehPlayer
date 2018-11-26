#ifndef MpvPlayerBackend_H
#define MpvPlayerBackend_H

#include <mpv/client.h>
#include <mpv/qthelper.hpp>

#include <mpv/render_gl.h>

#include <QObject>
#include <QOpenGLContext>
#include <QQuickFramebufferObject>

#include "backendinterface.hpp"
#include "enums.hpp"
#include "utils.hpp"

class MpvRenderer;

class MpvPlayerBackend
  : public QQuickFramebufferObject
  , public BackendInterface
{
  Q_INTERFACES(BackendInterface)

  Q_OBJECT

  mpv_handle* mpv;
  mpv_render_context* mpv_gl;
  bool onTop = false;
  QString totalDurationString;

  friend class MpvRenderer;

public:
  static void on_update(void* ctx);

  MpvPlayerBackend(QQuickItem* parent = 0);
  virtual ~MpvPlayerBackend();
  virtual Renderer* createRenderer() const;

public slots:
  QVariant playerCommand(const Enums::Commands& command, const QVariant& args);
  QVariant playerCommand(const Enums::Commands& command);
  void launchAboutQt();
  void toggleOnTop();
  void updateAppImage();
  // Optional but handy for MPV or custom backend settings.
  void command(const QVariant& params);
  void setProperty(const QString& name, const QVariant& value);
  void setOption(const QString& name, const QVariant& value);
  QVariant getProperty(const QString& name) const;
  // Just used for adding missing audio devices to list.
  QVariantMap getAudioDevices() const;
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

private slots:
  void doUpdate();
  void on_mpv_events();
  void updateDurationString();

private:
  void handle_mpv_event(mpv_event* event);
#ifdef DISCORD
  void updateDiscord();
#endif
};

#endif
