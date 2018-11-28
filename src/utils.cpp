#include "utils.hpp"
#include <stdbool.h>

#include <QApplication>
#include <QGuiApplication>
#include <QProcessEnvironment>
#include <QQmlApplicationEngine>
#include <QString>
#include <QVariant>
#include <QtCore>

#ifdef __linux__
#ifdef ENABLE_X11
#include <QX11Info>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/extensions/Xrandr.h>
#include <X11/extensions/dpms.h>
#include <X11/keysym.h>
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
int
fast_mod(const int input, const int ceil)
{
  return input >= ceil ? input % ceil : input;
}

QString
createTimestamp(int seconds)
{

  int s = fast_mod(seconds, 60);
  int m = fast_mod(seconds, 3600) / 60;
  int h = fast_mod(seconds, 86400) / 3600;

  if (h > 0) {
    return QString::asprintf("%02d:%02d:%02d", h, m, s);
  } else {
    return QString::asprintf("%02d:%02d", m, s);
  }
}

#ifdef __linux__
void
SetDPMS(bool on)
{
  if (getPlatformName() != "xcb") {
    return;
  }
#ifdef ENABLE_X11
  Display* dpy = QX11Info::display();
  if (on) {
    DPMSEnable(dpy);
    qDebug() << "Enabled DPMS.";
  } else {
    DPMSDisable(dpy);
    qDebug() << "Disabled DPMS.";
  }
#endif
}
void
ResetScreensaver()
{
#ifdef ENABLE_X11
  Display* display = QX11Info::display();
  XResetScreenSaver(display);
#endif
}

void
AlwaysOnTop(WId wid, bool on)
{
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
}

#else

void
AlwaysOnTop(WId wid, bool on)
{
  qDebug() << "Can't set on top for platform: " << getPlatformName();
}

void
SetDPMS(bool on)
{
  qDebug() << "Can't set DPMS for platform: " << getPlatformName();
}

void
ResetScreensaver()
{
  qDebug() << "Can't reset screensaver for: " << getPlatformName();
}

#endif
}
