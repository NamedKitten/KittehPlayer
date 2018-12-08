#include "utils.hpp"
#include <stdbool.h>

#include <QApplication>
#include <QGuiApplication>
#include <QJsonDocument>
#include <QProcessEnvironment>
#include <QQmlApplicationEngine>
#include <QSequentialIterable>
#include <QString>
#include <QVariant>
#include <QtCore>
#include <QtNetwork>

#ifdef __linux__
#ifdef ENABLE_X11
#include <QX11Info>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#endif
#endif

namespace Utils {
QString
getPlatformName()
{
  QGuiApplication* qapp =
    qobject_cast<QGuiApplication*>(QCoreApplication::instance());
  return qapp->platformName();
}

void
launchAboutQt()
{
  QApplication* qapp =
    qobject_cast<QApplication*>(QCoreApplication::instance());
  qapp->aboutQt();
}

void
checkForUpdates()
{
#ifdef GIT_COMMIT_HASH
  QString current_version = QString(GIT_COMMIT_HASH);
#else
  QString current_version = QString("Unknown");
#endif
  qDebug() << "Current Version: " << current_version;

  QNetworkRequest request(QUrl("https://api.github.com/repos/NamedKitten/"
                               "KittehPlayer/releases/tags/continuous"));

  QNetworkAccessManager nam;
  QNetworkReply* reply = nam.get(request);

  while (!reply->isFinished()) {
    qApp->processEvents();
  }
  QByteArray response_data = reply->readAll();
  QJsonDocument json = QJsonDocument::fromJson(response_data);

  if (json["target_commitish"].toString().length() != 0) {
    if (json["target_commitish"].toString().endsWith(current_version) == 0) {
      qDebug() << "Latest Version: " << json["target_commitish"].toString();
      qDebug() << "Update Available. Please update ASAP.";
      QProcess notifier;
      notifier.setProcessChannelMode(QProcess::ForwardedChannels);
      notifier.start("notify-send",
                     QStringList() << "KittehPlayer"
                                   << "New update avalable!"
                                   << "--icon=KittehPlayer");
      notifier.waitForFinished();
    }
  } else {
    qDebug() << "Couldn't check for new version.";
  }
}

void
updateAppImage()
{
  QString program =
    QProcessEnvironment::systemEnvironment().value("APPDIR", "") +
    "/usr/bin/appimageupdatetool";
  QProcess updater;
  updater.setProcessChannelMode(QProcess::ForwardedChannels);
  updater.start(program,
                QStringList() << QProcessEnvironment::systemEnvironment().value(
                  "APPIMAGE", ""));
  updater.waitForFinished();
  qApp->exit();
}

// https://www.youtube.com/watch?v=nXaxk27zwlk&feature=youtu.be&t=56m34s
inline const int
fast_mod(const int input, const int ceil)
{
  return input >= ceil ? input % ceil : input;
}

QString
createTimestamp(const int seconds)
{

  const int s = fast_mod(seconds, 60);
  const int m = fast_mod(seconds, 3600) / 60;
  const int h = fast_mod(seconds, 86400) / 3600;

  if (h > 0) {
    return QString::asprintf("%02d:%02d:%02d", h, m, s);
  } else {
    return QString::asprintf("%02d:%02d", m, s);
  }
}

void
SetScreensaver(WId wid, bool on)
{
  QProcess xdgScreensaver;
  xdgScreensaver.setProcessChannelMode(QProcess::ForwardedChannels);
  if (on) {
    qDebug() << "Enabling screensaver.";
    xdgScreensaver.start("xdg-screensaver",
                         QStringList() << "resume" << QString::number(wid));
  } else {
    qDebug() << "Disabling screensaver.";
    xdgScreensaver.start("xdg-screensaver",
                         QStringList() << "suspend" << QString::number(wid));
  }
  xdgScreensaver.waitForFinished();
}

void
SetDPMS(bool on)
{
#ifdef __linux__
  if (getPlatformName() != "xcb") {
    return;
  }
  QProcess xsetProcess;
  xsetProcess.setProcessChannelMode(QProcess::ForwardedChannels);
  if (on) {
    qDebug() << "Enabled DPMS.";
    xsetProcess.start("xset",
                      QStringList() << "s"
                                    << "on"
                                    << "+dpms");
  } else {
    qDebug() << "Disabled DPMS.";
    xsetProcess.start("xset",
                      QStringList() << "s"
                                    << "off"
                                    << "-dpms");
  }
  xsetProcess.waitForFinished();
#else
  qDebug() << "Can't set DPMS for platform: " << getPlatformName();
#endif
}

void
AlwaysOnTop(WId wid, bool on)
{
#ifdef __linux__
#ifdef ENABLE_X11
  Display* display = QX11Info::display();
  XEvent event;
  event.xclient.type = ClientMessage;
  event.xclient.serial = 0;
  event.xclient.send_event = True;
  event.xclient.display = display;
  event.xclient.window = wid;
  event.xclient.message_type = XInternAtom(display, "_NET_WM_STATE", False);
  event.xclient.format = 32;

  event.xclient.data.l[0] = on;
  event.xclient.data.l[1] = XInternAtom(display, "_NET_WM_STATE_ABOVE", False);
  event.xclient.data.l[2] = 0;
  event.xclient.data.l[3] = 0;
  event.xclient.data.l[4] = 0;

  XSendEvent(display,
             DefaultRootWindow(display),
             False,
             SubstructureRedirectMask | SubstructureNotifyMask,
             &event);
#endif
#else
  qDebug() << "Can't set on top for platform: " << getPlatformName();
#endif
}
}
