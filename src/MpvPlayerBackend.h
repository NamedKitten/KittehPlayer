#ifndef MpvPlayerBackend_H
#define MpvPlayerBackend_H

#include <mpv/client.h>
#include <mpv/qthelper.hpp>
#include <mpv/render_gl.h>

#include <QObject>
#include <QOpenGLContext>
#include <QQuickFramebufferObject>

#include "enums.hpp"

class MpvRenderer;

class MpvPlayerBackend : public QQuickFramebufferObject
{
  Q_OBJECT
  mpv_handle* mpv;
  mpv_render_context* mpv_gl;
  bool onTop = false;

  friend class MpvRenderer;

public:
  static void on_update(void* ctx);

  MpvPlayerBackend(QQuickItem* parent = 0);
  virtual ~MpvPlayerBackend();
  virtual Renderer* createRenderer() const;

public slots:
  void launchAboutQt();
#ifdef DISCORD
  void updateDiscord();
#endif
  void togglePlayPause();
  void toggleMute();
  void nextAudioTrack();
  void nextVideoTrack();
  void nextSubtitleTrack();
  void prevPlaylistItem();
  void nextPlaylistItem();
  void toggleOnTop();
  void toggleStats();
  QVariant getTracks() const;
  QVariant getaudioDevices() const;
  void setAudioDevice(const QString& name);
  void addSpeed(const QVariant& speed);
  void subtractSpeed(const QVariant& speed);
  void changeSpeed(const QVariant& speedFactor);
  void setSpeed(const QVariant& speed);
  QVariant getTrack(const QString& track);
  void setTrack(const QVariant& track, const QVariant& id);
  void setVolume(const QVariant& volume);
  void addVolume(const QVariant& volume);
  void loadFile(const QVariant& filename);
  void appendFile(const QVariant& filename);
  void seek(const QVariant& seekTime);
  void seekAbsolute(const QVariant& seekTime);
  void command(const QVariant& params);
  void setProperty(const QString& name, const QVariant& value);
  void setOption(const QString& name, const QVariant& value);
  QVariant getProperty(const QString& name) const;
  QVariant createTimestamp(const QVariant& seconds) const;

signals:
  void onUpdate();
  void mpv_events();
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
  void tracksChanged();
  void audioDevicesChanged();

private slots:
  void doUpdate();
  void on_mpv_events();
  void updateDurationString();

private:
  void handle_mpv_event(mpv_event* event);
};

#endif
