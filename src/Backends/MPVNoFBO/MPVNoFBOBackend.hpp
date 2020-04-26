#ifndef MPVNoFBOBackend_H
#define MPVNoFBOBackend_H

#include <mpv/client.h>
#include <mpv/opengl_cb.h>
#include <QEvent>
#include <QMetaType>
#include <QObject>
#include <QQuickItem>
#include <QQuickWindow>
#include <QSettings>
#include <QSize>
#include <QString>
#include <QVariant>
#include "src/backendinterface.hpp"
#include "src/enums.hpp"

class MPVNoFBORenderer : public QObject
{
  Q_OBJECT
  mpv_handle* mpv;
  mpv_opengl_cb_context* mpv_gl;

public:
  QQuickWindow* window;
  QSize size;

  friend class MpvObject;
  MPVNoFBORenderer(mpv_handle* a_mpv, mpv_opengl_cb_context* a_mpv_gl);
  virtual ~MPVNoFBORenderer();
public slots:
  void paint();
};

class MPVNoFBOBackend
  : public QQuickItem
  , public BackendInterface
{
  Q_INTERFACES(BackendInterface)

  Q_OBJECT
  Q_PROPERTY(bool logging READ logging WRITE setLogging)

  mpv_handle* mpv;
  mpv_opengl_cb_context* mpv_gl;
  MPVNoFBORenderer* renderer;
  bool onTop = false;
  bool m_logging = true;
  QSettings settings;

public:
  static void on_update(void* ctx);

  void setLogging(bool a)
  {
    if (a != m_logging) {
      m_logging = a;
    }
  }
  bool logging() const { return m_logging; }

  MPVNoFBOBackend(QQuickItem* parent = 0);
  virtual ~MPVNoFBOBackend();

  int lastTime = 0;
  double lastSpeed = 0;
  QString totalDurationString;
  QString lastPositionString;

public slots:
  QVariant playerCommand(const Enums::Commands& command, const QVariant& args);
  QVariant playerCommand(const Enums::Commands& command);
  void launchAboutQt();
  void toggleOnTop();
  QString getStats();
  // Optional but handy for MPV or custom backend settings.
  void command(const QVariant& params);
  void setProperty(const QString& name, const QVariant& value);
  void setOption(const QString& name, const QVariant& value);
  QVariant getProperty(const QString& name) const;

  void sync();
  void swapped();
  void cleanup();

  // Just used for adding missing audio devices to list.
  QVariantMap getAudioDevices(const QVariant& drivers) const;

  bool event(QEvent* event);

signals:
  void onUpdate();
  void mpv_events();
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
  void handleWindowChanged(QQuickWindow* win);

private:
  void handle_mpv_event(mpv_event* event);
};

#endif