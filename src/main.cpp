#ifdef QRC_SOURCE_PATH
#include "runtimeqml/runtimeqml.h"
#endif

#include <cstdlib>
#include "MpvPlayerBackend.h"
#include <QtCore>
#include <QApplication>
#include <QProcessEnvironment>
#include <QQmlApplicationEngine>
#include <stdbool.h>
#include <QX11Info>
#include <X11/extensions/Xrandr.h>
#include <X11/extensions/dpms.h>
#include <X11/keysym.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

#ifdef WIN32
#include "setenv_mingw.hpp"
#endif

int
main(int argc, char* argv[])
{
  setenv("QT_QUICK_CONTROLS_STYLE", "Desktop", 1);
  QApplication app(argc, argv);
  app.setOrganizationName("KittehPlayer");
  app.setOrganizationDomain("namedkitten.pw");
  app.setApplicationName("KittehPlayer");
  for (int i = 1; i < argc; ++i) {
    if (!qstrcmp(argv[i], "--update")) {
      QString program =
        QProcessEnvironment::systemEnvironment().value("APPDIR", "") +
        "/usr/bin/appimageupdatetool";
      QProcess updater;
      updater.setProcessChannelMode(QProcess::ForwardedChannels);
      updater.start(program,
                    QStringList()
                      << QProcessEnvironment::systemEnvironment().value(
                           "APPIMAGE", ""));
      updater.waitForFinished();
      qDebug() << program;
      exit(0);
    }
  }

  Display *dpy = QX11Info::display();
  DPMSDisable(dpy);
  qDebug() << "Disabled DPMS.";

  QString newpath =
    QProcessEnvironment::systemEnvironment().value("APPDIR", "") +
    "/usr/bin:" + QProcessEnvironment::systemEnvironment().value("PATH", "");
  qDebug() << newpath;
  setenv("PATH", newpath.toUtf8().constData(), 1);

  QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  QApplication::setAttribute(Qt::AA_NativeWindows); 
  
  qmlRegisterType<MpvPlayerBackend>("player", 1, 0, "PlayerBackend");
  std::setlocale(LC_NUMERIC, "C");

  QQmlApplicationEngine engine;
#ifdef QRC_SOURCE_PATH
  RuntimeQML* rt = new RuntimeQML(&engine, QRC_SOURCE_PATH "/qml.qrc");

  rt->setAutoReload(true);
  rt->setMainQmlFilename("main.qml");
  rt->reload();
#else
  engine.load(QUrl(QStringLiteral("qrc:///player/main.qml")));
#endif

  return app.exec();
}
