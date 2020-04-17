#include <QObject>
#include <QOpenGLContext>
#include <QQuickFramebufferObject>

#include "enums.hpp"

#ifndef BackendInterface_H
#define BackendInterface_H

class BackendInterface
{
public:
  virtual ~BackendInterface(){};
  int lastTime = 0;
  double lastSpeed = 0;
  QString totalDurationString;
  QString lastPositionString;

public slots:
  // All 5 required for Player API
  virtual QVariant playerCommand(const Enums::Commands& command,
                                 const QVariant& args) = 0;
  virtual QVariant playerCommand(const Enums::Commands& command) = 0;
  virtual void toggleOnTop() = 0;
  // Optional but handy for MPV or custom backend settings.
  virtual void command(const QVariant& params) = 0;
  virtual void setProperty(const QString& name, const QVariant& value) = 0;
  virtual void setOption(const QString& name, const QVariant& value) = 0;
  virtual QVariant getProperty(const QString& name) const = 0;
  virtual QVariantMap getAudioDevices(const QVariant& drivers) const = 0;


signals:
  // All below required for Player API
  virtual void playStatusChanged(const Enums::PlayStatus& status) = 0;
  virtual void volumeStatusChanged(const Enums::VolumeStatus& status) = 0;
  virtual void volumeChanged(const int& volume) = 0;
  virtual void durationChanged(const double& duration) = 0;
  virtual void positionChanged(const double& position) = 0;
  virtual void cachedDurationChanged(const double& duration) = 0;
  virtual void playlistPositionChanged(const double& position) = 0;
  virtual void titleChanged(const QString& title) = 0;
  virtual void subtitlesChanged(const QString& subtitles) = 0;
  virtual void durationStringChanged(const QString& string) = 0;
  virtual void tracksChanged(const QVariantList& tracks) = 0;
  virtual void audioDevicesChanged(const QVariantMap& devices) = 0;
  virtual void playlistChanged(const QVariantList& devices) = 0;
  virtual void chaptersChanged(const QVariantList& devices) = 0;
  virtual void speedChanged(const double& speed) = 0;
};
Q_DECLARE_INTERFACE(BackendInterface, "NamedKitten.BackendInterface");

#endif
