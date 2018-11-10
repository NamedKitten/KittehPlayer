#include "utils.hpp"
#include <stdbool.h>

#include <QGuiApplication>
#include <QtCore>

QString getPlatformName()
{
  QGuiApplication* qapp = qobject_cast<QGuiApplication*>(QCoreApplication::instance());
  return qapp->platformName();
}

#ifdef __linux__
#include <QX11Info>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/extensions/Xrandr.h>
#include <X11/extensions/dpms.h>
#include <X11/keysym.h>

void SetDPMS(bool on)
{
  qDebug() << getPlatformName();
  if (getPlatformName() != "xcb") {
    return;
  }
  Display* dpy = QX11Info::display();
  if (on) {
    DPMSEnable(dpy);
    qDebug() << "Enabled DPMS.";
  } else {
    DPMSDisable(dpy);
    qDebug() << "Disabled DPMS.";
  }
}

void AlwaysOnTop(WId wid, bool on)
{
  qDebug() << "On Top:" << on;
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

  XSendEvent(display, DefaultRootWindow(display), False, SubstructureRedirectMask | SubstructureNotifyMask, &event);
}

#else

void AlwaysOnTop(WId wid, bool on)
{
  qDebug() << "Can't set on top for platform: " << getPlatformName();
}

void SetDPMS(bool on)
{
  qDebug() << "Can't set DPMS for platform: " << getPlatformName();
}

#endif